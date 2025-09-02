import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class ActivationResultDialog extends StatelessWidget {
  final bool isSuccess;
  final String productName;
  final String? challengeName;
  final String? successMessage;
  final String? failureMessage;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ActivationResultDialog({
    Key? key,
    required this.isSuccess,
    required this.productName,
    this.challengeName,
    this.successMessage,
    this.failureMessage,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSuccess 
                ? AppColors.primary.withOpacity(0.12)
                : Colors.red.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              size: 28,
              color: isSuccess ? AppColors.primary : Colors.red,
            ),
          ),
          
          const SizedBox(height: 14),
          
          Text(
            isSuccess ? '🎉 Activation Submitted!' : '❌ Oops! Try Again',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isSuccess ? AppColors.primary : Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
                      Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        productName,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                if (challengeName != null) ...[
                                        const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.emoji_events, size: 14, color: Colors.orange[600]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          challengeName!,
                                                  style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 14),
          
                      Text(
              isSuccess 
                ? (successMessage ?? '🎯 Activation queued! We\'ll review in 1-5 days. Watch for "Ready" challenges! 🚀')
                : (failureMessage ?? '🤔 Code didn\'t work. Double-check and try again! 💪'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[700],
                height: 1.2,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              if (onCancel != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Text(
                      'Maybe Later',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? AppColors.primary : Colors.red,
                    foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    isSuccess ? 'Awesome! 🎉' : 'Let\'s Try Again! 🔄',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                                              fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActivationResultDialogHelper {
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String productName,
    String? challengeName,
    String? message,
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ActivationResultDialog(
        isSuccess: true,
        productName: productName,
        challengeName: challengeName,
        successMessage: message,
        onConfirm: onConfirm ?? () => Navigator.of(context).pop(),
      ),
    );
  }

  static Future<void> showFailureDialog({
    required BuildContext context,
    required String productName,
    String? challengeName,
    String? message,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ActivationResultDialog(
        isSuccess: false,
        productName: productName,
        challengeName: challengeName,
        failureMessage: message,
        onConfirm: onConfirm ?? () => Navigator.of(context).pop(),
        onCancel: onCancel ?? () => Navigator.of(context).pop(),
      ),
    );
  }
}
