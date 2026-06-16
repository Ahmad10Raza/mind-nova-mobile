import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import 'package:go_router/go_router.dart';
import '../../../mood/providers/analytics_provider.dart';
import '../../../profile/providers/profile_hub_provider.dart';

class ExploreUnderstandMyself extends ConsumerWidget {
  const ExploreUnderstandMyself({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(moodAnalyticsSummaryProvider(7));
    final hubState = ref.watch(profileHubProvider);
    
    String moodLogSubtitle = "Start checking in to see insights.";
    if (summaryAsync.hasValue && summaryAsync.value!.hasData) {
      final summary = summaryAsync.value!;
      moodLogSubtitle = "You've felt '${summary.dominantMood}' mostly this week.";
    }

    String analyticsSubtitle = "Cognitive load is 15% lower than average.";
    double analyticsProgress = 0.85;
    if (hubState.latestCMHI != null) {
      analyticsSubtitle = "Your clinical index is ${hubState.latestCMHI!.cmhi.toStringAsFixed(1)}.";
      analyticsProgress = (hubState.growthScore / 100.0).clamp(0.0, 1.0);
    } else if (hubState.growthScore > 0) {
      analyticsSubtitle = "Your growth score is ${hubState.growthScore.toInt()}.";
      analyticsProgress = (hubState.growthScore / 100.0).clamp(0.0, 1.0);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: Text(
            'Understand Myself',
            style: AppTypography.headingLarge,
          ),
        ),
        AppSpacing.v16,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.s12,
            crossAxisSpacing: AppSpacing.s12,
            childAspectRatio: 0.85,
            children: [
              _buildCard(
                icon: Icons.mood,
                color: AppColors.primary,
                title: 'Mood Log',
                subtitle: moodLogSubtitle,
                onTap: () => context.push('/mood-analytics'),
                extra: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _bar(0.6, AppColors.primary.withOpacity(0.2)),
                    const SizedBox(width: 2),
                    _bar(0.4, AppColors.primary.withOpacity(0.4)),
                    const SizedBox(width: 2),
                    _bar(1.0, AppColors.primary),
                    const SizedBox(width: 2),
                    _bar(0.7, AppColors.primary.withOpacity(0.6)),
                    const SizedBox(width: 2),
                    _bar(0.3, AppColors.primary.withOpacity(0.3)),
                  ],
                ),
              ),
              _buildCard(
                icon: Icons.edit_note,
                color: AppColors.secondary,
                title: 'Reflection',
                subtitle: 'Last entry: "Finding peace in the small victories today."',
                onTap: () => context.push('/journal'),
                extra: Row(
                  children: [
                    CircleAvatar(radius: 12, backgroundColor: AppColors.surfaceHighest),
                    const SizedBox(width: 4),
                    CircleAvatar(radius: 12, backgroundColor: AppColors.primary.withOpacity(0.2)),
                  ],
                ),
              ),
              _buildCard(
                icon: Icons.insights,
                color: AppColors.tertiary,
                title: 'Emotional Analytics',
                subtitle: analyticsSubtitle,
                onTap: () => context.push('/ai-hub'),
                extra: ClipRRect(
                  borderRadius: AppRadius.full,
                  child: LinearProgressIndicator(
                    value: analyticsProgress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.tertiary),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/weekly-history'),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    borderRadius: AppRadius.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: AppRadius.sm,
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                      ),
                      const Spacer(),
                      Text('Weekly Insight', style: AppTypography.headingMedium),
                      AppSpacing.v4,
                      Text(
                        hubState.weeklyInsightSummary ?? 'Keep logging your mood to unlock deeper insights into your growth journey.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              _buildCard(
                icon: Icons.favorite,
                color: AppColors.secondary,
                title: 'Gratitude Journal',
                subtitle: 'Add today\'s entries to build your positive stack.',
                onTap: () => context.push('/gratitude'),
              ),
              _buildCard(
                icon: Icons.self_improvement,
                color: AppColors.tertiary,
                title: 'Healing',
                subtitle: 'Guided journeys to reset anxiety, focus, and sleep.',
                onTap: () => context.push('/journeys'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    Widget? extra,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary.withOpacity(0.5),
          borderRadius: AppRadius.lg,
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.sm,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(title, style: AppTypography.headingMedium),
          AppSpacing.v4,
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (extra != null) ...[
            AppSpacing.v12,
            Expanded(child: extra),
          ]
        ],
      ),
    ),
    );
  }

  Widget _bar(double heightFactor, Color color) {
    return Expanded(
      child: FractionallySizedBox(
        heightFactor: heightFactor,
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ),
      ),
    );
  }
}
