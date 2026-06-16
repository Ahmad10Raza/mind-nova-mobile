import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/sleep_colors.dart';

/// Renders an animated star field with twinkling stars and occasional shooting stars.
class FloatingStarsPainter extends CustomPainter {
  final double animationValue;
  final int starCount;
  final Random _random = Random(42); // Fixed seed for consistent star positions

  FloatingStarsPainter({
    required this.animationValue,
    this.starCount = 40,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawStars(canvas, size);
    _drawShootingStar(canvas, size);
  }

  void _drawStars(Canvas canvas, Size size) {
    for (int i = 0; i < starCount; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height * 0.7; // Stars in upper 70%
      final baseRadius = _random.nextDouble() * 1.8 + 0.3;

      // Each star twinkles at its own independent frequency
      final twinklePhase = _random.nextDouble() * 2 * pi;
      final twinkleSpeed = _random.nextDouble() * 2 + 1;
      final twinkle = sin(animationValue * twinkleSpeed * 2 * pi + twinklePhase);
      final opacity = (0.3 + twinkle * 0.35).clamp(0.05, 0.95);
      final radius = baseRadius * (0.8 + twinkle * 0.2);

      final paint = Paint()
        ..color = SleepColors.starWhite.withOpacity(opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.5);

      canvas.drawCircle(Offset(x, y), radius, paint);

      // Bright stars get a secondary glow
      if (baseRadius > 1.2) {
        final glowPaint = Paint()
          ..color = SleepColors.lavenderGlow.withOpacity(opacity * 0.15)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 3);
        canvas.drawCircle(Offset(x, y), radius * 2, glowPaint);
      }
    }
  }

  void _drawShootingStar(Canvas canvas, Size size) {
    // Show a shooting star every ~3 seconds (based on animation cycle)
    final shootPhase = (animationValue * 5) % 1.0;
    if (shootPhase > 0.85) {
      final progress = (shootPhase - 0.85) / 0.15; // 0→1 during the brief window
      final startX = size.width * 0.2;
      final startY = size.height * 0.1;
      final endX = size.width * 0.7;
      final endY = size.height * 0.35;

      final currentX = startX + (endX - startX) * progress;
      final currentY = startY + (endY - startY) * progress;

      final trailPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.6 * (1 - progress)),
          ],
        ).createShader(Rect.fromPoints(
          Offset(currentX - 40, currentY - 15),
          Offset(currentX, currentY),
        ))
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(currentX - 40, currentY - 15),
        Offset(currentX, currentY),
        trailPaint,
      );

      // Head glow
      final headPaint = Paint()
        ..color = Colors.white.withOpacity(0.8 * (1 - progress))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(currentX, currentY), 2, headPaint);
    }
  }

  @override
  bool shouldRepaint(covariant FloatingStarsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
