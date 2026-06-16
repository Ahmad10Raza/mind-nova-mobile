import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/gradients/app_gradients.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/widgets/animations/mind_nova_animations.dart';

/// Journey welcome hero with breathing path icon.
class JourneyHeroSection extends StatelessWidget {
  final bool hasActiveJourney;
  final String? activeJourneyTitle;
  final int? currentDay;

  const JourneyHeroSection({
    super.key,
    this.hasActiveJourney = false,
    this.activeJourneyTitle,
    this.currentDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
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
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary.withOpacity(0.5),
                    borderRadius: AppRadius.sm,
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textSecondary, size: 18),
                ),
              ),
              AppSpacing.v32,

              BreathingScale(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.route_rounded, color: AppColors.primary, size: 28),
                ),
              ),
              AppSpacing.v24,

              Text(
                hasActiveJourney
                    ? 'Welcome back\nto your path.'
                    : 'Healing is\na journey.',
                style: AppTypography.heroXL.copyWith(color: AppColors.textPrimary),
              ),
              AppSpacing.v8,
              Text(
                hasActiveJourney
                    ? 'Day $currentDay of $activeJourneyTitle'
                    : 'Take the first gentle step.',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
