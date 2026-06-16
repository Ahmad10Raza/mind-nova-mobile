import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/sleep_colors.dart';

/// Animated moon orb that expands/contracts with breathing rhythm.
/// Central visual for the Sleep Breathing experience.
class MoonBreathingWidget extends StatelessWidget {
  final double breathProgress; // 0.0 - 1.0 (maps to expand/contract)
  final String phaseText; // "Breathe In", "Hold", "Breathe Out"
  final int secondsRemaining;

  const MoonBreathingWidget({
    super.key,
    required this.breathProgress,
    required this.phaseText,
    this.secondsRemaining = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Map breath progress to scale
    final scale = 0.6 + (breathProgress * 0.6); // 0.6 -> 1.2
    final glowOpacity = 0.1 + (breathProgress * 0.25);
    final glowRadius = 30.0 + (breathProgress * 60);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── Moon Orb ──────────────────────────────────
        SizedBox(
          width: 280,
          height: 280,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Outer glow ring
                    boxShadow: [
                      BoxShadow(
                        color: SleepColors.lavenderGlow.withOpacity(glowOpacity),
                        blurRadius: glowRadius,
                        spreadRadius: glowRadius * 0.3,
                      ),
                      BoxShadow(
                        color: SleepColors.moonGold.withOpacity(glowOpacity * 0.5),
                        blurRadius: glowRadius * 0.6,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          SleepColors.moonGold.withOpacity(0.8),
                          SleepColors.moonGold.withOpacity(0.4),
                          SleepColors.lavenderGlow.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        stops: const [0.2, 0.5, 0.75, 1.0],
                      ),
                    ),
                    // Inner moon
                    child: Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: SleepColors.moonGold.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                              color: SleepColors.moonGold.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        // Crescent shadow for depth
                        child: Stack(
                          children: [
                            Positioned(
                              top: 12,
                              left: 18,
                              child: Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: SleepColors.deepNavy.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 48),

        // ─── Phase Text ────────────────────────────────
        Text(
          phaseText,
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: SleepColors.textPrimary,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 12),

        // ─── Timer ─────────────────────────────────────
        Text(
          '${secondsRemaining}s',
          style: GoogleFonts.inter(
            fontSize: 24,
            color: SleepColors.textSecondary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
