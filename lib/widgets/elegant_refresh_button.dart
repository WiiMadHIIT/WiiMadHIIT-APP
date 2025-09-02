import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// 🎨 苹果风格优雅刷新按钮组件 - 通用模板
/// 
/// 使用方式：
/// ```dart
/// ElegantRefreshButton(
///   onRefresh: () => _refreshFunction(),
///   size: 200, // 可选，默认200
///   primaryColor: AppColors.primary, // 可选，默认使用主题色
/// )
/// ```
class ElegantRefreshButton extends StatefulWidget {
  final VoidCallback onRefresh;
  final double size;
  final Color? primaryColor;
  final Duration refreshDuration;
  final bool showStatusIndicator;

  const ElegantRefreshButton({
    super.key,
    required this.onRefresh,
    this.size = 200.0,
    this.primaryColor,
    this.refreshDuration = const Duration(milliseconds: 1500),
    this.showStatusIndicator = true,
  });

  @override
  State<ElegantRefreshButton> createState() => _ElegantRefreshButtonState();
}

class _ElegantRefreshButtonState extends State<ElegantRefreshButton> 
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isRefreshing = false;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    
    // 旋转动画控制器
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // 脉冲动画控制器
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // 旋转动画 - 无限循环
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
    
    // 脉冲动画 - 呼吸效果
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // 缩放动画
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // 启动脉冲动画
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// 处理刷新操作
  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
      _scale = 0.95;
    });
    
    // 启动旋转动画
    _rotationController.repeat();
    
    // 执行刷新
    widget.onRefresh();
    
    // 延迟停止旋转动画
    await Future.delayed(widget.refreshDuration);
    
    if (mounted) {
      _rotationController.stop();
      setState(() {
        _isRefreshing = false;
        _scale = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.primaryColor ?? AppColors.primary;
    final double buttonSize = widget.size;
    final double iconSize = buttonSize * 0.4; // 图标大小为按钮的40%
    final double backgroundSize = buttonSize * 0.8; // 背景光晕为按钮的80%
    
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: _handleRefresh,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // 🎨 苹果风格渐变背景
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.05),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            // 🎨 精致的边框
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            // 🎨 苹果风格阴影
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 🎨 背景光晕效果
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: backgroundSize,
                      height: backgroundSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            primaryColor.withOpacity(0.1),
                            primaryColor.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // 🎨 主图标容器
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Icon(
                        _isRefreshing ? Icons.refresh : Icons.refresh_rounded,
                        color: Colors.white,
                        size: iconSize * 0.45, // 图标大小为容器的45%
                      ),
                    );
                  },
                ),
              ),
              
              // 🎨 状态指示器
              if (_isRefreshing && widget.showStatusIndicator)
                Positioned(
                  top: buttonSize * 0.1, // 距离顶部10%
                  child: Container(
                    width: buttonSize * 0.03, // 指示器大小为按钮的3%
                    height: buttonSize * 0.03,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 