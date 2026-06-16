import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/tools_theme.dart';

class HabitAIInsightsCard extends StatelessWidget {
  final String insight;
  final String category;

  const HabitAIInsightsCard({
    super.key,
    required this.insight,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ToolsTheme.aiPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ToolsTheme.aiPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ToolsTheme.aiPurple.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: ToolsTheme.aiPurple, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                'AI BEHAVIORAL INSIGHT',
                style: GoogleFonts.outfit(
                  color: ToolsTheme.aiPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            insight,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Reflected from your $category patterns',
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
