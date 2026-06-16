import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/dashboard_theme.dart';

class PremiumMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final double progress; // 0.0 to 1.0
  final Color color;
  final IconData icon;
  final String? trend;
  final bool isImproving;
  final String? badge; // "Improving", "Stable", "Declining"

  const PremiumMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.progress,
    required this.color,
    required this.icon,
    this.trend,
    this.isImproving = true,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Using mainAxisSize: MainAxisSize.min and taking out the fixed height on DashboardScreen
        // will allow the card to expand as needed for the glow and badge.
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon + Trend row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              if (trend != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isImproving ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: isImproving ? DashboardTheme.moodGreen : DashboardTheme.crisisRed,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend!,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isImproving ? DashboardTheme.moodGreen : DashboardTheme.crisisRed,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(title, style: DashboardTheme.bodySmall),
          const SizedBox(height: 4),

          // Value + Unit
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: DashboardTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DashboardTheme.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar with glow
          Container(
            height: 14, // Allocate enough height for the bar + shadow glow beneath it
            alignment: Alignment.topCenter,
            child: Stack(
              clipBehavior: Clip.none, // Allow glow shadow to paint outside if needed, though wrapped securely now
              children: [
                Container(
                  height: 5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0, 1),
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.6)],
                      ),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Badge
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge!,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
