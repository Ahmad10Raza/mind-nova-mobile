import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/sleep_colors.dart';

/// Emergency calm-down card for night anxiety access.
class SleepEmergencyCard extends StatelessWidget {
  final VoidCallback? onBreathingTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onFullTap;

  const SleepEmergencyCard({
    super.key,
    this.onBreathingTap,
    this.onChatTap,
    this.onFullTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFullTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SleepColors.cardRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: SleepColors.glassBlurSigma,
            sigmaY: SleepColors.glassBlurSigma,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  SleepColors.emergencyRed.withOpacity(0.08),
                  Colors.white.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(SleepColors.cardRadius),
              border: Border.all(
                color: SleepColors.emergencyRed.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SleepColors.emergencyRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shield_moon_rounded,
                        color: SleepColors.emergencyRed,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Can\'t Sleep?',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: SleepColors.textPrimary,
                            ),
                          ),
                          Text(
                            'We\'re here to help calm your mind.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: SleepColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: SleepColors.textMuted,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildQuickAction(
                      'Breathe',
                      Icons.air_rounded,
                      SleepColors.calmTeal,
                      onBreathingTap,
                    ),
                    const SizedBox(width: 10),
                    _buildQuickAction(
                      'Talk to AI',
                      Icons.chat_bubble_outline_rounded,
                      SleepColors.lavenderGlow,
                      onChatTap,
                    ),
                    const SizedBox(width: 10),
                    _buildQuickAction(
                      'Grounding',
                      Icons.landscape_rounded,
                      SleepColors.moonGold,
                      onFullTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color color, VoidCallback? onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
