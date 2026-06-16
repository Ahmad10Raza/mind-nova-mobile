import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/design/shadows/app_shadows.dart';
import '../../../../core/design/gradients/app_gradients.dart';

import '../../providers/dashboard_provider.dart';

class HomeRecommendedAction extends ConsumerWidget {
  const HomeRecommendedAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusAsync = ref.watch(todayFocusProvider);

    return focusAsync.when(
      data: (focus) => _buildCard(context, focus),
      loading: () => _buildLoading(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCard(BuildContext context, TodayFocus focus) {
    final iconData = _getIcon(focus.type);
    final gradient = _getGradient(focus.type);

    return GestureDetector(
      onTap: () => context.push(focus.route),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: AppRadius.xl,
          boxShadow: AppShadows.glowPurple,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: Colors.white, size: 28),
            ),
            AppSpacing.v20,

            // Title
            Text(
              focus.title,
              style: AppTypography.headingLarge.copyWith(color: Colors.white),
            ),
            AppSpacing.v8,

            // Subtitle
            Text(
              focus.subtitle,
              style: AppTypography.body.copyWith(color: Colors.white.withOpacity(0.8)),
            ),
            AppSpacing.v24,

            // CTA
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s24,
                vertical: AppSpacing.s12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: AppRadius.full,
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    focus.ctaLabel,
                    style: AppTypography.button.copyWith(color: Colors.white),
                  ),
                  AppSpacing.h8,
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: AppRadius.xl,
      ),
    );
  }

  IconData _getIcon(FocusActionType type) {
    switch (type) {
      case FocusActionType.breathe:
        return Icons.air_rounded;
      case FocusActionType.grounding:
        return Icons.spa_rounded;
      case FocusActionType.logMood:
        return Icons.mood_rounded;
      case FocusActionType.completeHabit:
        return Icons.check_circle_outline_rounded;
      case FocusActionType.continueChallenge:
        return Icons.flag_rounded;
      case FocusActionType.rest:
        return Icons.bedtime_rounded;
      case FocusActionType.takeFirstStep:
        return Icons.favorite_rounded;
    }
  }

  LinearGradient _getGradient(FocusActionType type) {
    switch (type) {
      case FocusActionType.breathe:
      case FocusActionType.grounding:
        return AppGradients.recovery;
      case FocusActionType.rest:
        return AppGradients.sleep;
      case FocusActionType.logMood:
      case FocusActionType.takeFirstStep:
        return AppGradients.nova;
      default:
        return AppGradients.focus;
    }
  }
}
