import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:math' as math;
import '../../widgets/floating_logo.dart';
import '../../widgets/elegant_refresh_button.dart';

import '../../widgets/bonus_activity_detail_sheet.dart';
import '../../domain/entities/bonus_activity.dart';
import '../../domain/usecases/get_bonus_activities_usecase.dart';
import '../../domain/services/bonus_service.dart';
import '../../data/repository/bonus_repository.dart';
import '../../data/api/bonus_api.dart';
import '../../core/page_visibility_manager.dart';
import 'bonus_viewmodel.dart';

class BonusPage extends StatelessWidget {
  const BonusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BonusViewModel(
        getBonusActivitiesUseCase: GetBonusActivitiesUseCase(
          BonusRepository(BonusApi()),
        ),
        bonusService: BonusService(),
      )..loadBonusActivities(page: 1, size: 10),
      child: const _BonusPageContent(),
    );
  }
}

class _BonusPageContent extends StatefulWidget {
  const _BonusPageContent({Key? key}) : super(key: key);

  @override
  State<_BonusPageContent> createState() => _BonusPageContentState();
}

class _BonusPageContentState extends State<_BonusPageContent> 
    with SingleTickerProviderStateMixin, PageVisibilityMixin {
  late final PageController _pageController = PageController(viewportFraction: 0.78);
  
  // 🎯 核心优化：使用 Map 管理控制器，只保留必要的
  final Map<int, VideoPlayerController> _videoControllers = {};
  int _currentIndex = 0;
  static const int _preloadRange = 2; // 前后各预加载2个
  
  // 🎯 共享的默认视频控制器，避免重复创建
  VideoPlayerController? _defaultVideoController;

  @override
  int get pageIndex => 3; // Bonus页面的索引

  @override
  void restoreVideoPlayback() {
    super.restoreVideoPlayback();
    print('🎯 BonusPage: Restoring video playback for index $lastVideoIndex');
    
    // 恢复播放对应索引的视频
    final controller = _videoControllers[lastVideoIndex];
    if (controller != null && controller.value.isInitialized) {
      controller.play();
      print('🎯 BonusPage: Resumed video playback for index $lastVideoIndex');
    } else if (_defaultVideoController != null && _defaultVideoController!.value.isInitialized) {
      _defaultVideoController!.play();
      print('🎯 BonusPage: Resumed default video playback');
    }
  }

  @override
  void pauseVideoAndSaveState() {
    super.pauseVideoAndSaveState();
    print('🎯 BonusPage: Pausing video and saving state');
    
    // 暂停所有视频
    _videoControllers.forEach((index, controller) {
      if (controller.value.isInitialized) {
        controller.pause();
        print('🎯 BonusPage: Paused video for index $index');
      }
    });
    
    // 暂停默认视频
    if (_defaultVideoController != null && _defaultVideoController!.value.isInitialized) {
      _defaultVideoController!.pause();
      print('🎯 BonusPage: Paused default video');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  /// 🎯 核心方法：智能管理视频控制器
  void _manageVideoControllers(List<BonusActivity> activities, int currentIndex) {
    final Set<int> neededIndices = _getNeededIndices(currentIndex, activities.length);
    final Set<int> currentIndices = _videoControllers.keys.toSet();
    
    // 释放不需要的控制器（超出前后2页范围的）
    for (final index in currentIndices) {
      if (!neededIndices.contains(index)) {
        _disposeController(index);
      }
    }
    
    // 初始化需要的控制器（只初始化未加载的）
    for (final index in neededIndices) {
      if (!_videoControllers.containsKey(index)) {
        _initializeController(index, activities[index]);
      }
    }
  }
  
  /// 计算需要预加载的索引范围
  Set<int> _getNeededIndices(int currentIndex, int totalCount) {
    final Set<int> indices = {currentIndex};
    
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
        controller.pause();
        controller.dispose();
        print('🎯 Disposed video controller for index: $index');
      }
    }
  }
  
  /// 初始化单个视频控制器
  void _initializeController(int index, BonusActivity activity) {
    if (_videoControllers.containsKey(index)) return;
    
    // 🎯 先创建占位控制器，显示默认视频
    _createPlaceholderController(index);
    
    try {
      // 🎯 只有网络视频存在且URL有效时才尝试加载
      if (activity.videoUrl.isNotEmpty) {
        print('🎯 Attempting to load network video for index: $index');
        
        // 网络视频
        final controller = VideoPlayerController.networkUrl(Uri.parse(activity.videoUrl));
        controller.setLooping(true);
        controller.setVolume(0);
        
        controller.initialize().then((_) {
          if (mounted) {
            print('✅ Network video loaded successfully for index: $index');
            // 🎯 只有网络视频加载成功才替换占位控制器
            _replacePlaceholderWithRealController(index, controller);
            if (index == _currentIndex) {
              controller.play();
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
    super.dispose();
  }

  /// 优化的页面切换处理
  void _onPageChanged(int index) {
    final viewModel = context.read<BonusViewModel>();
    viewModel.setCurrentIndex(index);
    
    // 更新当前索引
    _currentIndex = index;
    
    // 🎯 更新页面可见性管理器中的视频索引
    updateCurrentVideoIndex(index);
    
    // 🎯 检查是否是刷新按钮页面（最后一个页面）
    final activities = viewModel.filteredActivities;
    final bool isRefreshPage = index == activities.length;
    
    if (isRefreshPage) {
      // 🎯 刷新按钮页面：使用默认视频
      _ensureDefaultVideoPlaying();
    } else {
      // 🎯 正常活动页面：管理视频控制器
      if (activities.isNotEmpty && index < activities.length) {
        _manageVideoControllers(activities, index);
      }
    }
    
    // 播放当前视频，暂停其他视频
    _videoControllers.forEach((controllerIndex, controller) {
      if (controllerIndex == index) {
        if (controller.value.isInitialized) {
          controller.play();
          print('🎯 Playing real video for index: $index');
        } else if (controller == _defaultVideoController) {
          // 🎯 如果是默认视频控制器且未初始化，确保播放
          if (_defaultVideoController!.value.isInitialized) {
            _defaultVideoController!.play();
            print('🎯 Playing default video for index: $index');
          }
        }
      } else {
        // 🎯 不暂停默认视频控制器，让它继续播放
        if (controller != _defaultVideoController) {
          controller.pause();
        }
      }
    });
  }
  
  /// 🎯 确保默认视频播放（用于刷新按钮页面或无活动数据时）
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
  Widget _buildVideoStack() {
    final viewModel = context.read<BonusViewModel>();
    final activities = viewModel.filteredActivities;
    
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        final page = _pageController.hasClients && _pageController.page != null
            ? _pageController.page!
            : viewModel.currentIndex.toDouble();
        
        List<Widget> stack = [];
        
        // 🎯 计算总页面数（包括刷新按钮页面）
        final int totalPages = activities.length + 1;
        
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
        if (stack.isEmpty || (page >= activities.length && _defaultVideoController != null && _defaultVideoController!.value.isInitialized)) {
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
        
        // 顶部渐变遮罩，提升可读性
        stack.add(Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(0, 0, 0, 0.32),
                  Color.fromRGBO(0, 0, 0, 0.10),
                  Colors.transparent,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ));
        
        return Stack(children: stack);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth * 0.78;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Consumer<BonusViewModel>(
      builder: (context, viewModel, child) {
        // 🎯 当活动列表更新时，重新管理控制器并确保前后2页预加载
        if (viewModel.filteredActivities.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _manageVideoControllers(viewModel.filteredActivities, _currentIndex);
            }
          });
        } else {
          // 🎯 当没有活动数据时，确保默认视频控制器被初始化和播放
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
              // 全屏视频背景
              if (viewModel.filteredActivities.isNotEmpty)
                Positioned.fill(
                  child: _buildVideoStack(),
                )
              else
                // 🎯 当没有活动数据时，显示默认视频
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
              
              // 顶部毛玻璃渐变遮罩
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).padding.top + 44,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(0, 0, 0, 0.22),
                        Color.fromRGBO(0, 0, 0, 0.10),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              
              // 顶部悬浮LOGO
              const FloatingLogo(),

              // 加载状态
              if (viewModel.isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),

          // 底部卡片轮播
          if (!viewModel.isLoading)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding + 64),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 活动卡片区域
                      Container(
                        constraints: BoxConstraints(
                          minHeight: math.min(200, MediaQuery.of(context).size.height * 0.28),
                          maxHeight: math.max(200, MediaQuery.of(context).size.height * 0.28),
                        ),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: viewModel.filteredActivities.length + 1, // 添加1个用于刷新按钮
                          physics: const PageScrollPhysics(),
                          onPageChanged: _onPageChanged,
                          itemBuilder: (context, index) {
                            // 最后一个item显示为刷新按钮
                            if (index == viewModel.filteredActivities.length) {
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
                            
                            final activity = viewModel.filteredActivities[index];
                            return AnimatedScale(
                              scale: viewModel.currentIndex == index ? 1.0 : 0.92,
                              duration: const Duration(milliseconds: 300),
                              child: _BonusCard(
                                activity: activity,
                                onTap: () {
                                  // 🎯 显示活动详情底部弹窗
                                  BonusActivityDetailSheet.show(
                                    context,
                                    activity: activity,
                                  );
                                },
                                index: index,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 底部指示器 - 包含刷新按钮的指示点
                      AnimatedSmoothIndicator(
                        activeIndex: viewModel.currentIndex,
                        count: viewModel.filteredActivities.length + 1, // 更新指示器数量，包含刷新按钮
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

class _BonusCard extends StatefulWidget {
  final BonusActivity activity;
  final VoidCallback onTap;
  final int index;
  
  const _BonusCard({
    required this.activity, 
    required this.onTap, 
    required this.index,
  });

  @override
  State<_BonusCard> createState() => _BonusCardState();
}

class _BonusCardState extends State<_BonusCard> {
  double _scale = 1.0;

  /// 🎯 获取创意提示文字
  String _getCreativeHint() {
    final hints = [
      '🎁 Tap for surprise!',
      '💎 Discover more!',
      '✨ Magic awaits!',
      '🚀 Ready to explore?',
      '🎯 Hit it!',
      '💫 Tap & see!',
      '🎪 Show time!',
      '🌟 Let\'s go!',
      '🎨 Peek inside!',
      '🎭 Curtain up!',
      '🎪 Ring the bell!',
      '🎯 Bullseye!',
      '💎 Diamond hands!',
      '🚀 To the moon!',
      '🎁 Unwrap it!',
    ];
    
    // 根据卡片索引选择不同的提示，增加趣味性
    return hints[widget.index % hints.length];
  }

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
    final List<List<Color>> cardGradients = [
      [Color(0xFF6EE7B7), Color(0xFF3B82F6)], // 青绿-蓝
      [Color(0xFFFFA5EC), Color(0xFF7F53AC)], // 粉-紫
      [Color(0xFFFFD6A5), Color(0xFFFF6F61)], // 橙-红
      [Color(0xFFB2FEFA), Color(0xFF0ED2F7)], // 青-蓝
      [Color(0xFFFFE29F), Color(0xFFFFA07A)], // 黄-橙
    ];
    
    final gradient = cardGradients[widget.index % cardGradients.length];
    
    // 自动选择主色或黑色，提升对比度
    Color _autoTextColor(Color bg) {
      return bg.computeLuminance() > 0.5 ? AppColors.primary : Colors.black87;
    }
    
    final mainTextColor = _autoTextColor(gradient.last);
    
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTap: _onTap,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient.map((c) => c.withOpacity(0.85)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradient.last.withOpacity(0.13),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: gradient.last.withOpacity(0.15),
                width: 1.1,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 活动名
                Flexible(
                  child: Text(
                    widget.activity.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: mainTextColor,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // 描述
                Flexible(
                  child: Text(
                    widget.activity.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: mainTextColor.withOpacity(0.82),
                      fontWeight: FontWeight.w500,
                      height: 1.3, // 优化行高
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 奖励
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: gradient.last.withOpacity(0.13),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.card_giftcard, size: 15, color: gradient.last),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.activity.reward,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: mainTextColor,
                              fontWeight: FontWeight.w600,
                              height: 1.2, // 优化行高，避免文字过于紧凑
                              fontSize: 13, // 稍微减小字体大小，确保两行显示
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // 限制区域
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.public, size: 13, color: gradient.last),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.activity.regionLimit.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: mainTextColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // 底部提示
                Flexible(
                  child: Center(
                    child: Text(
                      _getCreativeHint(),
                      style: AppTextStyles.labelLarge.copyWith(
                        color: mainTextColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


