import 'package:flutter/material.dart';

// 圆形进度条绘制
class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Gradient? gradient;
  final Color trackColor;
  final Color shadow;
  final double strokeWidth;
  CircleProgressPainter({
    required this.progress,
    required this.color,
    this.gradient,
    required this.trackColor,
    required this.shadow,
    this.strokeWidth = 14,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint track = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint fg = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2)
      ..strokeCap = StrokeCap.round;
    if (gradient != null) {
      fg.shader = gradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    }
    final Paint glow = Paint()
      ..color = shadow
      ..strokeWidth = strokeWidth + 6
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    // 轨迹
    canvas.drawCircle(center, radius, track);
    // glow
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.1415926/2, 2 * 3.1415926 * progress, false, glow);
    // 主进度
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.1415926/2, 2 * 3.1415926 * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}