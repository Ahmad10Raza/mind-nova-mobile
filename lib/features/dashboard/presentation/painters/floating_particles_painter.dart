import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Lightweight floating particle background painter.
/// Kept to ≤15 particles for performance. Wrap in RepaintBoundary.
class FloatingParticlesPainter extends CustomPainter {
  final double animationValue; // 0.0 → 1.0 looping
  final Color baseColor;
  final int particleCount;

  FloatingParticlesPainter({
    required this.animationValue,
    this.baseColor = const Color(0xFF5E4B8B),
    this.particleCount = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42); // Fixed seed for deterministic positions

    for (int i = 0; i < particleCount; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final radius = 2.0 + rng.nextDouble() * 4;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final phase = rng.nextDouble() * math.pi * 2;

      // Gentle sinusoidal float
      final dx = math.sin(animationValue * math.pi * 2 * speed + phase) * 8;
      final dy = math.cos(animationValue * math.pi * 2 * speed * 0.7 + phase) * 6;

      final opacity = 0.06 + rng.nextDouble() * 0.08;

      final paint = Paint()
        ..color = baseColor.withValues(alpha: opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.8);

      canvas.drawCircle(
        Offset(baseX + dx, baseY + dy),
        radius,
        paint,
      );
    }

    // A few sparkle dots (tiny, high opacity)
    for (int i = 0; i < 5; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final twinkle = (math.sin(animationValue * math.pi * 4 + i * 1.3) + 1) / 2;

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.15 * twinkle);

      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FloatingParticlesPainter old) {
    return old.animationValue != animationValue;
  }
}
