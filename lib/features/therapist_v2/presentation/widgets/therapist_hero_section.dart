import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/gradients/app_gradients.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/widgets/animations/mind_nova_animations.dart';

/// Warm, human-centric therapist hero.
class TherapistHeroSection extends StatelessWidget {
  final bool hasUpcomingSession;
  final String? nextSessionTime;

  const TherapistHeroSection({
    super.key,
    this.hasUpcomingSession = false,
    this.nextSessionTime,
  });

  @override
  Widget build(BuildContext context) {
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

              // Heart icon
              BreathingScale(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                ),
              ),
              AppSpacing.v24,

              Text(
                'Human support\nis here for you.',
                style: AppTypography.heroXL.copyWith(color: Colors.white),
              ),
              AppSpacing.v8,
              Text(
                'Asking for help takes courage.',
                style: AppTypography.body.copyWith(color: Colors.white60),
              ),

              if (hasUpcomingSession && nextSessionTime != null) ...[
                AppSpacing.v20,
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: AppRadius.sm,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, color: Colors.white70, size: 18),
                      AppSpacing.h12,
                      Text(
                        'Next session: $nextSessionTime',
                        style: AppTypography.caption.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
