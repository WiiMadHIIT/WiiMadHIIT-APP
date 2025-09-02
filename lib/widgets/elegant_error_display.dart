import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_colors.dart';

/// 🎨 苹果风格轻松幽默提示界面组件 - 通用模板
/// 
/// 使用方式：
/// ```dart
/// ElegantErrorDisplay(
///   error: 'Network error occurred',
///   onRetry: () => _retryFunction(),
///   title: 'Custom Title', // 可选
///   showHelpText: true, // 可选，默认true
/// )
/// ```
class ElegantErrorDisplay extends StatefulWidget {
  final String error;
  final VoidCallback onRetry;
  final String? title;
  final bool showHelpText;
  final String? customHelpText;
  final Widget? customIcon;
  final Color? iconColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const ElegantErrorDisplay({
    super.key,
    required this.error,
    required this.onRetry,
    this.title,
    this.showHelpText = true,
    this.customHelpText,
    this.customIcon,
    this.iconColor,
    this.margin,
    this.padding,
  });

  @override
  State<ElegantErrorDisplay> createState() => _ElegantErrorDisplayState();
}

class _ElegantErrorDisplayState extends State<ElegantErrorDisplay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    
    // 淡入动画控制器
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 弹跳动画控制器
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // 脉冲动画控制器
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // 淡入动画
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    
    // 弹跳动画
    _bounceAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    // 脉冲动画
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // 启动动画序列
    _startAnimationSequence();
    
    // 启动脉冲动画
    _pulseController.repeat(reverse: true);
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _bounceController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// 处理重试操作
  Future<void> _handleRetry() async {
    if (_isRetrying) return;
    
    setState(() {
      _isRetrying = true;
    });
    
    // 执行重试
    widget.onRetry();
    
    // 延迟重置状态
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (mounted) {
      setState(() {
        _isRetrying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getErrorInfo(widget.error);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _bounceAnimation,
        child: Container(
          margin: widget.margin ?? const EdgeInsets.all(24),
          padding: widget.padding ?? const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            // 🎨 苹果风格简约背景 - 优化视频背景下的可读性
            color: Colors.black.withOpacity(0.5), // 从 0.08 提升到 0.5，确保在视频背景下清晰可见
            border: Border.all(
              color: Colors.white.withOpacity(0.15), // 从 0.15 提升到 0.15，增强边框可见性
              width: 1.5, // 从 1 提升到 1.5，增强边框强度
            ),
                         // 🎨 精致的阴影效果 - 增强深度感
             boxShadow: [
               BoxShadow(
                 color: Colors.black.withOpacity(0.35), // 从 0.12 提升到 0.35，增强阴影深度
                 blurRadius: 32, // 从 24 提升到 32，增强模糊效果
                 offset: const Offset(0, 16), // 从 12 提升到 16，增强阴影偏移
                 spreadRadius: 0,
               ),
               // 🎨 新增：顶部高光效果，增强内容区域的立体感
               BoxShadow(
                 color: Colors.white.withOpacity(0.12),
                 blurRadius: 12,
                 offset: const Offset(0, -4),
                 spreadRadius: 0,
               ),
             ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🎨 轻松图标容器
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (widget.iconColor ?? errorInfo.color).withOpacity(0.15),
                        border: Border.all(
                          color: (widget.iconColor ?? errorInfo.color).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: widget.customIcon ?? Icon(
                        errorInfo.icon,
                        color: widget.iconColor ?? errorInfo.color,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // 🎨 轻松标题
              Text(
                widget.title ?? errorInfo.title,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // 🎨 轻松描述
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15), // 从 0.06 提升到 0.15，增强描述区域可见性
                  borderRadius: BorderRadius.circular(16),
                  // 🎨 新增：描述区域边框，增强层次感
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  errorInfo.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.95), // 从 0.85 提升到 0.95，确保最佳可读性
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 🎨 重试按钮
              _RetryButton(
                onRetry: _handleRetry,
                isRetrying: _isRetrying,
                buttonText: errorInfo.buttonText,
              ),
              
              // 🎨 帮助提示（可选）
              if (widget.showHelpText) ...[
                const SizedBox(height: 16),
                Text(
                  widget.customHelpText ?? errorInfo.helpText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.7), // 从 0.5 提升到 0.7，增强帮助文本可读性
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 🎨 智能错误信息处理 - 轻松幽默风格
  _ErrorInfo _getErrorInfo(String error) {
    final lowerError = error.toLowerCase();
    
    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return _ErrorInfo(
        title: 'Oops! Connection hiccup',
        message: 'Looks like the internet took a coffee break. Let\'s give it another shot!',
        icon: Icons.wifi_off_rounded,
        color: const Color(0xFF64B5F6),
        buttonText: 'Try Again',
        helpText: 'Sometimes even the internet needs a moment to wake up ☕',
      );
    } else if (lowerError.contains('timeout')) {
      return _ErrorInfo(
        title: 'Taking its sweet time',
        message: 'This is taking longer than expected. Maybe it\'s stuck in traffic?',
        icon: Icons.timer_outlined,
        color: const Color(0xFFFFB74D),
        buttonText: 'Give Another Go',
        helpText: 'Patience is a virtue, but we can try again! 🚗',
      );
    } else if (lowerError.contains('server') || lowerError.contains('500')) {
      return _ErrorInfo(
        title: 'Server is having a moment',
        message: 'Our servers are feeling a bit overwhelmed. Let\'s try again in a bit!',
        icon: Icons.cloud_off_rounded,
        color: const Color(0xFFE57373),
        buttonText: 'Retry Now',
        helpText: 'Even servers need a breather sometimes 😅',
      );
    } else if (lowerError.contains('not found') || lowerError.contains('404')) {
      return _ErrorInfo(
        title: 'Lost in the digital maze',
        message: 'We looked everywhere, but this page seems to have gone exploring!',
        icon: Icons.explore_outlined,
        color: const Color(0xFF81C784),
        buttonText: 'Find It Again',
        helpText: 'Digital adventures can be unpredictable 🗺️',
      );
    } else if (lowerError.contains('unauthorized') || lowerError.contains('401')) {
      return _ErrorInfo(
        title: 'Access denied, but nicely',
        message: 'Looks like you need to sign in first. No worries, it happens to the best of us!',
        icon: Icons.lock_outline_rounded,
        color: const Color(0xFFFFB74D),
        buttonText: 'Sign In',
        helpText: 'Security first, adventure second! 🔐',
      );
    } else {
      return _ErrorInfo(
        title: 'Well, that was unexpected',
        message: 'Something unexpected happened. But don\'t worry, we\'re on it!',
        icon: Icons.psychology_outlined,
        color: const Color(0xFFBA68C8),
        buttonText: 'Try Again',
        helpText: 'Life is full of surprises, even in apps! 🎭',
      );
    }
  }
}

/// 🎨 错误信息数据结构
class _ErrorInfo {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final String buttonText;
  final String helpText;

  _ErrorInfo({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.buttonText,
    required this.helpText,
  });
}

/// 🎨 苹果风格轻松重试按钮组件
class _RetryButton extends StatefulWidget {
  final VoidCallback onRetry;
  final bool isRetrying;
  final String buttonText;

  const _RetryButton({
    required this.onRetry,
    required this.isRetrying,
    required this.buttonText,
  });

  @override
  State<_RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<_RetryButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isRetrying) return;
    
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    if (widget.isRetrying) {
      _rotationController.repeat();
    }
    
    widget.onRetry();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _handleTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.9),
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isRetrying) ...[
                    AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 2 * 3.14159,
                          child: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Trying...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 