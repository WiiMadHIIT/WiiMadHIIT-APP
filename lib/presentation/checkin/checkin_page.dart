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

  ProductCheckin({
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.routeName,
  });
}

class CheckinPage extends StatefulWidget {
  const CheckinPage({Key? key}) : super(key: key);

  @override
  State<CheckinPage> createState() => _CheckinPageState();
}

class _CheckinPageState extends State<CheckinPage> {
  late VideoPlayerController _controller;
  final List<ProductCheckin> products = [
    ProductCheckin(
      name: "HIIT Pro",
      description: "High-Intensity Interval Training",
      iconAsset: "assets/icons/hiit.svg",
      routeName: "/hiit",
    ),
    ProductCheckin(
      name: "Yoga Flex",
      description: "Daily Yoga Flexibility",
      iconAsset: "assets/icons/yoga.svg",
      routeName: "/yoga",
    ),
    ProductCheckin(
      name: "Yoga Flex",
      description: "Daily Yoga Flexibility",
      iconAsset: "assets/icons/yoga.svg",
      routeName: "/yoga",
    ),
    ProductCheckin(
      name: "Yoga Flex",
      description: "Daily Yoga Flexibility",
      iconAsset: "assets/icons/yoga.svg",
      routeName: "/yoga",
    ),
    ProductCheckin(
      name: "Yoga Flex",
      description: "Daily Yoga Flexibility",
      iconAsset: "assets/icons/yoga.svg",
      routeName: "/yoga",
    ),
    // 可扩展更多产品
  ];
  late InfiniteScrollController _carouselController;
  int _currentIndex = 0;
  late final PageController _pageController = PageController(viewportFraction: 0.78);

  @override
  void initState() {
    super.initState();
    _carouselController = InfiniteScrollController(initialItem: 0);
    _controller = VideoPlayerController.asset('assets/video/video1.mp4')
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _carouselController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onProductTap(ProductCheckin product) {
    Navigator.pushNamed(context, product.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth * 0.78; // 78% 屏幕宽度

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 全屏视频背景
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
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
                    height: 140,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: products.length,
                      physics: const PageScrollPhysics(), // 强磁吸
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
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

class _ProductEntry extends StatelessWidget {
  final ProductCheckin product;
  final VoidCallback onTap;

  const _ProductEntry({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // TODO: 用SVG替换
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.dark40,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
} 