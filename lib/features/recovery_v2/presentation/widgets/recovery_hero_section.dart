import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/gradients/app_gradients.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/widgets/animations/mind_nova_animations.dart';

/// Atmospheric recovery hero with breathing background glow.
class RecoveryHeroSection extends StatelessWidget {
  final String? insightText;

  const RecoveryHeroSection({super.key, this.insightText});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = _getRecoveryGreeting(hour);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppGradients.sleep,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.radiusXL),
          bottomRight: Radius.circular(AppRadius.radiusXL),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s24, AppSpacing.s24, AppSpacing.s24, AppSpacing.s40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: AppRadius.sm,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
              AppSpacing.v32,

              // Breathing icon
              BreathingScale(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.recoveryBlue.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.self_improvement_rounded,
                    color: AppColors.recoveryBlue,
                    size: 32,
                  ),
                ),
              ),
              AppSpacing.v24,

              // Greeting
              Text(
                greeting,
                style: AppTypography.heroXL.copyWith(color: AppColors.textPrimary),
              ),
              AppSpacing.v8,
              Text(
                'This is your space to slow down.',
                style: AppTypography.body.copyWith(color: AppColors.textMuted),
              ),

              // Optional insight
              if (insightText != null) ...[
                AppSpacing.v20,
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: AppRadius.sm,
                    border: Border.all(color: AppColors.calmTeal.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: AppColors.calmTeal, size: 16),
                      AppSpacing.h12,
                      Expanded(
                        child: Text(
                          insightText!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
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

  String _getRecoveryGreeting(int hour) {
    if (hour < 6) return "Can't sleep?\nLet's calm your mind.";
    if (hour < 12) return 'Start gently\ntoday.';
    if (hour < 17) return 'Take a pause.\nYou deserve it.';
    if (hour < 20) return 'Time to\nwind down.';
    return 'Rest is\nhealing.';
  }
}
