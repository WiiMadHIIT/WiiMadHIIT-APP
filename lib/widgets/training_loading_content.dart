import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_colors.dart';

/// 🎯 训练相关加载内容组件 - 通用模板
/// 
/// 使用方式：
/// ```dart
/// TrainingLoadingContent(
///   title: 'Custom Title', // 可选，默认幽默标题
///   description: 'Custom description', // 可选，默认幽默描述
///   showIcon: true, // 可选，默认true
///   iconColor: Colors.blue, // 可选，默认使用主题色
/// )
/// ```
class TrainingLoadingContent extends StatelessWidget {
  final String? title;
  final String? description;
  final bool showIcon;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;

  const TrainingLoadingContent({
    super.key,
    this.title,
    this.description,
    this.showIcon = true,
    this.iconColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🎯 幽默的加载动画：使用主题色的圆形进度条
            if (showIcon)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor ?? AppColors.primary),
                    strokeWidth: 3,
                  ),
                ),
              ),
            if (showIcon) const SizedBox(height: 20),
            
            // 🎯 幽默的标题：不说"加载中"，而是"准备中"
            Text(
              title ?? 'Getting ready for you',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // 🎯 幽默的描述：用轻松的语气解释
            Text(
              description ?? 'Something is warming up',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 🎯 训练规则加载内容组件 - 专门用于训练规则页面
class TrainingRuleLoadingContent extends StatelessWidget {
  const TrainingRuleLoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return TrainingLoadingContent(
      title: 'Getting ready for you',
      description: 'Our training rules are warming up',
    );
  }
}

/// 🎯 训练列表加载内容组件 - 专门用于训练列表页面
class TrainingListLoadingContent extends StatelessWidget {
  const TrainingListLoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return TrainingLoadingContent(
      title: 'Getting ready for you',
      description: 'Our training data is warming up',
    );
  }
}

/// 🎯 通用训练加载内容组件 - 用于其他训练相关页面
class GeneralTrainingLoadingContent extends StatelessWidget {
  final String? customTitle;
  final String? customDescription;

  const GeneralTrainingLoadingContent({
    super.key,
    this.customTitle,
    this.customDescription,
  });

  @override
  Widget build(BuildContext context) {
    return TrainingLoadingContent(
      title: customTitle ?? 'Getting ready for you',
      description: customDescription ?? 'Something is warming up',
    );
  }
} 