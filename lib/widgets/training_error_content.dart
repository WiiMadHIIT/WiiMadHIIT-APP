import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_colors.dart';

/// 🎯 训练相关错误内容组件 - 通用模板
/// 
/// 使用方式：
/// ```dart
/// TrainingErrorContent(
///   onRetry: () => viewModel.refresh(),
///   title: 'Oops! A little hiccup', // 可选，默认幽默标题
///   description: 'Custom description', // 可选，默认幽默描述
///   buttonText: 'Try Again', // 可选，默认按钮文字
/// )
/// ```
class TrainingErrorContent extends StatelessWidget {
  final VoidCallback onRetry;
  final String? title;
  final String? description;
  final String? buttonText;
  final IconData? customIcon;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;
  final bool showIcon;

  const TrainingErrorContent({
    super.key,
    required this.onRetry,
    this.title,
    this.description,
    this.buttonText,
    this.customIcon,
    this.iconColor,
    this.padding,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🎯 幽默的图标：使用问号而不是错误图标
          if (showIcon)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                customIcon ?? Icons.help_outline,
                size: 48,
                color: iconColor ?? AppColors.primary,
              ),
            ),
          if (showIcon) const SizedBox(height: 20),
          
          // 🎯 幽默的标题：不说"错误"，而是"小意外"
          Text(
            title ?? 'Oops! A little hiccup',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // 🎯 幽默的描述：用轻松的语气解释
          Text(
            description ?? 'Something unexpected happened',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // 🎯 幽默的按钮：不说"重试"，而是"再试一次"
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh, size: 18),
            label: Text(
              buttonText ?? 'Try Again',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎯 训练规则错误内容组件 - 专门用于训练规则页面
class TrainingRuleErrorContent extends StatelessWidget {
  final VoidCallback onRetry;

  const TrainingRuleErrorContent({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return TrainingErrorContent(
      onRetry: onRetry,
      title: 'Oops! A little hiccup',
      description: 'Our training rules are taking a coffee break',
      buttonText: 'Try Again',
    );
  }
}

/// 🎯 训练列表错误内容组件 - 专门用于训练列表页面
class TrainingListErrorContent extends StatelessWidget {
  final VoidCallback onRetry;

  const TrainingListErrorContent({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return TrainingErrorContent(
      onRetry: onRetry,
      title: 'Oops! A little hiccup',
      description: 'Our training data is taking a coffee break',
      buttonText: 'Try Again',
    );
  }
} 