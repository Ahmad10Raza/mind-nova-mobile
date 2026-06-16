import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/gradients/app_gradients.dart';
import '../../../../core/design/radius/app_radius.dart';

import '../../data/emotional_states.dart';

/// Emotional check-in hero with reflection prompt.
class MoodHeroSection extends StatelessWidget {
  final String? latestMoodEmoji;
  final String? latestMoodName;

  const MoodHeroSection({super.key, this.latestMoodEmoji, this.latestMoodName});

  @override
  Widget build(BuildContext context) {
    final prompt = ReflectionPrompts.forTimeOfDay();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppGradients.therapy,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.radiusXL),
          bottomRight: Radius.circular(AppRadius.radiusXL),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s24, AppSpacing.s16, AppSpacing.s24, AppSpacing.s40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: AppRadius.sm,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
                ),
              ),
              AppSpacing.v32,

              // Current state
              if (latestMoodEmoji != null && latestMoodName != null) ...[
                Row(
                  children: [
                    Text(latestMoodEmoji!, style: const TextStyle(fontSize: 28)),
                    AppSpacing.h12,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Currently feeling',
                          style: AppTypography.caption.copyWith(color: Colors.white60),
                        ),
                        Text(
                          latestMoodName!,
                          style: AppTypography.headingMedium.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                AppSpacing.v24,
              ],

              // Reflection prompt
              Text(
                prompt.text,
                style: AppTypography.headingLarge.copyWith(
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              AppSpacing.v8,
              Text(
                'Take a moment to reflect.',
                style: AppTypography.body.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
