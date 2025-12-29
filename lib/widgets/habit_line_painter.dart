import 'package:flutter/material.dart';
import 'package:day_app/core/theme/app_colors.dart';

class HabitLinePainter extends CustomPainter {
  final double progress; // 0.0 .. 1.0
  final Color bgColor;

  HabitLinePainter(this.progress, this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    final clamped = progress.clamp(0.0, 1.0);
    final centerY = size.height / 2;

    const lineThickness = 8.0;
    const circleRadius = 8.0;

    // ---------- ЛИНИЯ ----------
    final bgPaint = Paint()
      ..color = bgColor.withOpacity(0.3)
      ..strokeWidth = lineThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = AppColors.accentBlue
      ..strokeWidth = lineThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final lineWidth = size.width * 0.8;
    final startX = (size.width - lineWidth) / 2;
    final endX = startX + lineWidth;
    final progressX = startX + lineWidth * clamped;

    canvas.drawLine(
      Offset(startX, centerY),
      Offset(endX, centerY),
      bgPaint,
    );

    canvas.drawLine(
      Offset(startX, centerY),
      Offset(progressX, centerY),
      progressPaint,
    );

    // ТОЧКА
    final circleCenter = Offset(progressX, centerY);

    canvas.drawCircle(
      circleCenter,
      circleRadius,
      Paint()..color = AppColors.accentBlue,
    );

    canvas.drawCircle(
      circleCenter,
      circleRadius - 4,
      Paint()..color = Colors.white,
    );

    // ПРОЦЕНТ
    final percent = (clamped * 100).round();

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$percent%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const bubblePaddingH = 8.0;
    const bubblePaddingV = 4.0;
    const bubbleRadius = 10.0;

    final bubbleWidth = textPainter.width + bubblePaddingH * 2;
    final bubbleHeight = textPainter.height + bubblePaddingV * 2;

    // позиция над точкой
    double bubbleX = progressX - bubbleWidth / 2;
    final bubbleY = centerY - circleRadius - bubbleHeight - 8;

    bubbleX = bubbleX.clamp(4.0, size.width - bubbleWidth - 4.0);

    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bubbleX, bubbleY, bubbleWidth, bubbleHeight),
      const Radius.circular(bubbleRadius),
    );

    final bubblePaint = Paint()..color = AppColors.accentBlue;

    canvas.drawRRect(bubbleRect, bubblePaint);

    textPainter.paint(
      canvas,
      Offset(
        bubbleX + bubblePaddingH,
        bubbleY + bubblePaddingV,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant HabitLinePainter old) =>
      old.progress != progress || old.bgColor != bgColor;
}
