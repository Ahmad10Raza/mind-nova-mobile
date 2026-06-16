import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

import '../../data/emotional_states.dart';

/// Soft emotional correlation insights — non-judgmental, supportive.
class MoodCorrelationInsights extends StatelessWidget {
  const MoodCorrelationInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Emotional insights', style: AppTypography.headingMedium),
        AppSpacing.v4,
        Text(
          'Patterns we noticed gently',
          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
        ),
        AppSpacing.v16,
        ...EmotionalCorrelations.examples.map((correlation) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s12),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: AppRadius.md,
                border: Border.all(color: correlation.color.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    decoration: BoxDecoration(
                      color: correlation.color.withOpacity(0.1),
                      borderRadius: AppRadius.sm,
                    ),
                    child: Icon(correlation.icon, color: correlation.color, size: 18),
                  ),
                  AppSpacing.h12,
                  Expanded(
                    child: Text(
                      correlation.insight,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
