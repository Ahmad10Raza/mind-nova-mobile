import 'package:flutter/material.dart';
import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import 'package:go_router/go_router.dart';

class ExploreJourneySection extends StatelessWidget {
  const ExploreJourneySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: Text(
            'Guided Journeys',
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
            childAspectRatio: 1.1,
            children: [
              _buildJourneyCard(
                icon: Icons.self_improvement,
                color: AppColors.primary,
                title: 'Anxiety Reset',
                progress: 0.4,
                statusText: 'Day 3 of 7',
                onTap: () => context.push('/journeys'),
              ),
              _buildJourneyCard(
                icon: Icons.battery_charging_full,
                color: AppColors.secondary,
                title: 'Burnout Recovery',
                progress: 0.1,
                statusText: 'Day 1 of 14',
                onTap: () => context.push('/journeys'),
              ),
              _buildJourneyCard(
                icon: Icons.bedtime,
                color: AppColors.tertiary,
                title: 'Sleep Repair',
                progress: 0.0,
                statusText: '10 Days • Start',
                onTap: () => context.push('/journeys'),
              ),
              _buildJourneyCard(
                icon: Icons.center_focus_strong,
                color: AppColors.primary,
                title: 'Focus Recovery',
                progress: 0.0,
                statusText: '5 Days • Start',
                onTap: () => context.push('/journeys'),
              ),
              _buildJourneyCard(
                icon: Icons.favorite,
                color: AppColors.secondary,
                title: 'Emotional Healing',
                progress: 0.0,
                statusText: '21 Days • Start',
                onTap: () => context.push('/journeys'),
              ),
              _buildJourneyCard(
                icon: Icons.psychology,
                color: AppColors.tertiary,
                title: 'Overthinking Reset',
                progress: 0.0,
                statusText: '7 Days • Start',
                onTap: () => context.push('/journeys'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyCard({
    required IconData icon,
    required Color color,
    required String title,
    required double progress,
    required String statusText,
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
            AppSpacing.v8,
            ClipRRect(
              borderRadius: AppRadius.full,
              child: LinearProgressIndicator(
                value: progress > 0 ? progress : 0,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
            AppSpacing.v8,
            Text(statusText, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
