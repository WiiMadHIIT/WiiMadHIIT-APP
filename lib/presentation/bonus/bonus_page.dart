import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class BonusPage extends StatelessWidget {
  const BonusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text('Bonus', style: AppTextStyles.headlineLarge),
      ),
      body: Center(
        child: Text(
          'This is the Bonus Page (Demo)',
          style: AppTextStyles.titleLarge,
        ),
      ),
      backgroundColor: AppColors.scaffoldBackground,
    );
  }
} 