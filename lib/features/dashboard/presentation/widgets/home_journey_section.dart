import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/design/shadows/app_shadows.dart';

import '../../../habits/providers/habit_provider.dart';
import '../../../challenges/providers/challenge_provider.dart';

class HomeJourneySection extends ConsumerWidget {
  const HomeJourneySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(todayHabitsProvider);
    final challengeAsync = ref.watch(activeChallengeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Continue your journey',
          style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
        ),
        AppSpacing.v16,
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            children: [
              // Habits continuation
              habitsAsync.when(
                data: (habits) {
                  final pending = habits.where((h) => h.logs.isEmpty).length;
                  if (pending == 0) return const SizedBox.shrink();
                  return _JourneyCard(
                    title: 'Habits',
                    subtitle: '$pending remaining today',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.calmTeal,
                    onTap: () => context.push('/habits'),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Challenge continuation
              challengeAsync.when(
                data: (challenge) {
                  if (challenge == null || challenge.isCompletedForToday) {
                    return const SizedBox.shrink();
                  }
                  return _JourneyCard(
                    title: 'Challenge',
                    subtitle: 'Continue today\'s step',
                    icon: Icons.flag_rounded,
                    color: AppColors.warmSupport,
                    onTap: () => context.push('/challenges/active'),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Sleep journey
              _JourneyCard(
                title: 'Sleep',
                subtitle: 'Log your rest',
                icon: Icons.bedtime_rounded,
                color: AppColors.recoveryBlue,
                onTap: () => context.push('/sleep'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JourneyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _JourneyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: AppSpacing.s12),
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: AppRadius.md,
          boxShadow: AppShadows.shadowSubtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: AppRadius.sm,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headingMedium.copyWith(fontSize: 15)),
                AppSpacing.v4,
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
