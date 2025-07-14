import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
import '../../routes/app_routes.dart';

class ChallengePage extends StatelessWidget {
  const ChallengePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text(
          'Challenge',
          style: AppTextStyles.headlineLarge,
        ),
        actions: [
          IconButton(
            icon: Icon(AppIcons.info, color: AppColors.icon),
            onPressed: () {},
            tooltip: 'Info',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcons.brandLogoSvg(size: 48, isActive: true),
            const SizedBox(height: AppTheme.spacingL),
            Icon(AppIcons.star, size: 48, color: AppColors.primary),
            const SizedBox(height: AppTheme.spacingXL),
            ElevatedButton.icon(
              style: AppTheme.elevatedButtonStyle,
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.challengeDetails);
              },
              icon: Icon(AppIcons.arrowForward, color: AppColors.buttonText),
              label: Text(
                'Go to Challenge Details',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.buttonText),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.scaffoldBackground,
    );
  }
}
