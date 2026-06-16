import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/grounding_provider.dart';
import '../models/grounding_model.dart';
import 'widgets/grounding_hero_card.dart';
import 'widgets/grounding_mode_grid.dart';
import 'widgets/emergency_toolkit_card.dart';

import '../../../core/design/colors/app_colors.dart';
import '../../../core/design/typography/app_typography.dart';
import '../../../core/design/spacing/app_spacing.dart';
import '../../../core/design/radius/app_radius.dart';

class GroundingDashboardScreen extends ConsumerWidget {
  const GroundingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(groundingDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.backgroundPrimary,
            elevation: 0,
            pinned: true,
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Text(
                "Grounding",
                style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded, color: AppColors.textMuted),
                onPressed: () => context.push('/grounding/history'),
              ),
              IconButton(
                icon: const Icon(Icons.insights_rounded, color: AppColors.textMuted),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: Column(
                children: [
                  const GroundingHeroCard(),
                  AppSpacing.v32,

                  // Analytics badges from dashboard
                  dashboardAsync.when(
                    data: (dashboard) {
                      if (dashboard.badges.isEmpty) return const SizedBox.shrink();
                      return _buildBadges(dashboard.badges);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  AppSpacing.v8,
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: GroundingModeGrid()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
            sliver: const SliverToBoxAdapter(child: EmergencyToolkitCard()),
          ),

          // Recent Sessions section
          dashboardAsync.when(
            data: (dashboard) {
              if (dashboard.recentSessions.isEmpty) return _buildEmptyState();
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recent Sessions",
                            style: AppTypography.headingM.copyWith(color: AppColors.textPrimary),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/grounding/history'),
                            child: Text(
                              "View all",
                              style: AppTypography.labelMedium.copyWith(color: AppColors.calmTeal),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.v16,
                      ...dashboard.recentSessions.map((s) => _buildSessionTile(s)),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: SizedBox(height: 32, child: Center(child: CircularProgressIndicator(color: AppColors.novaPurple))),
            ),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildBadges(List<String> badges) {
    final badgeMap = {
      'first_calm': ('🌿', 'First Calm'),
      'panic_reset_hero': ('🛡️', 'Panic Reset Hero'),
      '7_days_calm': ('🔥', '7 Days Calm'),
      'safe_space_explorer': ('🗺️', 'Safe Space Explorer'),
      'sensory_master': ('👁️', 'Sensory Master'),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withAlpha(128),
        borderRadius: AppRadius.lg,
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "YOUR BADGES",
            style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
          ),
          AppSpacing.v12,
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: badges.map((badge) {
              final data = badgeMap[badge];
              if (data == null) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.calmTeal.withAlpha(26),
                  borderRadius: AppRadius.pill,
                  border: Border.all(color: AppColors.calmTeal.withAlpha(77)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(data.$1, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      data.$2,
                      style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(GroundingSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withAlpha(128),
        borderRadius: AppRadius.md,
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.calmTeal.withAlpha(51),
              borderRadius: AppRadius.sm,
            ),
            child: const Icon(Icons.self_improvement_rounded, color: AppColors.calmTeal, size: 20),
          ),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.exerciseType.label,
                  style: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary),
                ),
                Text(
                  "${session.durationSecs}s session",
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (session.calmAfter != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successSoft.withAlpha(51),
                borderRadius: AppRadius.sm,
              ),
              child: Text(
                "${session.calmAfter}/10",
                style: AppTypography.labelMedium.copyWith(color: AppColors.calmTeal),
              ),
            ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
        child: Column(
          children: [
            const Text("🌱", style: TextStyle(fontSize: 56)),
            AppSpacing.v16,
            Text(
              "Your grounding journey starts here",
              textAlign: TextAlign.center,
              style: AppTypography.headingM.copyWith(color: AppColors.textPrimary),
            ),
            AppSpacing.v8,
            Text(
              "Reconnect with the present whenever you need.\nChoose an exercise above to begin.",
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textMuted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
