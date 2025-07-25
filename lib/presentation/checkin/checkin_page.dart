import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import '../../widgets/floating_logo.dart';
import '../checkin_start_training/training_list_page.dart';

class ProductCheckin {
  final String id; // 新增ID字段
  final String name;
  final String description;
  final String iconAsset;
  final String routeName;
  final String? videoAsset; // 新增，可选

  ProductCheckin({
    required this.id,
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.routeName,
    this.videoAsset,
  });
}

class CheckinPage extends StatefulWidget {
  const CheckinPage({Key? key}) : super(key: key);

  @override
  State<CheckinPage> createState() => _CheckinPageState();
}

class _CheckinPageState extends State<CheckinPage> with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  VideoPlayerController? _nextController;
  late InfiniteScrollController _carouselController;
  int _currentIndex = 0;
  late final PageController _pageController = PageController(viewportFraction: 0.78);
  late final AnimationController _videoSwitchAnim;
  bool _isSwitchingVideo = false;
  late final List<VideoPlayerController> _videoControllers;

  // 这里必须有
  final List<ProductCheckin> products = [
    ProductCheckin(
      id: "hiit_pro",
      name: "HIIT Pro",
      description: "High-Intensity Interval Training for maximum results",
      iconAsset: "assets/icons/hiit.svg",
      routeName: "/training_list",
      videoAsset: "assets/video/video1.mp4",
    ),
    ProductCheckin(
      id: "yoga_flex",
      name: "Yoga Flex",
      description: "Daily Yoga Flexibility and Mindfulness",
      iconAsset: "assets/icons/yoga.svg",
      routeName: "/training_list",
      videoAsset: "assets/video/video2.mp4",
    ),
    ProductCheckin(
      id: "strength_training",
      name: "Strength Training",
      description: "Build muscle and increase strength",
      iconAsset: "assets/icons/hiit.svg",
      routeName: "/training_list",
      videoAsset: "assets/video/video3.mp4",
    ),
    ProductCheckin(
      id: "cardio_blast",
      name: "Cardio Blast",
      description: "High-energy cardio workout",
      iconAsset: "assets/icons/yoga.svg",
      routeName: "/training_list",
      videoAsset: "assets/video/video1.mp4",
    ),
    // ... 其他产品
  ];

  @override
  void initState() {
    super.initState();
    _carouselController = InfiniteScrollController(initialItem: 0);
    _videoSwitchAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _videoControllers = List.generate(products.length, (i) {
      final asset = (products[i].videoAsset == null || products[i].videoAsset!.isEmpty)
          ? 'assets/video/video1.mp4'
          : products[i].videoAsset!;
      final controller = VideoPlayerController.asset(asset)
        ..setLooping(true)
        ..setVolume(0);
      controller.initialize().then((_) {
        if (i == 0) {
          controller.play();
        }
        // 触发刷新，确保 build 能感知到初始化完成
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

  void _onProductTap(ProductCheckin product) {
    if (product.routeName == "/training_list" || product.routeName == "/trainingList") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrainingListPage(
            productId: product.id, // 传递产品ID
          ),
        ),
      );
    } else {
      Navigator.pushNamed(context, product.routeName);
    }
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
        for (int i = 0; i < products.length; i++) {
          // 只渲染前后1页，提升性能
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
        // 如果所有视频都没初始化，显示默认视频
        if (!hasInitialized) {
          stack.add(
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: 1, // 这里用1防止报错
                  height: 1,
                  child: VideoPlayer(
                    VideoPlayerController.asset('assets/video/video1.mp4')
                      ..setLooping(true)
                      ..setVolume(0)
                      ..initialize(),
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth * 0.78; // 78% 屏幕宽度
    final double bottomPadding = MediaQuery.of(context).padding.bottom; //safty安全区高度 
    // final double bottomPadding2 = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight; //safty安全区高度 + 底部tabbar高度

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 全屏视频背景（TikTok风格上下滑动切换）
          Positioned.fill(
            child: _buildVideoStack(),
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

          // 悬浮入口
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
                      Navigator.pushNamed(context, '/checkinboard');
                    },
                  ),
                  SizedBox(
                    height: 200, // 推荐用固定高度，性能更优
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: products.length,
                      physics: const PageScrollPhysics(), // 强磁吸
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                        return AnimatedScale(
                          scale: _currentIndex == index ? 1.0 : 0.92,
                          duration: const Duration(milliseconds: 300),
                          child: _ProductEntry(
                            product: products[index],
                            onTap: () => _onProductTap(products[index]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedSmoothIndicator(
                    activeIndex: _currentIndex,
                    count: products.length,
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
          // 无入口时显示激励语
          if (products.isEmpty)
            Center(
              child: Text(
                "Stay active, stay strong!",
                style: AppTextStyles.headlineLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
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
    setState(() {
      _scale = widget.pressedScale;
      _isAnimating = true;
    });
    await Future.delayed(widget.pressDuration);
    setState(() {
      _scale = 1.0;
    });
    await Future.delayed(widget.reboundDuration);
    widget.onTap();
    setState(() {
      _isAnimating = false;
    });
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
  final ProductCheckin product;
  final VoidCallback onTap;

  const _ProductEntry({required this.product, required this.onTap});

  @override
  State<_ProductEntry> createState() => _ProductEntryState();
}

class _ProductEntryState extends State<_ProductEntry> {
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
                          child: Icon(Icons.fitness_center, color: AppColors.primary, size: 24),
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
    setState(() => _scale = 0.90);
    Future.delayed(const Duration(milliseconds: 80), () {
      setState(() => _scale = 1.0);
      widget.onPressed();
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
    setState(() => _scale = 0.97);
    Future.delayed(const Duration(milliseconds: 80), () {
      setState(() => _scale = 1.0);
      widget.onTap();
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