import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'dart:ui'; // Added for ImageFilter

class ProductCheckin {
  final String name;
  final String description;
  final String iconAsset;
  bool checkedIn;

  ProductCheckin({
    required this.name,
    required this.description,
    required this.iconAsset,
    this.checkedIn = false,
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
    ),
    ProductCheckin(
      name: "Yoga Flex",
      description: "Daily Yoga Flexibility",
      iconAsset: "assets/icons/yoga.svg",
    ),
    // 可扩展更多产品
  ];

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  void _toggleCheckin(int index) {
    setState(() {
      products[index].checkedIn = !products[index].checkedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 视频未加载时的底色
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
          // 半透明/毛玻璃内容区
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 32),
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
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.2),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...List.generate(products.length, (index) {
                                final product = products[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: _ProductCard(
                                    product: product,
                                    onTap: () => _toggleCheckin(index),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
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

class _ProductCard extends StatelessWidget {
  final ProductCheckin product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isChecked = product.checkedIn;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isChecked ? AppColors.primary.withOpacity(0.85) : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            if (isChecked)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Row(
          children: [
            // TODO: 替换为SVG图片
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isChecked ? Colors.white : AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.fitness_center,
                  color: isChecked ? AppColors.primary : AppColors.dark,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 产品信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: isChecked ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isChecked ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // 点亮状态icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isChecked
                  ? Icon(Icons.check_circle, color: Colors.white, size: 28, key: ValueKey(true))
                  : Icon(Icons.radio_button_unchecked, color: AppColors.primary, size: 28, key: ValueKey(false)),
            ),
          ],
        ),
      ),
    );
  }
} 