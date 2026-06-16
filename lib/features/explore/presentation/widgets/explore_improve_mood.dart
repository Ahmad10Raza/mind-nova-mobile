import 'package:flutter/material.dart';
import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import 'package:go_router/go_router.dart';

class ExploreImproveMood extends StatelessWidget {
  const ExploreImproveMood({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: Text(
            'Improve My Mood Today',
            style: AppTypography.headingLarge,
          ),
        ),
        AppSpacing.v16,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.s12,
            crossAxisSpacing: AppSpacing.s12,
            childAspectRatio: 0.9,
            children: [
              _buildMoodChip(icon: Icons.water_drop, color: AppColors.primary, label: 'Anxious', onTap: () => context.push('/breathing')),
              _buildMoodChip(icon: Icons.waves, color: AppColors.secondary, label: 'Overwhelmed', onTap: () => context.push('/grounding')),
              _buildMoodChip(icon: Icons.bedtime, color: AppColors.tertiary, label: 'Can\'t Sleep', onTap: () => context.push('/sleep/emergency')),
              _buildMoodChip(icon: Icons.center_focus_strong, color: AppColors.primary, label: 'Need Focus', onTap: () => context.push('/focus')),
              _buildMoodChip(icon: Icons.group, color: AppColors.secondary, label: 'Lonely', onTap: () => context.push('/community')),
              _buildMoodChip(icon: Icons.healing, color: AppColors.error, label: 'Need Help', isError: true, onTap: () => context.push('/crisis')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodChip({required IconData icon, required Color color, required String label, bool isError = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary.withOpacity(0.5),
          borderRadius: AppRadius.lg,
          border: isError ? Border.all(color: AppColors.error.withOpacity(0.2)) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            AppSpacing.v8,
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(color: isError ? AppColors.error : AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
