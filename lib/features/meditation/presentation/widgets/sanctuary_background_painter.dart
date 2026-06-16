import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';

class SanctuaryBackgroundPainter extends CustomPainter {
  final double progress;
  final double pulse;

  SanctuaryBackgroundPainter(this.progress, this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    // Deep midnight base gradient
    final bgPaint = Paint()..style = PaintingStyle.fill;

    // Top-right purple glow
    bgPaint.shader = RadialGradient(
      colors: [
        AppColors.novaPurpleDark.withAlpha((0.35 * 255).toInt()),
        Colors.transparent,
      ],
      radius: 1,
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.85, size.height * 0.08),
      radius: size.width * 0.7,
    ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Bottom-left teal glow
    bgPaint.shader = RadialGradient(
      colors: [
        AppColors.calmTeal.withAlpha((0.12 * 255).toInt()),
        Colors.transparent,
      ],
      radius: 1,
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.1, size.height * 0.7),
      radius: size.width * 0.6,
    ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Mid purple accent (pulsing)
    bgPaint.shader = RadialGradient(
      colors: [
        AppColors.novaPurple.withAlpha((pulse * 0.15 * 255).toInt()),
        Colors.transparent,
      ],
      radius: 1,
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.5, size.height * 0.4),
      radius: size.width * 0.5,
    ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Floating particles
    final rng = math.Random(42);
    for (int i = 0; i < 25; i++) {
      final angle = (progress * 2 * math.pi) + (i * math.pi * 2 / 25);
      final r = size.width * 0.25 + rng.nextDouble() * size.width * 0.35;
      final cx = size.width / 2 + math.cos(angle) * r * 0.6;
      final cy = size.height * 0.3 + math.sin(angle * 0.7 + i) * 100;

      final isPurple = i % 3 != 0;
      final baseColor = isPurple ? AppColors.novaPurple : AppColors.calmTeal;
      final opacity = 0.04 + rng.nextDouble() * 0.06;

      final particlePaint = Paint()
        ..color = baseColor.withAlpha((opacity * 255).toInt())
        ..style = PaintingStyle.fill;

      final radius = 1.5 + rng.nextDouble() * 3.5;
      canvas.drawCircle(Offset(cx, cy), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SanctuaryBackgroundPainter old) => true;
}
