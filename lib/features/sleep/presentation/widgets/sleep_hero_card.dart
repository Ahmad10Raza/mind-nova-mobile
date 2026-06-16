import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/sleep_colors.dart';

/// Animated hero card with moon illustration and time-based greeting.
class SleepHeroCard extends StatelessWidget {
  final double animationValue;

  const SleepHeroCard({super.key, required this.animationValue});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning ☀️';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 21) return 'Ready to Wind Down?';
    if (hour >= 21 || hour < 1) return 'Time for Rest 🌙';
    return 'Deep into the Night';
  }

  String get _subtitle {
    final hour = DateTime.now().hour;
    if (hour >= 17 && hour < 21) return 'Create a calm night routine for better sleep.';
    if (hour >= 21 || hour < 5) return 'Let your mind drift into peacefulness.';
    return 'Track and improve your sleep quality.';
  }

  @override
  Widget build(BuildContext context) {
    final breathe = sin(animationValue * 2 * pi) * 0.03 + 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // ─── Moon Illustration ──────────────────────────
          Center(
            child: Transform.scale(
              scale: breathe,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      SleepColors.moonGold.withOpacity(0.6),
                      SleepColors.moonGold.withOpacity(0.2),
                      Colors.transparent,
                    ],
                    stops: const [0.3, 0.65, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: SleepColors.moonGold.withOpacity(0.2),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SleepColors.moonGold.withOpacity(0.7),
                      boxShadow: [
                        BoxShadow(
                          color: SleepColors.moonGold.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    // Crescent shadow
                    child: Stack(
                      children: [
                        Positioned(
                          top: 8,
                          left: 12,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: SleepColors.deepNavy.withOpacity(0.6),
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

          const SizedBox(height: 28),

          // ─── Greeting Text ─────────────────────────────
          Center(
            child: Text(
              _greeting,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: SleepColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: SleepColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
