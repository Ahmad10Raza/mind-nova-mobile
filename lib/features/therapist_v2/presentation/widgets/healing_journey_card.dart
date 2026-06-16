import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/design/shadows/app_shadows.dart';

import '../../data/therapist_data.dart';

/// Healing journey cards for horizontal scroll.
class HealingJourneyCard extends StatelessWidget {
  final HealingJourney journey;
  final VoidCallback? onTap;

  const HealingJourneyCard({super.key, required this.journey, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 230,
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: AppRadius.md,
          boxShadow: AppShadows.shadowSubtle,
          border: Border.all(color: journey.color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s8),
                  decoration: BoxDecoration(
                    color: journey.color.withOpacity(0.12),
                    borderRadius: AppRadius.sm,
                  ),
                  child: Icon(journey.icon, color: journey.color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundTertiary,
                    borderRadius: AppRadius.full,
                  ),
                  child: Text(
                    journey.duration,
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 10),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(journey.title, style: AppTypography.headingMedium.copyWith(fontSize: 15)),
                AppSpacing.v4,
                Text(
                  journey.subtitle,
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            // Phase icons
            Row(
              children: journey.phases.asMap().entries.map((entry) {
                final isLast = entry.key == journey.phases.length - 1;
                final phaseIcon = _typeIcon(entry.value.type);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(phaseIcon, color: journey.color.withOpacity(0.6), size: 14),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted, size: 10),
                      ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'therapy': return Icons.person_rounded;
      case 'nova': return Icons.auto_awesome_rounded;
      case 'recovery': return Icons.spa_rounded;
      case 'journal': return Icons.edit_note_rounded;
      case 'mood': return Icons.favorite_rounded;
      default: return Icons.circle_rounded;
    }
  }
}
