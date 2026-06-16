import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../scoring/models/scoring_model.dart';

class QuickActionsSection extends StatelessWidget {
  final RiskCategory? riskLevel;

  const QuickActionsSection({super.key, this.riskLevel});

  @override
  Widget build(BuildContext context) {
    final actions = _getOrderedActions(riskLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Smart Shortcuts', style: DashboardTheme.heading2),
        const SizedBox(height: 14),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: actions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _buildActionCard(context, actions[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, _QAction action) {
    return GestureDetector(
      onTap: () {
        if (action.route.isNotEmpty) {
          if (action.route.startsWith('/')) {
            context.push(action.route);
          } else {
            context.go(action.route);
          }
        }
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              action.color.withValues(alpha: 0.12),
              action.color.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(DashboardTheme.radiusM),
          border: Border.all(
            color: action.color.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: action.color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: action.color, size: 26),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: DashboardTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<_QAction> _getOrderedActions(RiskCategory? risk) {
    final all = [
      _QAction('Mood', Icons.emoji_emotions_rounded, DashboardTheme.moodGreen, '/mood-checkin'),
      _QAction('Breathe', Icons.air_rounded, DashboardTheme.sleepBlue, '/breathing'),
      _QAction('AI Chat', Icons.auto_awesome_rounded, DashboardTheme.primaryPurple, '/chat'),
      _QAction('SOS', Icons.emergency_rounded, DashboardTheme.crisisRed, '/sos-mode'),
      _QAction('Habits', Icons.check_circle_rounded, DashboardTheme.stressAmber, '/habits'),
      _QAction('Journal', Icons.edit_note_rounded, DashboardTheme.recoveryTeal, '/journal'),
      _QAction('Zen Mode', Icons.timer_rounded, const Color(0xFF4DB6AC), '/focus'),
      _QAction('Audio', Icons.headphones_rounded, const Color(0xFF9575CD), '/audio'),
      _QAction('Challenges', Icons.emoji_events_rounded, const Color(0xFFFFB74D), '/challenges'),
      _QAction('Gratitude', Icons.favorite_rounded, const Color(0xFFF06292), '/gratitude'),
      _QAction('Body Scan', Icons.accessibility_new_rounded, const Color(0xFF4FC3F7), '/grounding/body-scan'),
      _QAction('Community', Icons.forum_rounded, DashboardTheme.anxietyPink, '/community/feed'),
      _QAction('Sleep', Icons.bedtime_rounded, DashboardTheme.sleepBlue, '/sleep'),
      _QAction('Assess', Icons.psychology_rounded, DashboardTheme.stressAmber, '/adaptive-assessment/clinical_main'),
    ];

    // Dynamic reordering: push calming actions first for high risk
    if (risk == RiskCategory.high || risk == RiskCategory.severe || risk == RiskCategory.emergency) {
      // For high risk, we want immediate relief tools first
      final breathe = all.removeAt(1);
      final sos = all.removeAt(2); // SOS was index 3, now 2 after removing breathe
      final bodyScan = all.removeAt(8); // Body Scan
      
      all.insert(0, breathe);
      all.insert(1, sos);
      all.insert(2, bodyScan);
    }

    return all.take(8).toList();
  }
}

class _QAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _QAction(this.label, this.icon, this.color, this.route);
}
