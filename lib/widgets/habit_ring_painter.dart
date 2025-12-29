import 'package:flutter/material.dart';
import 'package:day_app/core/theme/app_colors.dart';

class HabitRingPainter extends CustomPainter {
  final double progress;
  final Color bgColor;

  HabitRingPainter(this.progress, this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    final bgPaint = Paint()
      ..color = bgColor.withOpacity(0.3)
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = AppColors.accentBlue
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = 6.28318530718 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant HabitRingPainter old) => old.progress != progress || old.bgColor != bgColor;
}