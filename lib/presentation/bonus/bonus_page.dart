import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BonusActivity {
  final String name;
  final String description;
  final String reward;
  final String regionLimit;
  final String videoAsset;

  BonusActivity({
    required this.name,
    required this.description,
    required this.reward,
    required this.regionLimit,
    required this.videoAsset,
  });
}

class BonusPage extends StatefulWidget {
  const BonusPage({Key? key}) : super(key: key);

  @override
  State<BonusPage> createState() => _BonusPageState();
}

class _BonusPageState extends State<BonusPage> with SingleTickerProviderStateMixin {
  late final PageController _pageController = PageController(viewportFraction: 0.78);
  int _currentIndex = 0;
  late final List<VideoPlayerController> _videoControllers;

  final List<BonusActivity> activities = [
    BonusActivity(
      name: "Spring Challenge",
      description: "Join the spring fitness challenge and win big!",
      reward: "Up to 1000 WiiCoins + Exclusive Badge",
      regionLimit: "US, Canada, UK",
      videoAsset: "assets/video/video1.mp4",
    ),
    BonusActivity(
      name: "Yoga Marathon",
      description: "Complete 30 days of yoga for a special bonus.",
      reward: "500 WiiCoins + Yoga Mat",
      regionLimit: "Global",
      videoAsset: "assets/video/video2.mp4",
    ),
    BonusActivity(
      name: "HIIT Pro Bonus",
      description: "Push your HIIT limits and unlock rewards.",
      reward: "700 WiiCoins + Pro T-shirt",
      regionLimit: "US Only",
      videoAsset: "assets/video/video3.mp4",
    ),
    BonusActivity(
      name: "Cardio Blast",
      description: "Burn calories and earn extra bonuses!",
      reward: "300 WiiCoins + Energy Drink",
      regionLimit: "Europe, Asia",
      videoAsset: "assets/video/video1.mp4",
    ),
    BonusActivity(
      name: "Endurance King",
      description: "Longest streak wins the grand prize!",
      reward: "2000 WiiCoins + Crown Badge",
      regionLimit: "Global",
      videoAsset: "assets/video/video2.mp4",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _videoControllers = List.generate(activities.length, (i) {
      final controller = VideoPlayerController.asset(activities[i].videoAsset)
        ..setLooping(true)
        ..setVolume(0); // 已经静音
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
    setState(() {
      _currentIndex = index;
    });
    for (int i = 0; i < _videoControllers.length; i++) {
      if (i == index) {
        _videoControllers[i].play();
      } else {
        _videoControllers[i].pause();
      }
    }
  }

  Widget _buildVideoStack() {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        final page = _pageController.hasClients && _pageController.page != null
            ? _pageController.page!
            : _currentIndex.toDouble();
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 视频背景
          Positioned.fill(child: _buildVideoStack()),
          // 顶部LOGO
          Positioned(
            top: MediaQuery.of(context).padding.top + 32,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.40),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.25),
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: const Offset(0, 0),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.black.withOpacity(0.18), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.35),
                            blurRadius: 16,
                            spreadRadius: 2,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: SvgPicture.asset(
                          'assets/icons/wiimadhiit-w-red.svg',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'WiiMadHIIT',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 底部卡片轮播
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 64),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 260,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: activities.length,
                      physics: const PageScrollPhysics(),
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                        return AnimatedScale(
                          scale: _currentIndex == index ? 1.0 : 0.92,
                          duration: const Duration(milliseconds: 300),
                          child: _BonusCard(
                            activity: activities[index],
                            onTap: () {
                              // TODO: 领奖逻辑
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
                    activeIndex: _currentIndex,
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
        ],
      ),
    );
  }
}

class _BonusCard extends StatefulWidget {
  final BonusActivity activity;
  final VoidCallback onTap;
  final int index;
  const _BonusCard({required this.activity, required this.onTap, required this.index});

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
      // 亮色用primary，深色用黑色
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
                  maxLines: 2,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.public, size: 13, color: gradient.last),
                      const SizedBox(width: 4),
                      Text(
                        widget.activity.regionLimit.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: mainTextColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
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
