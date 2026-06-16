import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../domain/meditation_model.dart';
import '../providers/meditation_provider.dart';

class RecoveryStatsSection extends ConsumerWidget {
  const RecoveryStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(meditationDashboardProvider);

    return dashboardAsync.when(
      data: (stats) => _buildStats(stats),
      loading: () => _buildStats(null),
      error: (_, __) => _buildStats(null),
    );
  }

  Widget _buildStats(MeditationDashboardStats? stats) {
    final recoveryScore =
        '+${(stats?.averageCalmImprovement ?? 0).toStringAsFixed(0)}%';
    final currentFocus = _formatCategory(stats?.mostEffectiveCategory);
    final totalMinutes = stats?.totalMinutes ?? 0;
    final totalSessions = stats?.totalSessions ?? 0;
    final mostEffective = _formatCategory(stats?.favoriteCategory);

    // Weekly improvement estimate from streak
    final weeklyImprovement =
        stats != null && stats.currentStreak > 0 ? '+${stats.currentStreak * 3}%' : '+0%';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.favorite_rounded,
                  iconColor: AppColors.novaPurple,
                  value: recoveryScore,
                  label: 'Recovery Score',
                  gradient: [
                    AppColors.novaPurple.withAlpha(26),
                    AppColors.novaPurple.withAlpha(10),
                  ],
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: _StatCard(
                  icon: Icons.gps_fixed_rounded,
                  iconColor: AppColors.calmTeal,
                  value: currentFocus,
                  label: 'Current Focus',
                  gradient: [
                    AppColors.calmTeal.withAlpha(26),
                    AppColors.calmTeal.withAlpha(10),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.v12,
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up_rounded,
                  iconColor: AppColors.successSoft,
                  value: weeklyImprovement,
                  label: 'Weekly Improvement',
                  gradient: [
                    AppColors.successSoft.withAlpha(26),
                    AppColors.successSoft.withAlpha(10),
                  ],
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: _StatCard(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.warmSupport,
                  value: mostEffective,
                  label: 'Most Effective',
                  gradient: [
                    AppColors.warmSupport.withAlpha(26),
                    AppColors.warmSupport.withAlpha(10),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.v12,
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.timer_rounded,
                  iconColor: AppColors.recoveryBlue,
                  value: '${totalMinutes}m',
                  label: 'Recovery Minutes',
                  gradient: [
                    AppColors.recoveryBlue.withAlpha(26),
                    AppColors.recoveryBlue.withAlpha(10),
                  ],
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_rounded,
                  iconColor: const Color(0xFF0D9488),
                  value: '$totalSessions',
                  label: 'Total Sessions',
                  gradient: [
                    const Color(0xFF0D9488).withAlpha(26),
                    const Color(0xFF0D9488).withAlpha(10),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCategory(String? cat) {
    if (cat == null) return 'None';
    return cat
        .split('_')
        .map((w) => w.isNotEmpty
            ? w[0].toUpperCase() + w.substring(1).toLowerCase()
            : '')
        .join(' ');
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final List<Color> gradient;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: AppRadius.lg,
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          AppSpacing.v12,
          Text(
            value,
            style: AppTypography.headingM
                .copyWith(color: AppColors.textPrimary, fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption
                .copyWith(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
