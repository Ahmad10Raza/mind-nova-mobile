import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

class EmergencyToolkitCard extends StatelessWidget {
  const EmergencyToolkitCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.novaPurple.withAlpha(102), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency_rounded, color: AppColors.emotionalDangerMuted, size: 18),
              const SizedBox(width: 8),
              Text(
                "EMERGENCY TOOLKIT",
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.emotionalDangerMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          AppSpacing.v16,
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildTool(context, Icons.mic_rounded, "AI Chat", '/chat', AppColors.novaPurple),
              _buildTool(context, Icons.self_improvement_rounded, "Breathing", '/breathing', AppColors.calmTeal),
              _buildTool(context, Icons.edit_note_rounded, "Journal", '/journal', AppColors.recoveryBlue),
              _buildTool(context, Icons.spa_rounded, "Grounding", '/grounding/sensory', AppColors.successSoft),
              _buildTool(context, Icons.bedtime_rounded, "Sleep Mode", '/sleep', const Color(0xFF1E3A5F)),
              _buildTool(context, Icons.phone_rounded, "Crisis Line", '/crisis', AppColors.emotionalDangerMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTool(BuildContext context, IconData icon, String label, String route, Color color) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(38),
          borderRadius: AppRadius.sm,
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
