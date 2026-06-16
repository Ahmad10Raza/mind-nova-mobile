import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/dashboard_theme.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;

  const StreakCard({super.key, this.streakDays = 0});

  @override
  Widget build(BuildContext context) {
    // If no streak, show a motivational nudge
    if (streakDays == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DashboardTheme.cardWhite,
          borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
          boxShadow: DashboardTheme.softShadow(Colors.black),
        ),
        child: Row(
          children: [
            const Text('🌱', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start your wellness streak',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: DashboardTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Log your mood daily to build momentum',
                    style: DashboardTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DashboardTheme.stressAmber.withValues(alpha: 0.08),
            DashboardTheme.energyYellow.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
        border: Border.all(
          color: DashboardTheme.stressAmber.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$streakDays Day Streak!',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: DashboardTheme.textPrimary,
                  ),
                ),
                Text(
                  _getStreakMessage(streakDays),
                  style: DashboardTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10), // Guard constraint before the dots
          // Mini heat dots — last 7 days
          // Using Wrap or limiting sizing prevents edge boundary overflow
          Wrap(
            spacing: 3.5, // Horizontal space between dots
            children: List.generate(7, (i) {
              final isActive = i < streakDays.clamp(0, 7);
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive 
                      ? DashboardTheme.stressAmber
                      : DashboardTheme.stressAmber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getStreakMessage(int days) {
    if (days >= 30) return 'Incredible commitment! 🏆';
    if (days >= 14) return 'You\'re on fire! Keep going!';
    if (days >= 7) return 'A full week of self-care!';
    if (days >= 3) return 'Building strong habits!';
    return 'Great start! Keep it up!';
  }
}
