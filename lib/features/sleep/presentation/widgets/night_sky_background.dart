import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/sleep_colors.dart';
import 'floating_stars_painter.dart';

/// A reusable full-screen night sky background widget.
/// Contains animated gradient, stars, and a subtle moon glow.
/// Used as the base layer for all Sleep Mode screens.
class NightSkyBackground extends StatelessWidget {
  final double animationValue;
  final bool showMoon;
  final Widget child;

  const NightSkyBackground({
    super.key,
    required this.animationValue,
    required this.child,
    this.showMoon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ─── Base Gradient ──────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: SleepColors.nightSkyGradient,
          ),
        ),

        // ─── Star Field ────────────────────────────────────
        RepaintBoundary(
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            painter: FloatingStarsPainter(
              animationValue: animationValue,
              starCount: 45,
            ),
          ),
        ),

        // ─── Moon Glow ─────────────────────────────────────
        if (showMoon)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.06,
            right: MediaQuery.of(context).size.width * 0.08,
            child: _buildMoonGlow(),
          ),

        // ─── Content Layer ─────────────────────────────────
        child,
      ],
    );
  }

  Widget _buildMoonGlow() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            SleepColors.moonGold.withOpacity(0.15),
            SleepColors.moonGold.withOpacity(0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: SleepColors.moonGold.withOpacity(0.1),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SleepColors.moonGold.withOpacity(0.3),
            boxShadow: [
              BoxShadow(
                color: SleepColors.moonGold.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
