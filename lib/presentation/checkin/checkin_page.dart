import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:math';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../widgets/floating_logo.dart';
import '../../widgets/elegant_refresh_button.dart';

import '../../routes/app_routes.dart';
import '../../domain/entities/checkin_product.dart';
import '../../domain/services/checkin_service.dart';
import '../../domain/usecases/get_checkin_products_usecase.dart';
import '../../data/api/checkin_api.dart';
import '../../data/repository/checkin_repository.dart';
import '../../core/page_visibility_manager.dart';
import 'checkin_viewmodel.dart';

// 移除旧的ProductCheckin类，使用CheckinProduct实体

class CheckinPage extends StatelessWidget {
  const CheckinPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CheckinViewModel(
        GetCheckinProductsUseCase(
          CheckinRepository(CheckinApi()),
          CheckinService(),
        ),
      )..loadCheckinProducts(page: 1, size: 10), // Initial load with pagination
      child: const _CheckinPageContent(),
    );
  }
}

class _CheckinPageContent extends StatefulWidget {
  const _CheckinPageContent({Key? key}) : super(key: key);

  @override
  State<_CheckinPageContent> createState() => _CheckinPageContentState();
}

class _CheckinPageContentState extends State<_CheckinPageContent> 
    with SingleTickerProviderStateMixin, PageVisibilityMixin {
  late final PageController _pageController = PageController(viewportFraction: 0.78);
  late final AnimationController _videoSwitchAnim;
  bool _isSwitchingVideo = false;
  
  // 🎯 核心优化：使用 Map 管理控制器，只保留必要的
  final Map<int, VideoPlayerController> _videoControllers = {};
  int _currentIndex = 0;
  static const int _preloadRange = 2; // 前后各预加载2个
  
  // 🎯 共享的默认视频控制器，避免重复创建
  VideoPlayerController? _defaultVideoController;

  @override
  int get pageIndex => 2; // Checkin页面的索引

  @override
  void restoreVideoPlayback() {
    super.restoreVideoPlayback();
    print('🎯 CheckinPage: Restoring video playback for index $lastVideoIndex');
    
    // 恢复播放对应索引的视频
    final controller = _videoControllers[lastVideoIndex];
    if (controller != null && controller.value.isInitialized) {
      controller.play();
      print('🎯 CheckinPage: Resumed video playback for index $lastVideoIndex');
    } else if (_defaultVideoController != null && _defaultVideoController!.value.isInitialized) {
      _defaultVideoController!.play();
      print('🎯 CheckinPage: Resumed default video playback');
    }
  }

  @override
  void pauseVideoAndSaveState() {
    super.pauseVideoAndSaveState();
    print('🎯 CheckinPage: Pausing video and saving state');
    
    // 暂停所有视频
    _videoControllers.forEach((index, controller) {
      if (controller.value.isInitialized) {
        controller.pause();
        print('🎯 CheckinPage: Paused video for index $index');
      }
    });
    
    // 暂停默认视频
    if (_defaultVideoController != null && _defaultVideoController!.value.isInitialized) {
      _defaultVideoController!.pause();
      print('🎯 CheckinPage: Paused default video');
    }
  }

  @override
  void initState() {
    super.initState();
    _videoSwitchAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  /// 🎯 核心方法：智能管理视频控制器
  void _manageVideoControllers(List<CheckinProduct> products, int currentIndex) {
    // 🎯 安全检查：确保索引不超出范围
    if (products.isEmpty || currentIndex < 0 || currentIndex >= products.length) {
      return;
    }
    
    final Set<int> neededIndices = _getNeededIndices(currentIndex, products.length);
    final Set<int> currentIndices = _videoControllers.keys.toSet();
    
    // 释放不需要的控制器（超出前后2页范围的）
    for (final index in currentIndices) {
      if (!neededIndices.contains(index)) {
        _disposeController(index);
      }
    }
    
    // 初始化需要的控制器（只初始化未加载的）
    for (final index in neededIndices) {
      if (!_videoControllers.containsKey(index) && index < products.length) {
        _initializeController(index, products[index]);
      }
    }
  }
  
  /// 计算需要预加载的索引范围
  Set<int> _getNeededIndices(int currentIndex, int totalCount) {
    final Set<int> indices = {currentIndex};
    
    // 🎯 安全检查：确保totalCount有效
    if (totalCount <= 0) return indices;
    
    // 前后各预加载_preloadRange个
    for (int i = 1; i <= _preloadRange; i++) {
      if (currentIndex - i >= 0) indices.add(currentIndex - i);
      if (currentIndex + i < totalCount) indices.add(currentIndex + i);
    }
    
    return indices;
  }
  
  /// 释放指定索引的控制器
  void _disposeController(int index) {
    final controller = _videoControllers.remove(index);
    if (controller != null) {
      // 🎯 如果是共享的默认视频控制器，不暂停也不释放，让它继续播放
      if (controller == _defaultVideoController) {
        print('🎯 Keeping default video playing (not paused, not disposed)');
      } else {
        // 🎯 其他控制器正常释放
        controller.pause();
        controller.dispose();
        print('🎯 Disposed video controller for index: $index');
      }
    }
  }
  
  /// 初始化单个视频控制器
  void _initializeController(int index, CheckinProduct product) {
    if (_videoControllers.containsKey(index)) return;
    
    // 🎯 先创建占位控制器，显示默认视频
    _createPlaceholderController(index);
    
    try {
      // 🎯 只有网络视频存在且URL有效时才尝试加载
      if (product.hasCustomVideo && product.videoUrl != null && product.videoUrl!.isNotEmpty) {
        print('🎯 Attempting to load network video for index: $index');
        
        // 网络视频优先
        final controller = VideoPlayerController.networkUrl(Uri.parse(product.videoUrl!));
        controller.setLooping(true);
        controller.setVolume(0);
        
        controller.initialize().then((_) {
          if (mounted) {
            print('✅ Network video loaded successfully for index: $index');
            // 🎯 只有网络视频加载成功才替换占位控制器
            _replacePlaceholderWithRealController(index, controller);
            if (index == _currentIndex) {
              controller.play();
              print('🎯 After replacement: controller.isPlaying=${controller.value.isPlaying}');
            }
            setState(() {});
          }
        }).catchError((error) {
          print('❌ Network video initialization failed for index $index: $error');
          // 🎯 网络视频失败，保持使用默认视频，不替换
          print('🔄 Keeping default video for index: $index due to network failure');
        });
      } else {
        // 🎯 没有网络视频或URL无效，保持使用默认视频
        print('🎯 No network video available for index: $index, keeping default video');
        // 不需要做任何替换，继续使用默认视频
      }
      
      print('✅ Initialization process completed for index: $index');
      
    } catch (e) {
      print('❌ Error in initialization process for index $index: $e');
      // 🎯 发生异常时，保持使用默认视频
      print('🔄 Keeping default video for index: $index due to error');
    }
  }
  
  /// 🎯 创建占位控制器，显示默认视频
  void _createPlaceholderController(int index) {
    // 确保默认视频控制器已初始化
    if (_defaultVideoController == null) {
      _defaultVideoController = VideoPlayerController.asset('assets/video/video1.mp4')
        ..setLooping(true)
        ..setVolume(0);
      
      _defaultVideoController!.initialize().then((_) {
        if (mounted) {
          setState(() {});
          // 🎯 默认视频初始化成功后，如果是当前页则开始播放
          if (index == _currentIndex) {
            _defaultVideoController!.play();
            print('🎯 Started playing default video for current index: $index');
          }
        }
      });
    } else {
      // 🎯 如果默认视频控制器已存在且已初始化，立即播放
      if (_defaultVideoController!.value.isInitialized && index == _currentIndex) {
        _defaultVideoController!.play();
        print('🎯 Started playing existing default video for current index: $index');
      }
    }
    
    // 使用默认视频控制器作为占位
    _videoControllers[index] = _defaultVideoController!;
    print('🎯 Created placeholder controller for index: $index using default video');
  }
  
  /// 🎯 用真实控制器替换占位控制器
  void _replacePlaceholderWithRealController(int index, VideoPlayerController realController) {
    final oldController = _videoControllers[index];
    
    // 如果旧控制器是占位控制器，不需要释放（因为它是共享的）
    if (oldController == _defaultVideoController) {
      // 🎯 不暂停默认视频，让它继续播放供其他索引使用
      print('🔄 Keeping default video playing for other indices');
    } else {
      oldController?.pause();
      oldController?.dispose();
    }
    
    _videoControllers[index] = realController;
    print('🔄 Replaced placeholder with real controller for index: $index');
  }

  @override
  void dispose() {
    // 🎯 清理所有控制器
    _videoControllers.values.forEach((controller) {
      // 跳过共享的默认视频控制器，避免重复释放
      if (controller != _defaultVideoController) {
        controller.pause();
        controller.dispose();
      }
    });
    _videoControllers.clear();
    
    // 🎯 释放共享的默认视频控制器
    if (_defaultVideoController != null) {
      _defaultVideoController!.pause();
      _defaultVideoController!.dispose();
      _defaultVideoController = null;
    }
    
    _pageController.dispose();
    _videoSwitchAnim.dispose();
    super.dispose();
  }

  void _onProductTap(CheckinProduct product) {
    Navigator.pushNamed(
        context,
        AppRoutes.trainingList,
        arguments: {'productId': product.id},
    );
  }

  /// 优化的页面切换处理
  void _onPageChanged(int index) {
    final viewModel = context.read<CheckinViewModel>();
    viewModel.updateCurrentIndex(index);
    
    // 更新当前索引
    _currentIndex = index;
    
    // 🎯 更新页面可见性管理器中的视频索引
    updateCurrentVideoIndex(index);
    
    // 🎯 检查是否是刷新按钮页面（最后一个页面）
    final bool isRefreshPage = index == viewModel.products.length;
    
    if (isRefreshPage) {
      // 🎯 刷新按钮页面：使用默认视频
      _ensureDefaultVideoPlaying();
    } else {
      // 🎯 正常产品页面：管理视频控制器
      if (viewModel.products.isNotEmpty && index < viewModel.products.length) {
        _manageVideoControllers(viewModel.products, index);
      }
    }
    
    // 播放当前视频，暂停其他视频
    _videoControllers.forEach((controllerIndex, controller) {
      if (controllerIndex == index) {
        // 🎯 当前页面：确保播放
        if (controller.value.isInitialized) {
          controller.play();
          print('🎯 Playing real video for index: $index');
          print('🎯 Video controller state: isPlaying=${controller.value.isPlaying}, isInitialized=${controller.value.isInitialized}');
        } else if (controller == _defaultVideoController) {
          // 🎯 如果是默认视频控制器且未初始化，确保播放
          if (_defaultVideoController!.value.isInitialized) {
            _defaultVideoController!.play();
            print('🎯 Playing default video for index: $index');
          }
        }
      } else {
        // 🎯 其他页面：暂停非默认视频，保持默认视频播放
        if (controller != _defaultVideoController) {
          controller.pause();
          print('🎯 Paused video for index: $controllerIndex (not current)');
        }
      }
    });
  }
  
  /// 🎯 确保默认视频播放（用于刷新按钮页面或无产品数据时）
  void _ensureDefaultVideoPlaying() {
    // 确保默认视频控制器已初始化
    if (_defaultVideoController == null) {
      _defaultVideoController = VideoPlayerController.asset('assets/video/video1.mp4')
        ..setLooping(true)
        ..setVolume(0);
      
      _defaultVideoController!.initialize().then((_) {
        if (mounted) {
          setState(() {});
          // 开始播放默认视频
          _defaultVideoController!.play();
          print('🎯 Started playing default video');
        }
      });
    } else if (_defaultVideoController!.value.isInitialized) {
      // 如果默认视频已初始化，直接播放
      _defaultVideoController!.play();
      print('🎯 Playing existing default video');
    }
    
    // 将默认视频控制器分配给当前索引（如果有的话）
    if (_currentIndex >= 0) {
      _videoControllers[_currentIndex] = _defaultVideoController!;
    }
  }

  /// 优化的视频背景栈
  Widget _buildVideoStack(List<CheckinProduct> products) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        final viewModel = context.watch<CheckinViewModel>();
        final page = _pageController.hasClients && _pageController.page != null
            ? _pageController.page!
            : viewModel.currentIndex.toDouble();

        List<Widget> stack = [];
        
        // 🎯 计算总页面数（包括刷新按钮页面）
        final int totalPages = products.length + 1;
        
        // 🎯 只渲染当前页和前后2页的视频
        for (int i = 0; i < totalPages; i++) {
          if ((i - page).abs() > 2.2) continue;
          
          final offset = (i - page) * MediaQuery.of(context).size.height;
          final opacity = (1.0 - (i - page).abs()).clamp(0.0, 1.0);
          
          final controller = _videoControllers[i];
          if (controller != null && controller.value.isInitialized) {
            stack.add(
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, offset),
                  child: Opacity(
                    opacity: opacity,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }
        
        // 🎯 如果当前是刷新按钮页面且没有视频，显示默认视频
        if (stack.isEmpty || (page >= products.length && _defaultVideoController != null && _defaultVideoController!.value.isInitialized)) {
          stack.add(
            Positioned.fill(
              child: _defaultVideoController != null && _defaultVideoController!.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _defaultVideoController!.value.size.width,
                      height: _defaultVideoController!.value.size.height,
                      child: VideoPlayer(_defaultVideoController!),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
            ),
          );
        }
        
        return Stack(children: stack);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckinViewModel>(
      builder: (context, viewModel, child) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth * 0.78; // 78% 屏幕宽度
    final double bottomPadding = MediaQuery.of(context).padding.bottom; //safty安全区高度 

        // 🎯 当产品列表更新时，重新管理控制器并确保前后2页预加载
        if (viewModel.products.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _manageVideoControllers(viewModel.products, _currentIndex);
            }
          });
        } else {
          // 🎯 当没有产品数据时，确保默认视频控制器被初始化和播放
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _ensureDefaultVideoPlaying();
            }
          });
        }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 全屏视频背景（TikTok风格上下滑动切换）
          if (viewModel.products.isNotEmpty)
            Positioned.fill(
              child: _buildVideoStack(viewModel.products),
            )
          else
            // 🎯 当没有产品数据时，显示默认视频
            Positioned.fill(
              child: _defaultVideoController != null && _defaultVideoController!.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _defaultVideoController!.value.size.width,
                      height: _defaultVideoController!.value.size.height,
                      child: VideoPlayer(_defaultVideoController!),
                    ),
                  )
                : Container(color: Colors.black),
            ),

          // 顶部状态栏毛玻璃
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top + 44, // 顶部+渐变高度
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.22), // 顶部较深
                    Color.fromRGBO(0, 0, 0, 0.10),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // 顶部悬浮Logo（黑色半透明背景+红色发光阴影）
          const FloatingLogo(),

              // 加载状态
              if (viewModel.isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),

          // 悬浮入口
              if (!viewModel.isLoading)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding + 64),  //底部安全区高度
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 新增 Checkinboard 入口
                  _CheckinboardEntry(
                    onTap: () {
                              Navigator.pushNamed(context, AppRoutes.checkinboard);
                    },
                  ),
                  // 产品卡片区域
                  SizedBox(
                    height: 200, // 推荐用固定高度，性能更优
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: viewModel.products.length + 1, // 添加1个用于刷新按钮
                      physics: const PageScrollPhysics(), // 强磁吸
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                        // 最后一个item显示为刷新按钮
                        if (index == viewModel.products.length) {
                          return AnimatedScale(
                            scale: viewModel.currentIndex == index ? 1.0 : 0.92,
                            duration: const Duration(milliseconds: 300),
                            child: ElegantRefreshButton(
                              onRefresh: () async {
                                // 🎯 显示加载状态
                                viewModel.refresh();
                                
                                // 🎯 等待数据刷新完成
                                await Future.delayed(const Duration(milliseconds: 800));
                                
                                // 🎯 刷新完成后回到第一页
                                if (mounted && _pageController.hasClients) {
                                  _pageController.animateToPage(
                                    0,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              size: 200,
                              refreshDuration: const Duration(milliseconds: 800),
                            ),
                          );
                        }
                        
                        return AnimatedScale(
                          scale: viewModel.currentIndex == index ? 1.0 : 0.92,
                          duration: const Duration(milliseconds: 300),
                          child: _ProductEntry(
                            product: viewModel.products[index],
                            onTap: () => _onProductTap(viewModel.products[index]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 底部指示器 - 包含刷新按钮的指示点
                  AnimatedSmoothIndicator(
                    activeIndex: viewModel.currentIndex,
                    count: viewModel.products.length + 1, // 更新指示器数量，包含刷新按钮
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: AppColors.primary,
                      dotColor: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
                ),
              ),
            ),
          ),
        ],
      ),
        );
      },
    );
  }
}

class PowerfulTapEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double pressedScale;
  final Duration pressDuration;
  final Duration reboundDuration;
  final Curve reboundCurve;

  const PowerfulTapEffect({
    required this.child,
    required this.onTap,
    this.pressedScale = 0.90,
    this.pressDuration = const Duration(milliseconds: 80),
    this.reboundDuration = const Duration(milliseconds: 320),
    this.reboundCurve = Curves.elasticOut,
    Key? key,
  }) : super(key: key);

  @override
  State<PowerfulTapEffect> createState() => _PowerfulTapEffectState();
}

class _PowerfulTapEffectState extends State<PowerfulTapEffect> {
  double _scale = 1.0;
  bool _isAnimating = false;

  Future<void> _handleTap() async {
    if (_isAnimating) return;
    if (mounted) {
      setState(() {
        _scale = widget.pressedScale;
        _isAnimating = true;
      });
    }
    await Future.delayed(widget.pressDuration);
    if (mounted) {
      setState(() {
        _scale = 1.0;
      });
    }
    await Future.delayed(widget.reboundDuration);
    if (mounted) {
      widget.onTap();
      setState(() {
        _isAnimating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.translucent,
      child: AnimatedScale(
        scale: _scale,
        duration: _scale < 1.0 ? widget.pressDuration : widget.reboundDuration,
        curve: _scale < 1.0 ? Curves.easeIn : widget.reboundCurve,
        child: widget.child,
      ),
    );
  }
}

class _ProductEntry extends StatefulWidget {
  final CheckinProduct product;
  final VoidCallback onTap;

  const _ProductEntry({required this.product, required this.onTap});

  @override
  State<_ProductEntry> createState() => _ProductEntryState();
}

class _ProductEntryState extends State<_ProductEntry> {
  double _scale = 1.0;

  void _onTap() {
    if (mounted) {
      setState(() => _scale = 0.97);
    }
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) {
        setState(() => _scale = 1.0);
        widget.onTap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 优化卡片外观
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: PowerfulTapEffect(
        onTap: _onTap,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            splashColor: AppColors.primary.withOpacity(0.08),
            highlightColor: AppColors.primary.withOpacity(0.10),
            onTap: _onTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.18),
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min, // 让内容自适应高度
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部小标签
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'CHECK-IN',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 主体内容
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            IconData(
                              int.parse(widget.product.displayIcon),
                              fontFamily: 'MaterialIcons',
                            ),
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.product.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.dark40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // 明确的操作按钮
                  Align(
                    alignment: Alignment.centerRight,
                    child: PowerfulTapEffect(
                      onTap: _onTap,
                      pressedScale: 0.90, // 力量感更强
                      pressDuration: Duration(milliseconds: 80),
                      reboundDuration: Duration(milliseconds: 320),
                      reboundCurve: Curves.elasticOut,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flash_on, size: 18, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'Start Training',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _AnimatedButton({required this.onPressed, required this.child});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  double _scale = 1.0;

  void _onTap() {
    if (mounted) {
      setState(() => _scale = 0.90);
    }
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) {
        setState(() => _scale = 1.0);
        widget.onPressed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 180),
        curve: Curves.elasticOut,
        child: widget.child,
      ),
    );
  }
}

// Checkinboard入口组件
class _CheckinboardEntry extends StatefulWidget {
  final VoidCallback onTap;
  const _CheckinboardEntry({required this.onTap});

  @override
  State<_CheckinboardEntry> createState() => _CheckinboardEntryState();
}

class _CheckinboardEntryState extends State<_CheckinboardEntry> {
  double _scale = 1.0;

  void _onTap() {
    if (mounted) {
      setState(() => _scale = 0.97);
    }
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) {
        setState(() => _scale = 1.0);
        widget.onTap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), // 推荐左右20，上下4
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18), // 上下10，左右18
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.13),
                    width: 1.1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Checkinboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.8), size: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
