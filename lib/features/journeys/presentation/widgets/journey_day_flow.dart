import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

import '../../data/journey_data.dart';

/// Vertical step-by-step daily flow.
/// Each step is a soft card with route navigation.
class JourneyDayFlow extends StatelessWidget {
  final HealingJourneyDay day;
  final Color accentColor;

  const JourneyDayFlow({super.key, required this.day, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Text('Day ${day.dayNumber}', style: AppTypography.headingMedium),
        AppSpacing.v4,
        Text(day.theme, style: AppTypography.body.copyWith(color: accentColor)),
        AppSpacing.v4,
        Text(
          day.emotionalIntent,
          style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontStyle: FontStyle.italic),
        ),
        AppSpacing.v20,

        // Steps
        ...day.steps.asMap().entries.map((entry) {
          final step = entry.value;
          final isLast = entry.key == day.steps.length - 1;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline dot + line
                SizedBox(
                  width: 28,
                  child: Column(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: accentColor, width: 2),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 56,
                          color: AppColors.backgroundTertiary,
                        ),
                    ],
                  ),
                ),
                AppSpacing.h12,

                // Step card
                Expanded(
                  child: GestureDetector(
                    onTap: step.route != null ? () => context.push(step.route!) : null,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: AppRadius.sm,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.s8),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: AppRadius.sm,
                            ),
                            child: Icon(step.icon, color: accentColor, size: 16),
                          ),
                          AppSpacing.h12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(step.title, style: AppTypography.headingMedium.copyWith(fontSize: 13)),
                                Text(
                                  step.description,
                                  style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '~${step.estimatedDuration.inMinutes}m',
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 10),
                          ),
                          if (step.route != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 10),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
