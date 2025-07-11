import 'package:flutter/material.dart';
import 'app_colors.dart';

const List<String> fontFallback = [
  // iOS/macOS
  'San Francisco', 'SF Pro Text', 'SF Pro Display', 'PingFang SC', 'Heiti SC', 'Helvetica Neue',
  // Android
  'Roboto', 'Noto Sans SC', 'Noto Sans', 'Droid Sans',
  // Web/桌面
  'Arial', 'Helvetica', 'sans-serif'
];

class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.bold,
    fontSize: 28,
    color: AppColors.black,
  );
  static const TextStyle headline2 = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w600,
    fontSize: 22,
    color: AppColors.black,
  );
  static const TextStyle subtitle1 = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: AppColors.grey5,
  );
  static const TextStyle body1 = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.normal,
    fontSize: 16,
    color: AppColors.grey5,
  );
  static const TextStyle body2 = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.normal,
    fontSize: 14,
    color: AppColors.grey4,
  );
  static const TextStyle button = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.primary,
  );
  static const TextStyle caption = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.normal,
    fontSize: 12,
    color: AppColors.grey4,
  );
  static const TextStyle disabled = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.normal,
    fontSize: 16,
    color: AppColors.grey3,
  );

  static TextTheme textTheme = TextTheme(
    displayLarge: headline1,
    displayMedium: headline2,
    titleMedium: subtitle1,
    bodyLarge: body1,
    bodyMedium: body2,
    labelLarge: button,
    bodySmall: caption,
    labelSmall: disabled,
  );
}
