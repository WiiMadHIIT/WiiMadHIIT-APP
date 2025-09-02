import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../routes/app_routes.dart';

/// 装备激活对话框类型
enum EquipmentActivationType {
  /// 普通装备激活
  equipment,
  /// 挑战装备激活
  challengeEquipment,
  /// 挑战装备资格获得
  challengeQualified,
}

/// 装备激活对话框组件
class EquipmentActivationDialog {
  /// 显示装备激活提示弹窗
  static void showEquipmentActivated(
    BuildContext context, {
    required String productName,
    required String productId,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 成功图标
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 标题
                Text(
                  'Equipment Activated!',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // 描述
                Text(
                  'Your $productName is powered up! Time to crush some workouts! 💪',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // 按钮
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // 跳转到训练列表页面
                          Navigator.pushNamed(
                            context,
                            AppRoutes.trainingList,
                            arguments: {'productId': productId},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Let\'s Crush It! 🔥',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 显示挑战装备激活提示弹窗
  static void showChallengeEquipmentActivated(
    BuildContext context, {
    required String challengeName,
    required String challengeId,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 成功图标
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 标题
                Text(
                  '⚔️ Battle Time!',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // 描述
                Text(
                  'Your rival awaits! Check Playoff bracket and start the epic $challengeName battle! 🔥',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // 按钮
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // 跳转到挑战详情页面
                          Navigator.pushNamed(
                            context,
                            AppRoutes.challengeDetails,
                            arguments: {'challengeId': challengeId},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Fight! 💪',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 显示挑战装备资格获得提示弹窗
  static void showChallengeEquipmentQualified(
    BuildContext context, {
    required String challengeName,
    required String challengeId,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 成功图标
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 标题
                Text(
                  '🎯 Challenge Ready!',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // 描述
                Text(
                  'Time to shine! Join $challengeName and claim your rewards! 🏆',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // 按钮
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // 跳转到挑战详情页面
                          Navigator.pushNamed(
                            context,
                            AppRoutes.challengeDetails,
                            arguments: {'challengeId': challengeId},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Let\'s Go! 🚀',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 通用方法：根据类型显示对应的对话框
  static void show(
    BuildContext context, {
    required EquipmentActivationType type,
    required String name,
    required String id,
  }) {
    switch (type) {
      case EquipmentActivationType.equipment:
        showEquipmentActivated(
          context,
          productName: name,
          productId: id,
        );
        break;
      case EquipmentActivationType.challengeEquipment:
        showChallengeEquipmentActivated(
          context,
          challengeName: name,
          challengeId: id,
        );
        break;
      case EquipmentActivationType.challengeQualified:
        showChallengeEquipmentQualified(
          context,
          challengeName: name,
          challengeId: id,
        );
        break;
    }
  }
}
