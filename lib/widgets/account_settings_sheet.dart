import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Shows an iOS-inspired account settings action sheet from the bottom.
///
/// Actions:
/// - Sign out (primary)
/// - Delete account (destructive)
/// - Cancel
Future<void> showAccountSettingsSheet(
  BuildContext context, {
  required VoidCallback onLogout,
  required VoidCallback onDelete,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (context) {
      final media = MediaQuery.of(context);
      final bottomInset = media.viewPadding.bottom;
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset > 0 ? 0 : 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Manage your session and account privacy.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ActionTile(
                      icon: Icons.logout_rounded,
                      iconBg: AppColors.primary.withOpacity(0.12),
                      iconColor: AppColors.primary,
                      title: 'Sign out',
                      subtitle: 'Sign out from this device',
                      onTap: () {
                        Navigator.of(context).pop();
                        onLogout();
                      },
                    ),
                    const Divider(height: 1),
                    _ActionTile(
                      icon: Icons.delete_forever_rounded,
                      iconBg: const Color(0xFFFFECEB),
                      iconColor: const Color(0xFFEB3B30),
                      title: 'Delete account',
                      subtitle: 'Permanently remove your account and data',
                      isDestructive: true,
                      onTap: () async {
                        final confirmed = await _confirmDelete(context);
                        if (confirmed == true) {
                          Navigator.of(context).pop();
                          onDelete();
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _SheetCard(
                child: _CupertinoLikeButton(
                  label: 'Cancel',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

class _SheetCard extends StatelessWidget {
  final Widget child;
  const _SheetCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDestructive ? const Color(0xFFEB3B30) : Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right_rounded, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}

class _CupertinoLikeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _CupertinoLikeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

Future<bool?> _confirmDelete(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete account?',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'This action is permanent and cannot be undone. Your data will be removed.',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.black.withOpacity(0.75)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEB3B30)),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}


