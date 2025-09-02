import 'package:flutter/material.dart';

class GlassOverlay extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final double baseOpacity;
  final double edgeOpacity;
  final double centerOpacity;

  const GlassOverlay({
    super.key,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.child,
    this.baseOpacity = 0.15,
    this.edgeOpacity = 0.025,
    this.centerOpacity = 0.008,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      margin: margin,
      padding: padding,
      child: Stack(
        children: [
          // 第零层：基础黑色遮罩 - 让内容更清晰
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(baseOpacity),
            ),
          ),
          
          // 第一层：露珠基础玻璃 - 完全透明，像真正的露珠
          Container(
            decoration: BoxDecoration(
              // 露珠玻璃：中心完全透明，四周极轻微渐变
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.transparent,  // 中心完全透明
                  Colors.transparent,  // 中心区域保持透明
                  Colors.black.withOpacity(centerOpacity),  // 开始极轻微渐变
                  Colors.black.withOpacity(centerOpacity * 1.875),  // 渐变增强
                  Colors.black.withOpacity(edgeOpacity),  // 边缘极轻微渐变
                ],
                stops: const [0.0, 0.4, 0.7, 0.85, 1.0],
              ),
            ),
          ),
          
          // 第二层：水滴立体感 - 四周凸起，中间凹陷
          Container(
            decoration: BoxDecoration(
              // 水滴立体效果：四周凸起，中间凹陷
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.3,
                colors: [
                  Colors.transparent,  // 中心凹陷
                  Colors.transparent,  // 凹陷区域
                  Colors.black.withOpacity(centerOpacity * 1.5),  // 开始凸起
                  Colors.black.withOpacity(centerOpacity * 3.125),   // 凸起增强
                  Colors.black.withOpacity(edgeOpacity * 1.8),   // 边缘凸起
                ],
                stops: const [0.0, 0.45, 0.7, 0.85, 1.0],
              ),
            ),
          ),
          
          // 第三层：丝丝黑色光泽 - 多条微妙的光泽线条
          Container(
            decoration: BoxDecoration(
              // 丝丝光泽：多条微妙的黑色光泽线条
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  // 左上角光泽线条
                  Colors.black.withOpacity(centerOpacity * 4.375),
                  Colors.transparent,
                  Colors.black.withOpacity(centerOpacity * 2.25),
                  Colors.transparent,
                  // 中间光泽线条
                  Colors.black.withOpacity(centerOpacity * 3.125),
                  Colors.transparent,
                  Colors.black.withOpacity(centerOpacity * 1.875),
                  Colors.transparent,
                  // 右下角光泽线条
                  Colors.black.withOpacity(centerOpacity * 3.75),
                  Colors.transparent,
                  Colors.black.withOpacity(centerOpacity * 2.5),
                ],
                stops: const [0.0, 0.12, 0.22, 0.32, 0.45, 0.58, 0.68, 0.78, 0.85, 0.92, 1.0],
              ),
            ),
          ),
          
          // 第四层：对角线光泽 - 增强水滴的立体感
          Container(
            decoration: BoxDecoration(
              // 对角线光泽：增强水滴的立体感
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.black.withOpacity(centerOpacity * 2.5),
                  Colors.transparent,
                  Colors.black.withOpacity(centerOpacity * 1.875),
                  Colors.transparent,
                  Colors.black.withOpacity(centerOpacity * 1.5),
                ],
                stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
              ),
            ),
          ),
          
          // 第五层：垂直光泽 - 营造水滴的流动感
          Container(
            decoration: BoxDecoration(
              // 垂直光泽：营造水滴的流动感
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(centerOpacity * 2.25),
                  Colors.transparent,
                  Colors.black.withOpacity(centerOpacity * 1.5),
                  Colors.transparent,
                  Colors.black.withOpacity(centerOpacity * 1.875),
                ],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
            ),
          ),
          
          // 第六层：水平光泽 - 增强水滴边缘的立体感
          Container(
            decoration: BoxDecoration(
              // 水平光泽：增强水滴边缘的立体感
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(centerOpacity * 1.875),
                  Colors.transparent,
                  Colors.black.withOpacity(centerOpacity * 1.25),
                  Colors.transparent,
                  Colors.black.withOpacity(centerOpacity * 2.25),
                ],
                stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
              ),
            ),
          ),
          
          // 第七层：露珠反光 - 微妙的光泽效果
          Container(
            decoration: BoxDecoration(
              // 露珠反光：微妙的光泽效果，像露珠表面的光
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(centerOpacity * 2.25),  // 左上角反光
                  Colors.transparent,
                  Colors.white.withOpacity(centerOpacity * 1.5),  // 中间反光
                  Colors.transparent,
                  Colors.white.withOpacity(centerOpacity * 1.875),   // 右下角反光
                ],
                stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
              ),
            ),
          ),
          
          // 第八层：精致边框 - 水滴边缘的精致感
          Container(
            decoration: BoxDecoration(
              // 水滴边框：精致的边缘效果
              border: Border.all(
                color: Colors.white.withOpacity(centerOpacity * 7.5),
                width: 0.3,
              ),
            ),
          ),
          
          // 第九层：立体阴影 - 水滴的悬浮感
          Container(
            decoration: BoxDecoration(
              // 水滴阴影：营造悬浮立体感
              boxShadow: [
                // 主阴影：水滴的立体感
                BoxShadow(
                  color: Colors.black.withOpacity(centerOpacity * 5.0),
                  blurRadius: 35,
                  spreadRadius: 0,
                  offset: const Offset(0, 15),
                ),
                // 内光晕：水滴内部的光泽
                BoxShadow(
                  color: Colors.white.withOpacity(centerOpacity),
                  blurRadius: 25,
                  spreadRadius: 0,
                  offset: const Offset(0, -5),
                ),
                // 边缘光晕：水滴边缘的光泽
                BoxShadow(
                  color: Colors.white.withOpacity(centerOpacity * 1.5),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          
          // 如果有子组件，显示在最上层
          if (child != null) child!,
        ],
      ),
    );
  }
}

// 预设的玻璃遮罩样式
class GlassOverlayPresets {
  // 轻量级玻璃遮罩
  static GlassOverlay light({
    double? width,
    double? height,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Widget? child,
  }) {
    return GlassOverlay(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      child: child,
      baseOpacity: 0.1,
      edgeOpacity: 0.015,
      centerOpacity: 0.005,
    );
  }
  
  // 标准玻璃遮罩
  static GlassOverlay standard({
    double? width,
    double? height,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Widget? child,
  }) {
    return GlassOverlay(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      child: child,
      baseOpacity: 0.15,
      edgeOpacity: 0.025,
      centerOpacity: 0.008,
    );
  }
  
  // 重度玻璃遮罩
  static GlassOverlay heavy({
    double? width,
    double? height,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Widget? child,
  }) {
    return GlassOverlay(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      child: child,
      baseOpacity: 0.25,
      edgeOpacity: 0.04,
      centerOpacity: 0.015,
    );
  }
  
  // 露珠玻璃遮罩（当前使用的样式）
  static GlassOverlay dewdrop({
    double? width,
    double? height,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Widget? child,
  }) {
    return GlassOverlay(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      child: child,
      baseOpacity: 0.15,
      edgeOpacity: 0.025,
      centerOpacity: 0.008,
    );
  }
}
