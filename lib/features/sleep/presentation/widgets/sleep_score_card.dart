import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/sleep_colors.dart';

/// Glassmorphic sleep score card with circular gauge.
class SleepScoreCard extends StatelessWidget {
  final double score; // 0.0 - 1.0
  final String quality; // "Good", "Fair", "Poor"
  final double consistency; // 0.0 - 1.0
  final double avgHours;

  const SleepScoreCard({
    super.key,
    this.score = 0.75,
    this.quality = 'Good',
    this.consistency = 0.8,
    this.avgHours = 7.2,
  });

  Color get _scoreColor {
    if (score >= 0.8) return SleepColors.successGreen;
    if (score >= 0.6) return SleepColors.moonGold;
    if (score >= 0.4) return Colors.orange;
    return SleepColors.emergencyRed;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(SleepColors.cardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: SleepColors.glassBlurSigma,
          sigmaY: SleepColors.glassBlurSigma,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: SleepColors.glassCardWithGlow(_scoreColor),
          child: Column(
            children: [
              // ─── Circular Score Gauge ──────────────────
              SizedBox(
                height: 140,
                width: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 140,
                      width: 140,
                      child: CircularProgressIndicator(
                        value: score,
                        strokeWidth: 10,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(score * 100).toInt()}',
                          style: GoogleFonts.outfit(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: SleepColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Sleep Score',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: SleepColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── Sub Metrics ──────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetric('Quality', quality, Icons.star_rounded),
                  _buildDivider(),
                  _buildMetric('Avg.', '${avgHours.toStringAsFixed(1)}h', Icons.schedule_rounded),
                  _buildDivider(),
                  _buildMetric('Consistency', '${(consistency * 100).toInt()}%', Icons.repeat_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: SleepColors.textMuted, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: SleepColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: SleepColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: SleepColors.glassBorder,
    );
  }
}
