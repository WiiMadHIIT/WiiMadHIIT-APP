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
  // Display
  static const TextStyle displayLarge = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w700, // Bold
    fontSize: 34,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  static const TextStyle displayMedium = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w700, // Bold
    fontSize: 28,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  static const TextStyle displaySmall = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w600, // Semibold
    fontSize: 22,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  // Headline
  static const TextStyle headlineLarge = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w600, // Semibold
    fontSize: 20,
    height: 1.25,
    color: AppColors.textPrimary,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 17,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 16,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // Title
  static const TextStyle titleLarge = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w600, // Semibold
    fontSize: 17,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  static const TextStyle titleMedium = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 15,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  static const TextStyle titleSmall = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 13,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 17,
    height: 1.4,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 15,
    height: 1.4,
    color: AppColors.textSecondary,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 13,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // Label/Button
  static const TextStyle labelLarge = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w700, // Bold
    fontSize: 16,
    height: 1.2,
    color: AppColors.primary,
    letterSpacing: 0.2,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w600, // Semibold
    fontSize: 14,
    height: 1.2,
    color: AppColors.primary,
    letterSpacing: 0.1,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 12,
    height: 1.2,
    color: AppColors.primary,
  );

  // Caption/Footnote/Overline
  static const TextStyle caption = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 12,
    height: 1.2,
    color: AppColors.textSecondary,
  );
  static const TextStyle footnote = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 11,
    height: 1.2,
    color: AppColors.textDisabled,
  );
  static const TextStyle overline = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 10,
    height: 1.2,
    color: AppColors.textDisabled,
    letterSpacing: 1.5,
  );

  // Disabled
  static const TextStyle disabled = TextStyle(
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 16,
    height: 1.2,
    color: AppColors.textDisabled,
  );

  // 等宽/代码
  static const TextStyle mono = TextStyle(
    fontFamily: 'SF Mono',
    fontFamilyFallback: ['Menlo', 'Consolas', 'monospace'],
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.3,
    color: AppColors.dark40,
  );

  // 全局 TextTheme 映射
  static TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}