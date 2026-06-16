import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../scoring/models/scoring_model.dart';
import 'package:go_router/go_router.dart';

class MindfulMomentCard extends StatelessWidget {
  final RiskCategory? riskLevel;

  const MindfulMomentCard({super.key, this.riskLevel});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(riskLevel);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DashboardTheme.cardWhite,
        borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
        boxShadow: DashboardTheme.softShadow(Colors.black),
      ),
      child: Column(
        children: [
          // Graphic showcase area
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(DashboardTheme.radiusL)),
            ),
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: config.color.withValues(alpha: 0.1), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: config.color.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    config.asset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.spa_rounded, size: 60, color: config.color),
                  ),
                ),
              ),
            ),
          ),
          
          // Text & Action area
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'MINDFUL MOMENT',
                  style: DashboardTheme.label.copyWith(color: config.color),
                ),
                const SizedBox(height: 12),
                Text(
                  config.quote,
                  textAlign: TextAlign.center,
                  style: DashboardTheme.heading3.copyWith(height: 1.4, fontSize: 15),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => context.push(config.route),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      color: config.color,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: DashboardTheme.glowShadow(config.color),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(config.icon, color: Colors.white, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          config.actionLabel,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _MomentConfig _getConfig(RiskCategory? risk) {
    if (risk == RiskCategory.high || risk == RiskCategory.severe || risk == RiskCategory.emergency) {
      return _MomentConfig(
        asset: 'assets/illustrations/Meditation.png',
        quote: "Take a gentle pause. You don't have to carry it all at once.",
        color: DashboardTheme.recoveryTeal,
        actionLabel: 'Body Scan',
        icon: Icons.accessibility_new_rounded,
        route: '/body-scan', // Assumed route for Body Scan
      );
    }
    
    final hour = DateTime.now().hour;
    if (hour >= 20 || hour < 6) {
      return _MomentConfig(
        asset: 'assets/illustrations/Meditation.png',
        quote: "The day is done. Release the tension and prepare to rest your mind.",
        color: DashboardTheme.sleepBlue,
        actionLabel: 'Sleep Prep',
        icon: Icons.bedtime_rounded,
        route: '/sleep-mode',
      );
    }
    
    return _MomentConfig(
      asset: 'assets/illustrations/FlowerOnMind.png',
      quote: "Water your mind with positive thoughts. Every step forward counts.",
      color: DashboardTheme.primaryPurple,
      actionLabel: 'Zen Focus',
      icon: Icons.timer_rounded,
      route: '/zen-mode',
    );
  }
}

class _MomentConfig {
  final String asset;
  final String quote;
  final Color color;
  final String actionLabel;
  final IconData icon;
  final String route;
  const _MomentConfig({
    required this.asset,
    required this.quote,
    required this.color,
    required this.actionLabel,
    required this.icon,
    required this.route,
  });
}
