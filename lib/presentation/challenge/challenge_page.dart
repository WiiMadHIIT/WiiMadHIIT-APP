// 引入所需的包
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../routes/app_routes.dart';
import '../leaderboard/leaderboard_page.dart';
import '../../widgets/floating_logo.dart';

import '../../widgets/elegant_refresh_button.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/services/challenge_service.dart';
import '../../domain/usecases/get_challenges_usecase.dart';
import '../../data/api/challenge_api.dart';
import '../../data/repository/challenge_repository.dart';
import '../../core/page_visibility_manager.dart';
import 'challenge_viewmodel.dart';

/// 挑战主页面，包含顶部LOGO、视频背景、底部滑动卡片等
class ChallengePage extends StatelessWidget {
  const ChallengePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChallengeViewModel(
        GetChallengesUseCase(
          ChallengeRepository(ChallengeApi()),
          ChallengeService(),
        ),
      )..loadChallenges(page: 1, size: 10), // Initial load with pagination
      child: const _ChallengePageContent(),
    );
  }
}

class _ChallengePageContent extends StatefulWidget {
  const _ChallengePageContent({Key? key}) : super(key: key);

  @override
  State<_ChallengePageContent> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<_ChallengePageContent> 
    with SingleTickerProviderStateMixin, PageVisibilityMixin {
  late final PageController _pageController = PageController(viewportFraction: 0.78); // 卡片滑动控制器
  late final AnimationController _videoSwitchAnim;
  bool _isSwitchingVideo = false;
  
  // 🎯 核心优化：使用 Map 管理控制器，只保留必要的
  final Map<int, VideoPlayerController> _videoControllers = {};
  int _currentIndex = 0;
  static const int _preloadRange = 2; // 前后各预加载2个
  
  // 🎯 共享的默认视频控制器，避免重复创建
  VideoPlayerController? _defaultVideoController;

  @override
  int get pageIndex => 1; // Challenge页面的索引

  @override
  void restoreVideoPlayback() {
    super.restoreVideoPlayback();
    print('🎯 ChallengePage: Restoring video playback for index $lastVideoIndex');
    
    // 恢复播放对应索引的视频
    final controller = _videoControllers[lastVideoIndex];
    if (controller != null && controller.value.isInitialized) {
      controller.play();
      print('🎯 ChallengePage: Resumed video playback for index $lastVideoIndex');
    } else if (_defaultVideoController != null && _defaultVideoController!.value.isInitialized) {
      _defaultVideoController!.play();
      print('🎯 ChallengePage: Resumed default video playback');
    }
  }

  @override
  void pauseVideoAndSaveState() {
    super.pauseVideoAndSaveState();
    print('🎯 ChallengePage: Pausing video and saving state');
    
    // 暂停所有视频
    _videoControllers.forEach((index, controller) {
      if (controller.value.isInitialized) {
        controller.pause();
        print('🎯 ChallengePage: Paused video for index $index');
      }
    });
    
    // 暂停默认视频
    if (_defaultVideoController != null && _defaultVideoController!.value.isInitialized) {
      _defaultVideoController!.pause();
      print('🎯 ChallengePage: Paused default video');
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
  void _manageVideoControllers(List<Challenge> challenges, int currentIndex) {
    // 🎯 安全检查：确保索引不超出范围
    if (challenges.isEmpty || currentIndex < 0 || currentIndex >= challenges.length) {
      return;
    }
    
    final Set<int> neededIndices = _getNeededIndices(currentIndex, challenges.length);
    final Set<int> currentIndices = _videoControllers.keys.toSet();
    
    // 释放不需要的控制器（超出前后2页范围的）
    for (final index in currentIndices) {
      if (!neededIndices.contains(index)) {
        _disposeController(index);
      }
    }
    
    // 初始化需要的控制器（只初始化未加载的）
    for (final index in neededIndices) {
      if (!_videoControllers.containsKey(index) && index < challenges.length) {
        _initializeController(index, challenges[index]);
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
  void _initializeController(int index, Challenge challenge) {
    if (_videoControllers.containsKey(index)) return;
    
    // 🎯 先创建占位控制器，显示默认视频
    _createPlaceholderController(index);
    
    try {
      // 🎯 只有网络视频存在且URL有效时才尝试加载
      if (challenge.hasVideo && challenge.videoUrl != null && challenge.videoUrl!.isNotEmpty) {
        print('🎯 Attempting to load network video for index: $index');
        
        // 网络视频优先
        final controller = VideoPlayerController.networkUrl(Uri.parse(challenge.videoUrl!));
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

  /// 点击挑战卡片时的跳转逻辑
  void _onChallengeTap(Challenge challenge) {
    Navigator.pushNamed(
      context,
      AppRoutes.challengeDetails,
      arguments: {'challengeId': challenge.id},
    );
  }

  /// 优化的页面切换处理
  void _onPageChanged(int index) {
    final viewModel = context.read<ChallengeViewModel>();
    viewModel.updateCurrentIndex(index);
    
    // 更新当前索引
    _currentIndex = index;
    
    // 🎯 更新页面可见性管理器中的视频索引
    updateCurrentVideoIndex(index);
    
    // 🎯 检查是否是刷新按钮页面（最后一个页面）
    final bool isRefreshPage = index == viewModel.filteredChallenges.length;
    
    if (isRefreshPage) {
      // 🎯 刷新按钮页面：使用默认视频
      _ensureDefaultVideoPlaying();
    } else {
      // 🎯 正常挑战页面：管理视频控制器
      if (viewModel.challenges.isNotEmpty && index < viewModel.challenges.length) {
        _manageVideoControllers(viewModel.challenges, index);
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
  
  /// 🎯 确保默认视频播放（用于刷新按钮页面或无挑战数据时）
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

  /// 显示底部筛选菜单
  void _showFilterSheet(BuildContext context, ChallengeViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.96),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterOption(context, viewModel, null, 'All'),
                const SizedBox(height: 8),
                _buildFilterOption(context, viewModel, 'ongoing', 'Ongoing'),
                const SizedBox(height: 8),
                _buildFilterOption(context, viewModel, 'upcoming', 'Upcoming'),
                const SizedBox(height: 8),
                _buildFilterOption(context, viewModel, 'ended', 'Ended'),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建筛选选项
  Widget _buildFilterOption(BuildContext context, ChallengeViewModel viewModel, String? status, String label) {
    final bool selected = viewModel.currentFilter == status;
    return GestureDetector(
      onTap: () {
        viewModel.filterChallengesByStatus(status);
        
        // 筛选后跳转到第一页
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              status == null
                ? Icons.all_inclusive
                : status == 'ongoing'
                  ? Icons.flash_on
                  : status == 'upcoming'
                    ? Icons.schedule
                    : Icons.emoji_events,
              color: selected ? AppColors.primary : Colors.grey[500],
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTextStyles.titleLarge.copyWith(
                color: selected ? AppColors.primary : Colors.black87,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (selected)
              const Spacer(),
            if (selected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }

  /// 优化的视频背景栈
  Widget _buildVideoStack(List<Challenge> challenges) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        final viewModel = context.watch<ChallengeViewModel>();
        final page = _pageController.hasClients && _pageController.page != null
            ? _pageController.page!
            : viewModel.currentIndex.toDouble();

        List<Widget> stack = [];
        
        // 🎯 计算总页面数（包括刷新按钮页面）
        final int totalPages = challenges.length + 1;
        
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
        if (stack.isEmpty || (page >= challenges.length && _defaultVideoController != null && _defaultVideoController!.value.isInitialized)) {
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
    return Consumer<ChallengeViewModel>(
      builder: (context, viewModel, child) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double bottomPadding = MediaQuery.of(context).padding.bottom;
        
        // 🎯 当挑战列表更新时，重新管理控制器并确保前后2页预加载
        if (viewModel.challenges.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _manageVideoControllers(viewModel.challenges, _currentIndex);
            }
          });
        } else {
          // 🎯 当没有挑战数据时，确保默认视频控制器被初始化和播放
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
              if (viewModel.challenges.isNotEmpty)
                Positioned.fill(
                  child: _buildVideoStack(viewModel.challenges),
                )
              else
                // 🎯 当没有挑战数据时，显示默认视频
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

              // 底部滑动卡片区
              if (!viewModel.isLoading)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding + 64),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 240,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: viewModel.filteredChallenges.length + 1, // 添加1个用于刷新按钮
                            physics: const PageScrollPhysics(),
                            onPageChanged: _onPageChanged,
                            itemBuilder: (context, index) {
                              // 最后一个item显示为刷新按钮
                              if (index == viewModel.filteredChallenges.length) {
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
                                child: _ChallengeEntry(
                                  challenge: viewModel.filteredChallenges[index],
                                  onTap: () => _onChallengeTap(viewModel.filteredChallenges[index]),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 底部指示器 - 包含刷新按钮的指示点
                        AnimatedSmoothIndicator(
                          activeIndex: viewModel.currentIndex,
                          count: viewModel.filteredChallenges.length + 1, // 更新指示器数量
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
              
              // 悬浮筛选按钮和排行榜按钮
              if (!viewModel.isLoading)
                Positioned(
                  right: 16,
                  bottom: bottomPadding + 24,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LeaderboardFab(onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LeaderboardPage()),
                        );
                      }),
                      const SizedBox(width: 16),
                      _FilterFab(
                        onTap: () => _showFilterSheet(context, viewModel),
                        currentFilter: viewModel.currentFilter,
                      ),
                    ],
                  ),
                ),
              

            ],
          ),
        );
      },
    );
  }
}

/// TikTok风格悬浮筛选按钮
class _FilterFab extends StatelessWidget {
  final VoidCallback onTap;
  final String? currentFilter;
  const _FilterFab({required this.onTap, required this.currentFilter});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withOpacity(0.18),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 2),
            Text(
              'Filter',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.2,
              ),
            ),
            if (currentFilter != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.circle,
                  color: AppColors.primary,
                  size: 8,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 新增排行榜按钮组件
class _LeaderboardFab extends StatelessWidget {
  final VoidCallback onTap;
  const _LeaderboardFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withOpacity(0.18),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.leaderboard,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 2),
            Text(
              'Rank',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 按压动效组件，点击时有缩放反馈
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

/// 单个挑战卡片组件，根据不同状态显示不同样式
class _ChallengeEntry extends StatefulWidget {
  final Challenge challenge;
  final VoidCallback onTap;

  const _ChallengeEntry({required this.challenge, required this.onTap});

  @override
  State<_ChallengeEntry> createState() => _ChallengeEntryState();
}

class _ChallengeEntryState extends State<_ChallengeEntry> {
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

  /// Get status color
  Color _getStatusColor() {
    switch (widget.challenge.statusEnum) {
      case ChallengeStatus.ongoing:
        return const Color(0xFF00C851); // Green - Ongoing
      case ChallengeStatus.ended:
        return const Color(0xFF6C757D); // Gray - Ended
      case ChallengeStatus.upcoming:
        return const Color(0xFFFF6B35); // Orange - Upcoming
    }
  }

  /// Get status label (English)
  String _getStatusText() {
    return widget.challenge.statusText;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    
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
            splashColor: statusColor.withOpacity(0.08),
            highlightColor: statusColor.withOpacity(0.10),
            onTap: _onTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: statusColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top status bar
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getStatusText(),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Challenge name
                  Text(
                    widget.challenge.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Reward info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withOpacity(0.1),
                          statusColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.challenge.reward,
                            maxLines: 1,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Description info
                  if (widget.challenge.hasDescription)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
                      child: Text(
                        widget.challenge.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Bottom info bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // End time
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.challenge.timeRemainingText,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Action button
                      ElevatedButton.icon(
                        onPressed: widget.onTap,
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white),
                        label: const Text('Explore', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          textStyle: const TextStyle(fontSize: 14, letterSpacing: 0.2),
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
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

/// 按钮缩放动画组件
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




