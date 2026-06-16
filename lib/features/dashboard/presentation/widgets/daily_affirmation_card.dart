import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/dashboard_theme.dart';

class DailyAffirmationCard extends StatelessWidget {
  const DailyAffirmationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final affirmation = _getAffirmation();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3E5F5), Color(0xFFE8EAF6), Color(0xFFE0F2F1)],
        ),
        borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Daily Affirmation',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DashboardTheme.primaryPurple,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            affirmation,
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: DashboardTheme.textPrimary,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getAffirmation() {
    final affirmations = [
      "I am worthy of peace and happiness.",
      "Every day I am growing stronger, mentally and emotionally.",
      "I choose to focus on what I can control.",
      "My feelings are valid and I give myself permission to feel them.",
      "I am more than my anxious thoughts.",
      "I deserve rest and I will honor my boundaries.",
      "Progress, not perfection, is my goal today.",
    ];
    final dayIndex = DateTime.now().day % affirmations.length;
    return '"${affirmations[dayIndex]}"';
  }
}
