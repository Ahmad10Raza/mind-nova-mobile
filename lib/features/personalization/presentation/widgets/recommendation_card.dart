import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

import '../../data/emotional_profile.dart';

/// Emotional recommendation card — gentle, contextual, non-manipulative.
class RecommendationCard extends StatelessWidget {
  final EmotionalRecommendation recommendation;

  const RecommendationCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(recommendation.route),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: recommendation.color.withOpacity(0.06),
          borderRadius: AppRadius.md,
          border: Border.all(color: recommendation.color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s8),
              decoration: BoxDecoration(
                color: recommendation.color.withOpacity(0.12),
                borderRadius: AppRadius.sm,
              ),
              child: Icon(recommendation.icon, color: recommendation.color, size: 18),
            ),
            AppSpacing.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.title,
                    style: AppTypography.headingMedium.copyWith(fontSize: 14),
                  ),
                  AppSpacing.v4,
                  Text(
                    recommendation.reason,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: recommendation.color.withOpacity(0.5), size: 14),
          ],
        ),
      ),
    );
  }
}
