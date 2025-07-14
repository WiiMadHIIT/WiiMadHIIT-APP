import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class CheckinPage extends StatelessWidget {
  const CheckinPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text('Check-in', style: AppTextStyles.headlineLarge),
      ),
      body: Center(
        child: Text(
          'This is the Check-in Page (Demo)',
          style: AppTextStyles.titleLarge,
        ),
      ),
      backgroundColor: AppColors.scaffoldBackground,
    );
  }
} 