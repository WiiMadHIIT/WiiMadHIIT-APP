import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../domain/entities/bonus_activity.dart';

class BonusActivityDetailSheet extends StatefulWidget {
  final BonusActivity activity;
  final VoidCallback? onClose;

  const BonusActivityDetailSheet({
    Key? key,
    required this.activity,
    this.onClose,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required BonusActivity activity,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => BonusActivityDetailSheet(
        activity: activity,
        onClose: onClose,
      ),
    );
  }

  @override
  State<BonusActivityDetailSheet> createState() => _BonusActivityDetailSheetState();
}

class _BonusActivityDetailSheetState extends State<BonusActivityDetailSheet> {
  bool _isCodeCopied = false;
  bool _isUrlCopied = false;

  Future<void> _copyActivityCode() async {
    if (widget.activity.activityCode?.isNotEmpty == true) {
      await Clipboard.setData(ClipboardData(text: widget.activity.activityCode!));
      setState(() => _isCodeCopied = true);
      
      // 🎯 静默复制，不显示SnackBar，符合苹果设计理念
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _isCodeCopied = false);
      });
    }
  }

  Future<void> _copyActivityUrl() async {
    if (widget.activity.activityUrl?.isNotEmpty == true) {
      await Clipboard.setData(ClipboardData(text: widget.activity.activityUrl!));
      setState(() => _isUrlCopied = true);
      
      // 🎯 静默复制，不显示SnackBar，符合苹果设计理念
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _isUrlCopied = false);
      });
    }
  }

  /// 🎯 在浏览器中打开活动链接
  Future<void> _openActivityUrl() async {
    if (widget.activity.activityUrl?.isNotEmpty == true) {
      final Uri url = Uri.parse(widget.activity.activityUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Cannot open link'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.85;

    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 12),
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.primary.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.card_giftcard,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity Details',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Background video shows current activity',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.grey[300]!,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.activity.activityName?.isNotEmpty == true) ...[
                      _buildInfoSection(
                        icon: Icons.emoji_events,
                        title: 'Activity Name',
                        content: widget.activity.activityName!,
                        iconColor: Colors.amber,
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    if (widget.activity.activityDescription?.isNotEmpty == true) ...[
                      _buildInfoSection(
                        icon: Icons.description,
                        title: 'Description',
                        content: widget.activity.activityDescription!,
                        iconColor: Colors.blue,
                        isDescription: true,
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    if (widget.activity.reward.isNotEmpty) ...[
                      _buildInfoSection(
                        icon: Icons.card_giftcard,
                        title: 'Reward',
                        content: widget.activity.reward,
                        iconColor: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    if (widget.activity.regionLimit.isNotEmpty) ...[
                      _buildInfoSection(
                        icon: Icons.public,
                        title: 'Region Limit',
                        content: widget.activity.regionLimit,
                        iconColor: Colors.green,
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    if (widget.activity.activityCode?.isNotEmpty == true) ...[
                      _buildCopyableSection(
                        icon: Icons.code,
                        title: 'Activity Code',
                        content: widget.activity.activityCode!,
                        iconColor: Colors.purple,
                        onCopy: _copyActivityCode,
                        isCopied: _isCodeCopied,
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    if (widget.activity.activityUrl?.isNotEmpty == true) ...[
                      _buildUrlSection(
                        icon: Icons.link,
                        title: 'Activity Link',
                        content: widget.activity.activityUrl!,
                        iconColor: Colors.orange,
                        onCopy: _copyActivityUrl,
                        onOpen: _openActivityUrl,
                        isCopied: _isUrlCopied,
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    if (widget.activity.startTimeStep != null) ...[
                      _buildInfoSection(
                        icon: Icons.schedule,
                        title: 'Start Time',
                        content: _formatTimestamp(widget.activity.startTimeStep),
                        iconColor: Colors.teal,
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    if (widget.activity.endTimeStep != null) ...[
                      _buildInfoSection(
                        icon: Icons.timer_off,
                        title: 'End Time',
                        content: _formatTimestamp(widget.activity.endTimeStep),
                        iconColor: Colors.red,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Close'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.grey[700],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.rocket_launch, size: 18),
                      label: const Text('Join Activity'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
    bool isDescription = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.black87,
                    height: isDescription ? 1.4 : 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableSection({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
    required VoidCallback onCopy,
    required bool isCopied,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                      Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: iconColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.black87,
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onCopy,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCopied ? Colors.green : AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: (isCopied ? Colors.green : AppColors.primary).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCopied ? Icons.check : Icons.copy,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isCopied ? 'Copied!' : 'Copy',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🎯 构建URL展示区域（支持复制和打开）
  Widget _buildUrlSection({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
    required VoidCallback onCopy,
    required VoidCallback onOpen,
    required bool isCopied,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.black87,
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onCopy,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCopied ? Colors.green : AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: (isCopied ? Colors.green : AppColors.primary).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isCopied ? Icons.check : Icons.copy,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isCopied ? 'Copied!' : 'Copy Link',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onOpen,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.open_in_new,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Open',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
