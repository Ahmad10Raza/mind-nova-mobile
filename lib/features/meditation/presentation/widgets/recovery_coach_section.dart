import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

class RecoveryCoachSection extends StatelessWidget {
  const RecoveryCoachSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundTertiary,
              const Color(0xFF1A1060).withAlpha(128),
              AppColors.backgroundSecondary,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: AppRadius.xl,
          border: Border.all(color: AppColors.novaPurple.withAlpha(51)),
          boxShadow: [
            BoxShadow(
              color: AppColors.novaPurple.withAlpha(38),
              blurRadius: 32,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.novaPurple.withAlpha(64),
                        AppColors.calmTeal.withAlpha(38),
                      ],
                    ),
                    borderRadius: AppRadius.sm,
                    border: Border.all(
                        color: AppColors.novaPurple.withAlpha(76)),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.novaPurpleLight, size: 20),
                ),
                AppSpacing.h12,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOVA RECOVERY COACH',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.novaPurpleLight,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'Personalized for you',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            AppSpacing.v20,

            // Pattern summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: AppRadius.md,
                border: Border.all(color: Colors.white.withAlpha(13)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Emotional Patterns',
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.textMuted),
                  ),
                  AppSpacing.v8,
                  Row(
                    children: [
                      _buildPatternChip('😰 Anxiety', AppColors.novaPurple),
                      AppSpacing.h8,
                      _buildPatternChip('😴 Sleep', const Color(0xFF1E3A8A)),
                      AppSpacing.h8,
                      _buildPatternChip('📉 Stress', const Color(0xFFEA580C)),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.v16,

            // Suggestion
            Text(
              'Nova believes today\'s best recovery step is:',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textMuted),
            ),
            AppSpacing.v12,

            // Suggested session card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1E3A8A).withAlpha(128),
                    const Color(0xFF312E81).withAlpha(102),
                  ],
                ),
                borderRadius: AppRadius.md,
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: AppRadius.sm,
                    ),
                    child: const Center(
                        child: Text('🌙', style: TextStyle(fontSize: 24))),
                  ),
                  AppSpacing.h12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sleep Faster Tonight',
                          style: AppTypography.headingSmall
                              .copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '15 minutes · Sleep',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.v12,

            // Expected outcome
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.successSoft.withAlpha(20),
                borderRadius: AppRadius.sm,
                border: Border.all(color: AppColors.successSoft.withAlpha(51)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up_rounded,
                      color: AppColors.successSoft, size: 14),
                  AppSpacing.h8,
                  Text(
                    'Expected Outcome: Improved sleep readiness',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.successSoft, fontSize: 11),
                  ),
                ],
              ),
            ),
            AppSpacing.v16,

            // CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/meditation/player'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.calmTeal,
                  foregroundColor: AppColors.backgroundPrimary,
                  shape:
                      RoundedRectangleBorder(borderRadius: AppRadius.md),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text('Start Session',
                        style: AppTypography.button.copyWith(
                            color: AppColors.backgroundPrimary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: AppRadius.xs,
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall
            .copyWith(color: AppColors.textSecondary, fontSize: 10),
      ),
    );
  }
}
