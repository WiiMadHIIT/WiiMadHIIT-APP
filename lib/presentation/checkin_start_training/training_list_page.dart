import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../domain/entities/training_product.dart';
import '../../domain/entities/training_item.dart';
import '../../domain/services/training_service.dart';
import '../../domain/usecases/get_training_product_usecase.dart';
import '../../data/repository/training_repository.dart';
import '../../data/api/training_api.dart';
import 'training_list_viewmodel.dart';
import '../../widgets/training_error_content.dart';
import '../../widgets/training_loading_content.dart';
import 'dart:ui';

class TrainingListPage extends StatelessWidget {
  final String? productId; // 产品ID，用于加载对应配置
  
  const TrainingListPage({
    Key? key,
    this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final trainingApi = TrainingApi();
        final trainingRepository = TrainingRepository(trainingApi);
        final trainingService = TrainingService();
        final getTrainingProductUseCase = GetTrainingProductUseCase(trainingRepository, trainingService);
        final viewModel = TrainingListViewModel(getTrainingProductUseCase);
        
        // 加载数据
        if (productId != null && productId!.isNotEmpty) {
          viewModel.loadTrainingProduct(productId!);
        }
        
        return viewModel;
      },
      child: _TrainingListPageContent(),
    );
  }
}

class _TrainingListPageContent extends StatefulWidget {
  @override
  State<_TrainingListPageContent> createState() => _TrainingListPageContentState();
}

class _TrainingListPageContentState extends State<_TrainingListPageContent> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;
  bool _isVideoInitialized = false;
  
  // ViewModel 引用
  TrainingListViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    
    // 在第一个帧渲染后智能加载训练产品数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel = context.read<TrainingListViewModel>();
      
      // 检查是否有缓存数据，如果有则取消清理定时器
      if (_viewModel!.hasCachedData) {
        _viewModel!.cancelCleanup();
        // 如果有缓存数据，初始化视频
        if (_viewModel!.hasData && _viewModel!.pageConfig != null) {
          _initializeVideo();
        }
      } else {
        // 如果没有缓存数据，需要重新加载
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final productId = args?['productId'] as String? ?? '';
        if (productId.isNotEmpty) {
          _viewModel!.loadTrainingProduct(productId);
        }
      }
      
      // 添加监听器，当数据加载完成后重新初始化视频
      _viewModel!.addListener(_onViewModelChanged);
    });
  }

  // ViewModel 变化监听器
  void _onViewModelChanged() {
    if (mounted && _viewModel != null) {
      if (_viewModel!.hasData && _viewModel!.pageConfig != null && !_isVideoInitialized) {
        _initializeVideo();
      }
    }
  }
  
  // 视频状态变化监听器
  void _onVideoStateChanged() {
    if (mounted && _videoController != null) {
      setState(() {
        // 同步视频播放状态
        _isVideoPlaying = _videoController!.value.isPlaying;
      });
    }
  }
  
  // 释放视频控制器
  void _disposeVideoController() {
    if (_videoController != null) {
      _videoController!.removeListener(_onVideoStateChanged);
      _videoController!.pause();
      _videoController!.dispose();
      _videoController = null;
      _isVideoInitialized = false;
      _isVideoPlaying = false;
    }
  }

  void _initializeVideo() {
    final viewModel = context.read<TrainingListViewModel>();
    final pageConfig = viewModel.pageConfig;
    
    if (pageConfig == null) return;
    
    // 只有在有自定义视频时才尝试加载网络视频
    if (pageConfig.hasCustomVideo) {
      final videoUrl = pageConfig.displayVideoUrl;
      
      // 先释放之前的视频控制器
      _disposeVideoController();
      
      // 网络视频
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..setLooping(true)
        ..setVolume(0.0)
        ..addListener(_onVideoStateChanged)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
          }
        }).catchError((error) {
          // 网络视频加载失败，不加载本地视频，直接设置为未初始化状态
          print('Network video failed, not loading local video: $error');
          if (mounted) {
            setState(() {
              _isVideoInitialized = false;
            });
          }
        });
    } else {
      // 没有自定义视频时，不加载任何视频
      print('No custom video configured, skipping video initialization');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }



  @override
  void dispose() {
    // 释放动画控制器
    _animationController.dispose();
    
    // 释放视频控制器
    _disposeVideoController();
    
    // 移除 ViewModel 监听器
    if (_viewModel != null) {
      _viewModel!.removeListener(_onViewModelChanged);
      
      // 智能延迟清理：延迟清理数据以提升用户体验
      _viewModel!.scheduleCleanup();
      
      _viewModel = null;
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingListViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: CustomScrollView(
            slivers: [
              // SliverAppBar 始终可见，提供一致的导航体验
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildVideoSection(viewModel.pageConfig),
                ),
              ),
              
              // 内容区域：根据状态显示不同内容
              if (viewModel.isLoading)
                // 加载状态
                SliverToBoxAdapter(
                  child: TrainingListLoadingContent(),
                )
              else if (viewModel.hasError)
                // 错误状态
                SliverToBoxAdapter(
                                  child: TrainingListErrorContent(
                  onRetry: () {
                    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                    final productId = args?['productId'] as String? ?? '';
                    if (productId.isNotEmpty) {
                      viewModel.loadTrainingProduct(productId);
                    }
                  },
                ),
                )
              else if (!viewModel.hasData || !viewModel.hasAvailableTrainings)
                // 无数据状态
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No training data available',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please check back later',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                // 正常数据状态
                // 项目列表标题
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewModel.pageConfig!.pageTitle,
                          style: AppTextStyles.headlineLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          viewModel.pageConfig!.pageSubtitle,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 训练项目列表
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _TrainingCard(
                          training: viewModel.displayTrainings[index],
                          levelColor: _getLevelColorInt(viewModel.displayTrainings[index].level),
                          onTap: () => _onTrainingTap(viewModel.displayTrainings[index]),
                        );
                      },
                      childCount: viewModel.displayTrainings.length,
                    ),
                  ),
                ),

                // 底部间距
                SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ],
          ),
        );
      },
    );
  }



  Widget _buildVideoSection(TrainingPageConfig? pageConfig) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.4),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 视频背景
          _isVideoInitialized && _videoController != null
              ? Center(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // 根据 hasCustomThumbnail 决定使用网络图片还是本地图片
                        pageConfig?.hasCustomThumbnail == true
                            ? Image.network(
                                pageConfig!.displayThumbnailUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.black,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : pageConfig != null
                                ? Image.asset(
                                    pageConfig.displayThumbnailUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                : Container(
                                    color: Colors.black,
                                    child: Center(
                                      child: Icon(
                                        Icons.videocam_off,
                                        color: Colors.white.withOpacity(0.6),
                                        size: 48,
                                      ),
                                    ),
                                  ),
                        // 颜色滤镜覆盖层
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          
          // 视频渐变覆盖层
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: _isVideoPlaying && _isVideoInitialized
                ? GestureDetector(
                    onTap: _toggleVideo,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  )
                : null,
          ),
          
          // 播放按钮
          if (!_isVideoPlaying || !_isVideoInitialized)
            Center(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: _isVideoInitialized ? _toggleVideo : null,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: _isVideoInitialized
                              ? Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                )
                              : SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // 视频标题和全屏按钮
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Must-see before workout',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // 全屏按钮
                if (_isVideoInitialized)
                  GestureDetector(
                    onTap: _showFullscreenVideo,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 共享的播放/暂停控制方法
  void _toggleVideo() {
    if (_videoController == null || !_isVideoInitialized) return;
    
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }
    // 状态会通过监听器自动更新
  }

  void _showFullscreenVideo() {
    if (_videoController == null || !_isVideoInitialized) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenVideoPage(
          videoController: _videoController!,
          videoTitle: 'Must-see before workout',
          getVideoProgress: _getVideoProgress,
          formatDuration: _formatDuration,
          toggleVideo: _toggleVideo,
        ),
      ),
    );
  }

  double _getVideoProgress() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return 0.0;
    }
    final duration = _videoController!.value.duration;
    final position = _videoController!.value.position;
    return duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0.0;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _onTrainingTap(TrainingItem training) {
    // 从 ViewModel 获取 productId
    final viewModel = context.read<TrainingListViewModel>();
    final productId = viewModel.productId ?? '';
    
    // 导航到训练规则页面，传递 trainingId 和 productId
    Navigator.pushNamed(
      context,
      AppRoutes.trainingRule,
      arguments: {
        'trainingId': training.id,
        'productId': productId,
      },
    );
  }

  // 难度等级到颜色的映射（整型星级）
  Color _getLevelColorInt(int level) {
    if (level <= 2) return Colors.green;
    if (level <= 4) return Colors.orange;
    if (level <= 7) return Colors.red;
    return Colors.purple;
  }
}

// 训练卡片组件
class _TrainingCard extends StatelessWidget {
  final TrainingItem training;
  final Color levelColor;
  final VoidCallback onTap;

  const _TrainingCard({
    required this.training,
    required this.levelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
                          border: Border.all(
              color: levelColor.withOpacity(0.1),
              width: 1,
            ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题和难度
                      Row(
                        children: [
                          Expanded(
                            child:                             Text(
                              training.name,
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          _LevelStars(level: training.level, color: levelColor),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 参与人数和完成率
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.people,
                            label: '${training.participantCount}',
                            subtitle: 'Joined',
                            color: levelColor,
                          ),
                          const SizedBox(width: 12),
                          // 移除完成率展示
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 描述
                      Text(
                        training.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 开始按钮
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              levelColor,
                              levelColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: levelColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Start Training',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelStars extends StatelessWidget {
  final int level; // 1-10
  final Color color;

  const _LevelStars({required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    final int clamped = level.clamp(1, 10);
    final int fullStars = clamped >= 5 ? 5 : clamped; // 显示最多5个星图标
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < 5; i++)
            Icon(
              i < fullStars ? Icons.star : Icons.star_border,
              size: 14,
              color: color,
            ),
          const SizedBox(width: 6),
          Text(
            'Lv $clamped',
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// 信息标签组件
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
                size: 16,
            color: color,
          ),
              const SizedBox(width: 6),
          Text(
            label,
                style: AppTextStyles.labelMedium.copyWith(
              color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTextStyles.labelSmall.copyWith(
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w500,
            ),
          ),
          ],
        ],
      ),
    );
  }
}

// 全屏视频播放页面
class _FullscreenVideoPage extends StatefulWidget {
  final VideoPlayerController videoController;
  final String videoTitle;
  final double Function() getVideoProgress;
  final String Function(Duration) formatDuration;
  final VoidCallback toggleVideo;

  const _FullscreenVideoPage({
    Key? key,
    required this.videoController,
    required this.videoTitle,
    required this.getVideoProgress,
    required this.formatDuration,
    required this.toggleVideo,
  }) : super(key: key);

  @override
  State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    // 初始化播放状态
    _isVideoPlaying = widget.videoController.value.isPlaying;
    // 添加监听器来更新播放状态
    widget.videoController.addListener(_onVideoStateChanged);
  }

  @override
  void dispose() {
    widget.videoController.removeListener(_onVideoStateChanged);
    super.dispose();
  }

  void _onVideoStateChanged() {
    if (mounted) {
      setState(() {
        _isVideoPlaying = widget.videoController.value.isPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 全屏视频播放器
            Center(
              child: AspectRatio(
                aspectRatio: widget.videoController.value.aspectRatio,
                child: VideoPlayer(widget.videoController),
              ),
            ),
            // 顶部控制栏
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.videoTitle,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 中间播放/暂停按钮
            Center(
              child: GestureDetector(
                onTap: widget.toggleVideo,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(_isVideoPlaying ? 0.2 : 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                    color: _isVideoPlaying ? Colors.white : Colors.black,
                    size: 36,
                  ),
                ),
              ),
            ),
            // 底部控制栏
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 进度条
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: widget.getVideoProgress(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 时间显示
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${widget.formatDuration(widget.videoController.value.position)} / ${widget.formatDuration(widget.videoController.value.duration)}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // 退出全屏按钮
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.fullscreen_exit,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
