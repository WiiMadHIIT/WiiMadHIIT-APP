import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class CodeReminderSheet extends StatefulWidget {
  final String? productName;
  final String? challengeName;

  const CodeReminderSheet({
    Key? key,
    this.productName,
    this.challengeName,
  }) : super(key: key);

  @override
  State<CodeReminderSheet> createState() => _CodeReminderSheetState();
}

class _CodeReminderSheetState extends State<CodeReminderSheet>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // 安全启动动画
    if (mounted) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    // 释放动画控制器
    _animationController.dispose();
    super.dispose();
  }

  void _close() {
    if (mounted) {
      _animationController.reverse().then((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  Future<void> _launchShopPage() async {
    final Uri url = Uri.parse('https://www.wiimadhiit.com/equipment');
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shop is taking a coffee break! ☕'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shop got lost in the mall! 🛍️'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 检查动画控制器是否已释放
    if (!_animationController.isAnimating && !_animationController.isCompleted) {
      return const SizedBox.shrink();
    }
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // 背景遮罩
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                child: Container(
                  color: Colors.black.withOpacity(0.3 * _fadeAnimation.value),
                ),
              ),
            ),
            
            // 弹窗内容
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
                                child: Transform.translate(
                    offset: Offset(0, 50 * _slideAnimation.value),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.55,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 24,
                            offset: const Offset(0, -8),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 拖拽指示器
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      
                      // 标题区域
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Get Your Magic Code!',
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 内容区域
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 产品信息（如果有的话）
                            if (widget.productName != null || widget.challengeName != null) ...[
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.productName != null) ...[
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.inventory_2,
                                            size: 16,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              widget.productName!,
                                              style: AppTextStyles.titleMedium.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (widget.challengeName != null) ...[
                                      if (widget.productName != null) const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.emoji_events,
                                            size: 14,
                                            color: Colors.orange[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              widget.challengeName!,
                                              style: AppTextStyles.bodyMedium.copyWith(
                                                color: Colors.orange[600],
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // 说明文字
                            Text(
                              'Ready to unlock your fitness adventure?',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 14),
                            
                            // 步骤列表
                            _buildStepItem(
                              icon: Icons.shopping_cart,
                              title: 'Get Your Gear',
                              description: 'Grab the fitness equipment or training kit',
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 10),
                            
                            _buildStepItem(
                              icon: Icons.qr_code,
                              title: 'Find Your Code',
                              description: 'Your magic code comes with the purchase',
                              color: Colors.orange[600]!,
                            ),
                            const SizedBox(height: 10),
                            
                            _buildStepItem(
                              icon: Icons.verified,
                              title: 'Activate & Rock!',
                              description: 'Enter the activation code and start your journey!',
                              color: Colors.orange[600]!,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // 操作按钮
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _close,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      side: BorderSide(color: Colors.grey[300]!),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text(
                                      'Got it! 👍',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await _launchShopPage();
                                      _close();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text(
                                      'Shop Now! 🛍️',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
