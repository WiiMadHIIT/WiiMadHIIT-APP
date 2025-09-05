import 'package:flutter/material.dart';
import 'dart:math' as math;
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
  final String? hintText; // 新增：提示文字
  final bool canRefresh; // 新增：是否可以刷新

  const ElegantRefreshButton({
    super.key,
    required this.onRefresh,
    this.size = 200.0,
    this.primaryColor,
    this.refreshDuration = const Duration(milliseconds: 1500),
    this.showStatusIndicator = true,
    this.hintText, // 新增：提示文字参数
    this.canRefresh = true, // 新增：是否可以刷新，默认可以
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
        child: SizedBox(
          width: buttonSize,
          height: buttonSize, // 恢复原始高度，圆形文字不需要额外空间
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 🎨 按钮背景装饰
              Positioned(
                top: 0,
                left: 0,
                right: 0,
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
                ),
              ),
              
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
                  color: primaryColor.withOpacity(0.9), // 始终显示为可刷新状态
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
              
              // 🎨 提示文字 - 围绕主图标容器底部圆弧显示
              if (widget.hintText != null)
                Positioned.fill(
                  child: CustomPaint(
                    painter: CircularTextPainter(
                      text: widget.hintText!,
                      textColor: Colors.white, // 始终显示为可刷新状态
                      radius: (buttonSize / 2) * 0.8, // 使用按钮半径的80%，确保在边界内
                      fontSize: 9, // 稍微减小字体，让文字更紧凑
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

/// 🎨 圆形文字绘制器
class CircularTextPainter extends CustomPainter {
  final String text;
  final Color textColor;
  final double radius;
  final double fontSize;

  CircularTextPainter({
    required this.text,
    required this.textColor,
    required this.radius,
    required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 确保圆心在画布中心
    final center = Offset(size.width / 2, size.height / 2);
    
    // 创建文字样式
    final textStyle = TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
    
    // 创建文字测量器
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // 计算文字总宽度
    final textWidth = textPainter.width;
    final textLength = text.length;
    
    // 计算底部圆弧的角度范围（从右侧到左侧）
    // 使用更小的角度范围，主要集中在底部
    final startAngle = math.pi * 0.25; // 从约45度开始（右下角）
    final endAngle = math.pi * 0.75;   // 到约135度结束（左下角）
    final totalAngle = endAngle - startAngle; // 角度递增
    
    // 计算每个字符的角度间隔
    final anglePerChar = textLength > 1 ? totalAngle / (textLength - 1) : 0.0;
    
    // 绘制每个字符
    for (int i = 0; i < textLength; i++) {
      final char = text[i];
      final angle = textLength > 1 ? startAngle + (i * anglePerChar) : startAngle; // 从小到大，让文字从右到左排列
      
      // 计算字符位置
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      // 创建单个字符的TextPainter
      final charPainter = TextPainter(
        text: TextSpan(text: char, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      charPainter.layout();
      
      // 保存画布状态
      canvas.save();
      
      // 移动到字符位置
      canvas.translate(x, y);
      
      // 旋转画布使字符正着显示（不朝向圆心）
      canvas.rotate(angle - math.pi / 2);
      
      // 绘制字符
      charPainter.paint(canvas, Offset(-charPainter.width / 2, -charPainter.height / 2));
      
      // 恢复画布状态
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is CircularTextPainter &&
        (oldDelegate.text != text ||
            oldDelegate.textColor != textColor ||
            oldDelegate.radius != radius ||
            oldDelegate.fontSize != fontSize);
  }
}