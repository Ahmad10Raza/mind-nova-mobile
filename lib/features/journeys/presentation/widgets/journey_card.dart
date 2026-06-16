import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/design/shadows/app_shadows.dart';

import '../../data/journey_data.dart';

/// Large immersive journey card with gradient background.
class JourneyCard extends StatelessWidget {
  final GuidedHealingJourney journey;
  final VoidCallback onTap;

  const JourneyCard({super.key, required this.journey, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s24),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary.withOpacity(0.5),
          borderRadius: AppRadius.xl,
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: journey.color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: journey.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(journey.icon, color: journey.color, size: 22),
                ),
                Row(
                  children: [
                    if (journey.isTherapistGuided)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: journey.color.withOpacity(0.15),
                          borderRadius: AppRadius.full,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, color: journey.color, size: 10),
                            const SizedBox(width: 4),
                            Text(
                              'Therapist',
                              style: AppTypography.caption.copyWith(color: journey.color, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
                      decoration: BoxDecoration(
                        color: journey.color.withOpacity(0.15),
                        borderRadius: AppRadius.full,
                      ),
                      child: Text(
                        journey.duration,
                        style: AppTypography.caption.copyWith(color: journey.color, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            AppSpacing.v20,
            Text(journey.title, style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary)),
            AppSpacing.v4,
            Text(journey.subtitle, style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
            AppSpacing.v12,
            Text(
              journey.emotionalIntent,
              style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact horizontal journey card.
class JourneyCardCompact extends StatelessWidget {
  final GuidedHealingJourney journey;
  final VoidCallback onTap;

  const JourneyCardCompact({super.key, required this.journey, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary.withOpacity(0.5),
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
                  child: Icon(journey.icon, color: journey.color, size: 18),
                ),
                Text(
                  journey.duration,
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 10),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(journey.title, style: AppTypography.headingMedium.copyWith(fontSize: 14)),
                AppSpacing.v4,
                Text(
                  journey.subtitle,
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            // Difficulty badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: AppRadius.full,
              ),
              child: Text(
                journey.difficulty,
                style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
