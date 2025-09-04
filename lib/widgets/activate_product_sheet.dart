import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../domain/entities/profile.dart';
import '../presentation/profile/profile_viewmodel.dart';
import 'code_reminder_sheet.dart';
import 'activation_result_dialog.dart';

class ActivateProductSheet extends StatefulWidget {
  final List<Activate> activateList;
  final Function(String productId, String activationCode)? onActivate;

  const ActivateProductSheet({
    Key? key,
    required this.activateList,
    this.onActivate,
  }) : super(key: key);

  @override
  State<ActivateProductSheet> createState() => _ActivateProductSheetState();
}

class _ActivateProductSheetState extends State<ActivateProductSheet>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  // 添加滚动控制器用于键盘弹出时的滚动
  late ScrollController _scrollController;
  
  // 让输入框在键盘上方保持合适间距
  static const double _keyboardGap = 16.0;
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, GlobalKey> _fieldKeys = {};

  final Map<String, TextEditingController> _codeControllers = {};
  final Map<String, GlobalKey<FormState>> _formKeys = {};
  final Map<String, bool> _isSubmitting = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
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

    // 初始化滚动控制器
    _scrollController = ScrollController();

    // 为每个产品创建控制器
    for (final activate in widget.activateList) {
      _codeControllers[activate.productId] = TextEditingController();
      _formKeys[activate.productId] = GlobalKey<FormState>();
      _isSubmitting[activate.productId] = false;
      _focusNodes[activate.productId] = FocusNode();
      _fieldKeys[activate.productId] = GlobalKey();
      _focusNodes[activate.productId]!.addListener(() {
        if (mounted && _focusNodes[activate.productId]!.hasFocus) {
          _scheduleEnsureVisible(activate.productId);
        }
      });
    }

    // 安全启动动画
    if (mounted) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    // 移除所有焦点节点的监听器以防止内存泄漏
    for (final node in _focusNodes.values) {
      node.removeListener(() {});
      node.dispose();
    }
    
    // 释放所有文本控制器
    for (final controller in _codeControllers.values) {
      controller.dispose();
    }
    
    // 释放动画控制器
    _animationController.dispose();
    
    // 释放滚动控制器
    _scrollController.dispose();
    
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

  // 计划在键盘动画稳定后将输入框滚动到键盘上方，保留固定间距
  void _scheduleEnsureVisible(String productId) {
    Future.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      _ensureVisible(productId);
    });
  }

  void _ensureVisible(String productId) {
    if (!mounted) return;
    if (!_scrollController.hasClients) return;
    final ctx = _fieldKeys[productId]?.currentContext;
    if (ctx == null) return;
    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderBox) return;
    final box = renderObject;
    final fieldBottomGlobal = box.localToGlobal(Offset(0, box.size.height)).dy;
    final viewHeight = MediaQuery.of(context).size.height;
    final keyboardTop = viewHeight - MediaQuery.of(context).viewInsets.bottom;
    final desiredBottom = keyboardTop - _keyboardGap;
    final overflow = fieldBottomGlobal - desiredBottom;
    if (overflow > 0) {
      final double target = (_scrollController.offset + overflow)
          .clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _submitActivation(String productId, String activationCode) async {
    print('🔍 ActivateProductSheet: 开始提交激活码');
    print('🔍 ActivateProductSheet: 产品ID: $productId');
    print('🔍 ActivateProductSheet: 激活码: ${activationCode.substring(0, 2)}****${activationCode.substring(activationCode.length - 2)}');
    
    if (_isSubmitting[productId] == true) {
      print('🔍 ActivateProductSheet: 正在提交中，忽略重复请求');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting[productId] = true;
    });

    try {
      print('🔍 ActivateProductSheet: 获取ProfileViewModel');
      // 获取 ProfileViewModel 并调用激活方法
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      print('🔍 ActivateProductSheet: 调用ViewModel的submitActivationCode方法');
      final result = await viewModel.submitActivationCode(productId, activationCode);
      
      print('🔍 ActivateProductSheet: ViewModel返回结果: $result');
      
      // 检查组件是否仍然挂载
      if (!mounted) return;
      
      if (result) {
        // 激活成功 - 显示成功弹窗
        final activateItem = widget.activateList.firstWhere(
          (item) => item.productId == productId,
          orElse: () => Activate(
            challengeId: '',
            challengeName: '',
            productId: '',
            productName: '',
          ),
        );
        
        // 清空输入框
        _codeControllers[productId]?.clear();
        
        // 调用回调
        widget.onActivate?.call(productId, activationCode);
        
        // 显示成功弹窗
        await ActivationResultDialogHelper.showSuccessDialog(
          context: context,
          productName: activateItem.productName,
          challengeName: activateItem.challengeName.isNotEmpty ? activateItem.challengeName : null,
          message: viewModel.activationSuccessMessage ?? 'Your activation request has been successfully submitted. Please wait 1-5 days for review. After approval, the corresponding challenge/check-in records will appear in the list with "Ready" status.',
          onConfirm: () {
            if (mounted) {
              Navigator.of(context).pop(); // 关闭弹窗
              Navigator.of(context).pop(); // 关闭激活弹窗
            }
          },
        );
      } else {
        // 激活失败 - 显示失败弹窗
        final activateItem = widget.activateList.firstWhere(
          (item) => item.productId == productId,
          orElse: () => Activate(
            challengeId: '',
            challengeName: '',
            productId: '',
            productName: '',
          ),
        );
        
        await ActivationResultDialogHelper.showFailureDialog(
          context: context,
          productName: activateItem.productName,
          challengeName: activateItem.challengeName.isNotEmpty ? activateItem.challengeName : null,
          message: viewModel.activationError ?? 'Activation code submission failed. Please check if the activation code is correct and resubmit.',
          onConfirm: () {
            if (mounted) {
              Navigator.of(context).pop(); // 关闭弹窗，保持激活弹窗打开
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        // 显示错误弹窗
        final activateItem = widget.activateList.firstWhere(
          (item) => item.productId == productId,
          orElse: () => Activate(
            challengeId: '',
            challengeName: '',
            productId: '',
            productName: '',
          ),
        );
        
        await ActivationResultDialogHelper.showFailureDialog(
          context: context,
          productName: activateItem.productName,
          challengeName: activateItem.challengeName.isNotEmpty ? activateItem.challengeName : null,
          message: 'Activation failed: ${e.toString()}',
          onConfirm: () {
            if (mounted) {
              Navigator.of(context).pop(); // 关闭弹窗，保持激活弹窗打开
            }
          },
        );
      }
    } finally {
      // 重置加载状态 - 检查组件是否仍然挂载
      if (mounted) {
        setState(() {
          _isSubmitting[productId] = false;
        });
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
        final mediaQuery = MediaQuery.of(context);
        final keyboardInset = mediaQuery.viewInsets.bottom;
        final screenHeight = mediaQuery.size.height;
        final double baseMax = (screenHeight * 0.75).clamp(240.0, screenHeight - 24.0);

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                child: Container(
                  color: Colors.black.withOpacity(0.3 * _fadeAnimation.value),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: keyboardInset),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                builder: (context, inset, _) {
                  return Transform.translate(
                    offset: Offset(0, 80 * _slideAnimation.value - inset),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: baseMax,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, -8),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: 36,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.card_giftcard,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Activate Activities',
                                        style: AppTextStyles.titleLarge.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        'Unlock your fitness adventure! 🚀',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: Column(
                                children: widget.activateList.map((activate) {
                                  return _buildProductCard(activate);
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(Activate activate) {
    final isSubmitting = _isSubmitting[activate.productId] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[25],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                        // 产品信息头部
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activate.productName,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (activate.challengeName.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 14,
                              color: Colors.orange[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                activate.challengeName,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.orange[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // 获取code提示按钮
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => CodeReminderSheet(
                            productName: activate.productName,
                            challengeName: activate.challengeName,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue[200]!,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.help_outline,
                          size: 16,
                          color: Colors.blue[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 激活码输入表单
            Form(
              key: _formKeys[activate.productId],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activation Code',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: _fieldKeys[activate.productId],
                    controller: _codeControllers[activate.productId],
                    focusNode: _focusNodes[activate.productId],
                    // 添加键盘相关配置
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: 'Enter activation code',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.red[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      suffixIcon: Icon(
                        Icons.key,
                        color: Colors.grey[400],
                        size: 18,
                      ),
                    ),
                                          validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter activation code';
                        }
                        if (value.trim().length < 6) {
                          return 'Activation code too short';
                        }
                        return null;
                      },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (value) {
                      if (_formKeys[activate.productId]?.currentState?.validate() == true) {
                        _submitActivation(activate.productId, value.trim());
                      }
                    },
                    // 输入时确保可见并保持与键盘的理想间距
                    onTap: () {
                      _scheduleEnsureVisible(activate.productId);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 激活按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : () {
                  if (_formKeys[activate.productId]?.currentState?.validate() == true) {
                    final code = _codeControllers[activate.productId]?.text.trim() ?? '';
                    _submitActivation(activate.productId, code);
                  }
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
                child: isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Activating...',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Activate',
                            style: TextStyle(
                              fontSize: 15, 
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
