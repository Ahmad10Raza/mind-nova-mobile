import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/sleep_sound.dart';
import '../../constants/sleep_colors.dart';
import 'night_sky_background.dart';

class DynamicAtmosphereBackground extends StatelessWidget {
  final ThemeType theme;
  final double animationValue;
  final Widget child;

  const DynamicAtmosphereBackground({
    super.key,
    required this.theme,
    required this.animationValue,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Night Sky
        NightSkyBackground(
          animationValue: animationValue,
          showMoon: theme == ThemeType.space || theme == ThemeType.none,
          child: const SizedBox.expand(),
        ),

        // Theme Specific Overlays
        _buildThemeOverlay(context),

        // Content
        child,
      ],
    );
  }

  Widget _buildThemeOverlay(BuildContext context) {
    switch (theme) {
      case ThemeType.rain:
        return _RainOverlay(animationValue: animationValue);
      case ThemeType.fire:
        return _FireOverlay(animationValue: animationValue);
      case ThemeType.space:
        return _SpaceOverlay(animationValue: animationValue);
      case ThemeType.none:
        return const SizedBox.shrink();
    }
  }
}

class _RainOverlay extends StatelessWidget {
  final double animationValue;
  const _RainOverlay({required this.animationValue});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _RainPainter(animationValue),
    );
  }
}

class _RainPainter extends CustomPainter {
  final double progress;
  _RainPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    final random = Random(42);
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final startY = (random.nextDouble() * size.height + progress * size.height) % size.height;
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, startY + 20),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FireOverlay extends StatelessWidget {
  final double animationValue;
  const _FireOverlay({required this.animationValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, 0.5),
          radius: 1.5,
          colors: [
            Colors.orange.withValues(alpha: 0.05 * (0.8 + 0.2 * sin(animationValue * 2 * pi))),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _SpaceOverlay extends StatelessWidget {
  final double animationValue;
  const _SpaceOverlay({required this.animationValue});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // NightSkyBackground already handles stars
  }
}
