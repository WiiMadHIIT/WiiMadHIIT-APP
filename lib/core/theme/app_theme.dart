import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  // 圆角、阴影、间距等全局常量
  static const double borderRadius = 12;
  static const double cardElevation = 2;
  static const double dialogElevation = 8;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;

  // 按钮风格
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.buttonText,
    textStyle: AppTextStyles.labelLarge,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    elevation: cardElevation,
    padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
  );

  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    textStyle: AppTextStyles.labelLarge,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
  );

  static final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    textStyle: AppTextStyles.labelLarge,
    side: const BorderSide(color: AppColors.primary),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
  );

  // 亮色主题
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    dividerColor: AppColors.divider,
    textTheme: AppTextStyles.textTheme,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.energyOrange,
      error: AppColors.error,
      background: AppColors.background,
      surface: AppColors.card,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.card,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.primary),
      titleTextStyle: AppTextStyles.headlineLarge,
      centerTitle: true,
    ),
    iconTheme: const IconThemeData(color: AppColors.primary),
    elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedButtonStyle),
    textButtonTheme: TextButtonThemeData(style: textButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonStyle),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.gray2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
      hintStyle: AppTextStyles.bodySmall,
      labelStyle: AppTextStyles.bodyMedium,
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: const EdgeInsets.all(spacingM),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.dialog,
      elevation: dialogElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      titleTextStyle: AppTextStyles.headlineLarge,
      contentTextStyle: AppTextStyles.bodyLarge,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.gray4,
      labelStyle: AppTextStyles.labelLarge,
      unselectedLabelStyle: AppTextStyles.labelMedium,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.gray4,
      selectedLabelStyle: AppTextStyles.labelLarge,
      unselectedLabelStyle: AppTextStyles.labelMedium,
      type: BottomNavigationBarType.fixed,
      elevation: cardElevation,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.card,
      textStyle: AppTextStyles.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.gray2,
      labelStyle: AppTextStyles.bodySmall,
      selectedColor: AppColors.primary.withOpacity(0.1),
      secondarySelectedColor: AppColors.primary.withOpacity(0.2),
      disabledColor: AppColors.gray3,
      padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(AppColors.primary),
      trackColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.3)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.gray3,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withOpacity(0.1),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.dark40,
        borderRadius: BorderRadius.circular(borderRadius / 2),
      ),
      textStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
    ),
  );

  // 暗黑主题
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.dark,
    dividerColor: AppColors.gray3,
    textTheme: AppTextStyles.textTheme.apply(
      bodyColor: AppColors.white,
      displayColor: AppColors.white,
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.energyOrange,
      error: AppColors.error,
      background: AppColors.dark,
      surface: AppColors.dark40,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.dark,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.primary),
      titleTextStyle: AppTextStyles.headlineLarge.copyWith(color: AppColors.white),
      centerTitle: true,
    ),
    iconTheme: const IconThemeData(color: AppColors.primary),
    elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedButtonStyle),
    textButtonTheme: TextButtonThemeData(style: textButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonStyle),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.gray3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.gray4),
      labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.gray3,
      thickness: 1,
      space: 1,
    ),
    cardTheme: CardThemeData(
      color: AppColors.dark40,
      elevation: cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: const EdgeInsets.all(spacingM),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.dark40,
      elevation: dialogElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      titleTextStyle: AppTextStyles.headlineLarge.copyWith(color: AppColors.white),
      contentTextStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.gray4,
      labelStyle: AppTextStyles.labelLarge,
      unselectedLabelStyle: AppTextStyles.labelMedium,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.dark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.gray4,
      selectedLabelStyle: AppTextStyles.labelLarge,
      unselectedLabelStyle: AppTextStyles.labelMedium,
      type: BottomNavigationBarType.fixed,
      elevation: cardElevation,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.dark40,
      textStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.gray3,
      labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
      selectedColor: AppColors.primary.withOpacity(0.2),
      secondarySelectedColor: AppColors.primary.withOpacity(0.3),
      disabledColor: AppColors.gray2,
      padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(AppColors.primary),
      trackColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.3)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.gray3,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withOpacity(0.1),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.dark40,
        borderRadius: BorderRadius.circular(borderRadius / 2),
      ),
      textStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
    ),
  );
}