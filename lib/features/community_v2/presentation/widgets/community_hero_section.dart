import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/gradients/app_gradients.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/widgets/animations/mind_nova_animations.dart';

/// Warm community welcome hero.
class CommunityHeroSection extends StatelessWidget {
  const CommunityHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppGradients.community,
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

              // People icon
              BreathingScale(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.people_rounded, color: Colors.white, size: 28),
                ),
              ),
              AppSpacing.v24,

              Text(
                "You're not\nalone here.",
                style: AppTypography.heroXL.copyWith(color: Colors.white),
              ),
              AppSpacing.v8,
              Text(
                'A safe space for healing together.',
                style: AppTypography.body.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
