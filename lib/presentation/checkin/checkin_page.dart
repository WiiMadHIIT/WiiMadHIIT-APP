import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

class ProductCheckin {
  final String name;
  final String description;
  final String iconAsset;
  final String routeName;
  final String? videoAsset; // 新增，可选

  ProductCheckin({
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
      name: "HIIT Pro",
      description: "High-Intensity Interval Training",
      iconAsset: "assets/icons/hiit.svg",
      routeName: "/hiit",
      videoAsset: "assets/video/video1.mp4",
    ),
    ProductCheckin(
      name: "Yoga Flex",
      description: "Daily Yoga Flexibility",
      iconAsset: "assets/icons/yoga.svg",
      routeName: "/yoga",
      videoAsset: "assets/video/video2.mp4",
    ),
    ProductCheckin(
      name: "Yoga Flex",
      description: "Daily Yoga Flexibility",
      iconAsset: "assets/icons/yoga.svg",
      routeName: "/yoga",
      videoAsset: "assets/video/video3.mp4",
    ),
    ProductCheckin(
      name: "HIIT Pro",
      description: "High-Intensity Interval Training",
      iconAsset: "assets/icons/hiit.svg",
      routeName: "/hiit",
      videoAsset: "",
    ),
    ProductCheckin(
      name: "HIIT Pro",
      description: "High-Intensity Interval Training",
      iconAsset: "assets/icons/hiit.svg",
      routeName: "/hiit",
      videoAsset: "",
    ),
    ProductCheckin(
      name: "HIIT Pro",
      description: "High-Intensity Interval Training",
      iconAsset: "assets/icons/hiit.svg",
      routeName: "/hiit",
      videoAsset: "",
    ),
    ProductCheckin(
      name: "HIIT Pro",
      description: "High-Intensity Interval Training",
      iconAsset: "assets/icons/hiit.svg",
      routeName: "/hiit",
      videoAsset: "",
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
    Navigator.pushNamed(context, product.routeName);
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
                      color: Colors.red.withOpacity(0.25), // 红色发光
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
                            color: Colors.red.withOpacity(0.35), // 红色发光
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
          // 悬浮入口
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 64),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 180, // 推荐用固定高度，性能更优
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

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _AnimatedButton({required this.onPressed, required this.child});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
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

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.97;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          splashColor: AppColors.primary.withOpacity(0.08),
          highlightColor: AppColors.primary.withOpacity(0.10),
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
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
                            maxLines: 1,
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
                const SizedBox(height: 14),
                // 明确的操作按钮
                Align(
                  alignment: Alignment.centerRight,
                  child: _AnimatedButton(
                    onPressed: widget.onTap,
                    child: ElevatedButton.icon(
                      onPressed: widget.onTap,
                      icon: const Icon(Icons.flash_on, size: 18, color: Colors.white),
                      label: Text(
                        'Start Training',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        elevation: 0,
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