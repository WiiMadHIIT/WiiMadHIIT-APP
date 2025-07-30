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
import '../../domain/entities/bonus_activity.dart';
import '../../domain/usecases/get_bonus_activities_usecase.dart';
import '../../domain/usecases/claim_bonus_usecase.dart';
import '../../domain/services/bonus_service.dart';
import '../../data/repository/bonus_repository.dart';
import '../../data/api/bonus_api.dart';
import 'bonus_viewmodel.dart';

class BonusPage extends StatelessWidget {
  const BonusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BonusViewModel(
        getBonusActivitiesUseCase: GetBonusActivitiesUseCase(
          BonusRepository(BonusApi()),
        ),
        claimBonusUseCase: ClaimBonusUseCase(
          BonusRepository(BonusApi()),
        ),
        bonusService: BonusService(),
      )..loadBonusActivities(),
      child: Consumer<BonusViewModel>(
        builder: (context, viewModel, _) {
          // 错误处理
          if (viewModel.hasError) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Error: ${viewModel.error}',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.refresh(),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 加载中
          if (viewModel.isLoading) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          }

          // 没有数据
          if (!viewModel.hasActivities) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'No bonus activities available',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.refresh(),
                      child: Text('Refresh'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 正常显示
          return _BonusPageContent(viewModel: viewModel);
        },
      ),
    );
  }
}

class _BonusPageContent extends StatefulWidget {
  final BonusViewModel viewModel;

  const _BonusPageContent({required this.viewModel});

  @override
  State<_BonusPageContent> createState() => _BonusPageContentState();
}

class _BonusPageContentState extends State<_BonusPageContent> with SingleTickerProviderStateMixin {
  late final PageController _pageController = PageController(viewportFraction: 0.78);
  late final List<VideoPlayerController> _videoControllers;

  @override
  void initState() {
    super.initState();
    _initializeVideoControllers();
  }

  void _initializeVideoControllers() {
    final activities = widget.viewModel.filteredActivities;
    _videoControllers = List.generate(activities.length, (i) {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(activities[i].videoUrl),
      )..setLooping(true)
        ..setVolume(0);
      
      controller.initialize().then((_) {
        if (i == 0) controller.play();
        if (mounted) setState(() {});
      });
      
      return controller;
    });
  }

  @override
  void dispose() {
    for (final c in _videoControllers) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    widget.viewModel.setCurrentIndex(index);
    
    // 控制视频播放
    for (int i = 0; i < _videoControllers.length; i++) {
      if (i == index) {
        _videoControllers[i].play();
      } else {
        _videoControllers[i].pause();
      }
    }
  }

  Widget _buildVideoStack() {
    final activities = widget.viewModel.filteredActivities;
    
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        final page = _pageController.hasClients && _pageController.page != null
            ? _pageController.page!
            : widget.viewModel.currentIndex.toDouble();
        
        List<Widget> stack = [];
        bool hasInitialized = false;
        
        for (int i = 0; i < activities.length; i++) {
          if ((i - page).abs() > 1.2) continue;
          
          final offset = (i - page) * MediaQuery.of(context).size.height;
          final opacity = (1.0 - (i - page).abs()).clamp(0.0, 1.0);
          
          if (_videoControllers[i].value.isInitialized) hasInitialized = true;
          
          stack.add(
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, offset),
                child: Opacity(
                  opacity: opacity,
                  child: _videoControllers[i].value.isInitialized
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoControllers[i].value.size.width,
                            height: _videoControllers[i].value.size.height,
                            child: VideoPlayer(_videoControllers[i]),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          );
        }
        
        if (!hasInitialized) {
          stack.add(
            Positioned.fill(
              child: Container(color: Colors.black),
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
    final activities = widget.viewModel.filteredActivities;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 视频背景
          Positioned.fill(child: _buildVideoStack()),
          // 顶部LOGO
          const FloatingLogo(),
          // 底部卡片轮播
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding + 64),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      minHeight: math.min(180, MediaQuery.of(context).size.height * 0.26),
                      maxHeight: math.max(180, MediaQuery.of(context).size.height * 0.26),
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: activities.length,
                      physics: const PageScrollPhysics(),
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                          final activity = activities[index];
                        return AnimatedScale(
                            scale: widget.viewModel.currentIndex == index ? 1.0 : 0.92,
                          duration: const Duration(milliseconds: 300),
                          child: _BonusCard(
                              activity: activity,
                            onTap: () {
                                // 领取奖励逻辑
                                widget.viewModel.claimBonus(activity.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Bonus claimed!')),
                              );
                            },
                            index: index,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedSmoothIndicator(
                      activeIndex: widget.viewModel.currentIndex,
                    count: activities.length,
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

  void _onTap() {
    setState(() => _scale = 0.97);
    Future.delayed(const Duration(milliseconds: 80), () {
      setState(() => _scale = 1.0);
      widget.onTap();
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 活动名
                Text(
                  widget.activity.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: mainTextColor,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                // 描述
                Text(
                  widget.activity.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: mainTextColor.withOpacity(0.82),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // 奖励
                Container(
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
                    children: [
                      Icon(Icons.card_giftcard, size: 15, color: gradient.last),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.activity.reward,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: mainTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
                const SizedBox(height: 8),
                // 底部提示
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
        child: Text(
                      'Tap card to learn more',
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
