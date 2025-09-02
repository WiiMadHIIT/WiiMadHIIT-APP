import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// 用户信息编辑弹窗 - 苹果风格设计
class UserProfileEditSheet extends StatefulWidget {
  final String currentUsername;
  final String currentEmail;
  final Future<bool> Function(String username, String email) onSave;
  final VoidCallback? onCancel;

  const UserProfileEditSheet({
    Key? key,
    required this.currentUsername,
    required this.currentEmail,
    required this.onSave,
    this.onCancel,
  }) : super(key: key);

  @override
  State<UserProfileEditSheet> createState() => _UserProfileEditSheetState();
}

class _UserProfileEditSheetState extends State<UserProfileEditSheet>
    with SingleTickerProviderStateMixin {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late FocusNode _usernameFocusNode;
  late FocusNode _emailFocusNode;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isUsernameValid = true;
  bool _isEmailValid = true;
  bool _hasChanges = false;
  bool _isSaving = false;
  bool _showSuccessMessage = false;

  // 计算表单区域的自适应宽度，避免小屏或分屏下横向溢出
  double _formWidth(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double horizontalPadding = 48.0; // Safe padding for sheet
    const double minWidth = 280.0;
    const double maxWidth = 400.0;
    final double target = screenWidth - horizontalPadding;
    return target.clamp(minWidth, maxWidth).toDouble();
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
    _emailController = TextEditingController(text: widget.currentEmail);
    _usernameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    
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

    _usernameController.addListener(_onTextChanged);
    _emailController.addListener(_onTextChanged);
    
    // 安全启动动画
    if (mounted) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    // 移除监听器以防止内存泄漏
    _usernameController.removeListener(_onTextChanged);
    _emailController.removeListener(_onTextChanged);
    
    // 释放控制器和焦点节点
    _usernameController.dispose();
    _emailController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    
    // 释放动画控制器
    _animationController.dispose();
    
    super.dispose();
  }

  void _onTextChanged() {
    final usernameChanged = _usernameController.text != widget.currentUsername;
    final emailChanged = _emailController.text != widget.currentEmail;
    
    setState(() {
      _hasChanges = usernameChanged || emailChanged;
    });
  }

  bool _validateUsername(String username) {
    return username.trim().isNotEmpty && username.length >= 2;
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  void _validateFields() {
    setState(() {
      _isUsernameValid = _validateUsername(_usernameController.text);
      _isEmailValid = _validateEmail(_emailController.text);
    });
  }

  Future<void> _handleSave() async {
    _validateFields();
    
    if (!_isUsernameValid || !_isEmailValid) {
      return;
    }

    FocusScope.of(context).unfocus();
    
    // 显示加载状态
    setState(() {
      _isSaving = true;
    });
    
    try {
      // 调用保存回调，等待结果
      final success = await widget.onSave(
        _usernameController.text.trim(),
        _emailController.text.trim(),
      );
      
      // 检查组件是否仍然挂载
      if (!mounted) return;
      
      if (success) {
        // 保存成功，显示成功提示
        setState(() {
          _showSuccessMessage = true;
        });
        
        // 延迟关闭弹窗，让用户看到成功提示
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _animationController.reverse();
          }
        });
      } else {
        // 保存失败，保持弹窗打开，让用户看到错误信息
        // 错误处理已经在外部完成
      }
    } catch (e) {
      // 处理异常，保持弹窗打开
      if (mounted) {
        print('Error saving profile: $e');
      }
    } finally {
      // 重置加载状态 - 检查组件是否仍然挂载
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _handleCancel() {
    FocusScope.of(context).unfocus();
    // 先调用回调，让外部处理关闭逻辑
    widget.onCancel?.call();
    // 然后执行关闭动画
    if (mounted) {
      _animationController.reverse();
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
        
        return Container(
          color: Colors.black.withOpacity(0.4 * _fadeAnimation.value),
          child: Column(
            children: [
              // 蒙层区域 - 点击关闭
              Expanded(
                child: GestureDetector(
                  onTap: _handleCancel,
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.transparent),
                ),
              ),
              
              // 弹窗内容区域 - 键盘感知
              AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(bottom: keyboardInset),
                child: Transform.translate(
                  offset: Offset(0, 100 * _slideAnimation.value),
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      // 下滑手势检测 - 更灵敏
                      if (details.delta.dy > 5) {
                        _handleCancel();
                      }
                    },
                    onVerticalDragEnd: (details) {
                      // 如果下滑速度足够快，也关闭弹窗
                      if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
                        _handleCancel();
                      }
                    },
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: (screenHeight * 0.8).clamp(400.0, screenHeight - keyboardInset - 32.0),
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: SafeArea(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: keyboardInset > 0 ? 16 : 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 拖拽指示器 - 可点击关闭
                              GestureDetector(
                                onTap: _handleCancel,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  width: 36,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              
                              // 标题和修改状态
                              Padding(
                                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                                child: Row(
                                  children: [
                                    Text(
                                      'Edit Profile',
                                      style: AppTextStyles.headlineSmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    if (_hasChanges && !_showSuccessMessage)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Modified',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    if (_showSuccessMessage)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.green.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green[600],
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                'Updated Successfully!',
                                                style: AppTextStyles.labelSmall.copyWith(
                                                  color: Colors.green[600],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              
                              // 用户名输入框
                              Padding(
                                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Username',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: _formWidth(context),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _isUsernameValid 
                                              ? Colors.grey[200]! 
                                              : Colors.red[300]!,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _usernameController,
                                        focusNode: _usernameFocusNode,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter your username',
                                          hintStyle: AppTextStyles.bodyLarge.copyWith(
                                            color: Colors.grey[400],
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                          border: InputBorder.none,
                                          suffixIcon: _usernameController.text.isNotEmpty
                                              ? IconButton(
                                                  icon: Icon(
                                                    Icons.clear,
                                                    color: Colors.grey[400],
                                                    size: 20,
                                                  ),
                                                  onPressed: () {
                                                    _usernameController.clear();
                                                    _usernameFocusNode.requestFocus();
                                                  },
                                                )
                                              : null,
                                        ),
                                        onChanged: (value) {
                                          if (_isUsernameValid != _validateUsername(value)) {
                                            setState(() {
                                              _isUsernameValid = _validateUsername(value);
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    if (!_isUsernameValid)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6, left: 4),
                                        child: Text(
                                          'Username must be at least 2 characters',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: Colors.red[400],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              
                              // 邮箱输入框
                              Padding(
                                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: _formWidth(context),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _isEmailValid 
                                              ? Colors.grey[200]! 
                                              : Colors.red[300]!,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _emailController,
                                        focusNode: _emailFocusNode,
                                        keyboardType: TextInputType.emailAddress,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter your email',
                                          hintStyle: AppTextStyles.bodyLarge.copyWith(
                                            color: Colors.grey[400],
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                          border: InputBorder.none,
                                          suffixIcon: _emailController.text.isNotEmpty
                                              ? IconButton(
                                                  icon: Icon(
                                                    Icons.clear,
                                                    color: Colors.grey[400],
                                                    size: 20,
                                                  ),
                                                  onPressed: () {
                                                    _emailController.clear();
                                                    _emailFocusNode.requestFocus();
                                                  },
                                                )
                                              : null,
                                        ),
                                        onChanged: (value) {
                                          if (_isEmailValid != _validateEmail(value)) {
                                            setState(() {
                                              _isEmailValid = _validateEmail(value);
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    if (!_isEmailValid)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6, left: 4),
                                        child: Text(
                                          'Please enter a valid email address',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: Colors.red[400],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              
                              // 按钮组
                              Padding(
                                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: _handleCancel,
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: AppTextStyles.labelLarge.copyWith(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: (_hasChanges && _isUsernameValid && _isEmailValid && !_isSaving)
                                            ? _handleSave
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          disabledBackgroundColor: Colors.grey[300],
                                          disabledForegroundColor: Colors.grey[500],
                                        ),
                                        child: _isSaving
                                            ? Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      'Saving...',
                                                      style: AppTextStyles.labelLarge.copyWith(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Text(
                                                'Save Changes',
                                                style: AppTextStyles.labelLarge.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
