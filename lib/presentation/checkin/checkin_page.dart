import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';

class ProductCheckin {
  final String name;
  final String description;
  final String iconAsset;
  final bool checkedIn;

  ProductCheckin({
    required this.name,
    required this.description,
    required this.iconAsset,
    this.checkedIn = false,
  });
}

class CheckinPage extends StatelessWidget {
  CheckinPage({Key? key}) : super(key: key);

  final List<ProductCheckin> products = [
    ProductCheckin(
      name: "HIIT Pro",
      description: "High-Intensity Interval Training",
      iconAsset: "assets/icons/hiit.svg", // 需准备SVG
      checkedIn: false,
    ),
    ProductCheckin(
      name: "Yoga Flex",
      description: "Daily Yoga Flexibility",
      iconAsset: "assets/icons/yoga.svg", // 需准备SVG
      checkedIn: true,
    ),
    // 未来可扩展更多产品
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text('Daily Check-in', style: AppTextStyles.headlineLarge),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner/激励语
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              "Stay active, stay strong!",
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 产品打卡卡片
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductCheckin product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: product.checkedIn
              ? [AppColors.light60, AppColors.light40]
              : [AppColors.primary, AppColors.energyOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                // TODO: 替换为SVG图片
                child: Icon(Icons.fitness_center, color: AppColors.primary, size: 32),
              ),
            ),
            const SizedBox(width: 20),
            // 产品信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // 打卡按钮
            ElevatedButton(
              onPressed: product.checkedIn ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: product.checkedIn ? AppColors.buttonDisabled : AppColors.primary,
                foregroundColor: AppColors.buttonText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 0,
              ),
              child: Text(
                product.checkedIn ? "Checked In" : "Check in",
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 