import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../scoring/models/scoring_model.dart';

class DailyActionCard extends StatelessWidget {
  final RiskCategory? risk;

  const DailyActionCard({super.key, this.risk});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final action = _getAction(hour, risk);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: DashboardTheme.primaryGradient,
        borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
        boxShadow: DashboardTheme.glowShadow(DashboardTheme.primaryPurple),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action.title,
                  style: GoogleFonts.outfit(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => context.push(action.route),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      action.cta,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: DashboardTheme.primaryPurple,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Contextual icon, cleaner without overlapping background doodles
          Expanded(
            flex: 1,
            child: Icon(action.icon, color: Colors.white.withValues(alpha: 0.4), size: 56),
          ),
        ],
      ),
    );
  }

  _ActionData _getAction(int hour, RiskCategory? risk) {
    if (risk == RiskCategory.high || risk == RiskCategory.severe || risk == RiskCategory.emergency) {
      return _ActionData('SUPPORT', "Let's find some calm together", 'Start Breathing', '/breathing', Icons.spa_rounded);
    }
    if (hour < 12) {
      return _ActionData('MORNING RITUAL', 'Start your day with a check-in', 'Log Mood', '/mood-checkin', Icons.wb_sunny_rounded);
    }
    if (hour < 17) {
      return _ActionData('MINDFUL MINUTE', 'Time for a mid-day reflection', 'Daily Check-in', '/mood-checkin', Icons.self_improvement_rounded);
    }
    if (hour < 20) {
      return _ActionData('EVENING WIND-DOWN', 'Reflect on your day', 'Evening Journal', '/mood-checkin', Icons.nightlight_rounded);
    }
    return _ActionData('NIGHT MODE', 'Prepare for restful sleep', 'Breathe & Relax', '/breathing', Icons.bedtime_rounded);
  }
}

class _ActionData {
  final String label;
  final String title;
  final String cta;
  final String route;
  final IconData icon;
  const _ActionData(this.label, this.title, this.cta, this.route, this.icon);
}
