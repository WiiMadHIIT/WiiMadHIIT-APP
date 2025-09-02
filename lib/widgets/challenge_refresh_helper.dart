import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_colors.dart';
import '../presentation/profile/profile_viewmodel.dart';

Future<void> loadChallengesWithDialog(BuildContext context, ProfileViewModel viewModel, {int page = 1, int size = 10}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading challenge records...',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );

  final success = await viewModel.loadChallenges(page: page, size: size);
  Navigator.of(context).pop();
  if (!success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Failed to load challenge records',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator()),
            );
            final retry = await viewModel.loadChallenges(page: page, size: size);
            Navigator.of(context).pop();
            if (!retry) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Still failed, please try again later'), backgroundColor: Colors.red),
              );
            }
          },
        ),
      ),
    );
  }
}