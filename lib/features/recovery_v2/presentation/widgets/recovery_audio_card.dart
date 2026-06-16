import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/design/shadows/app_shadows.dart';

import '../../data/recovery_modes.dart';

class RecoveryAudioCard extends StatelessWidget {
  final RecoveryAudioCategory category;

  const RecoveryAudioCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(category.route),
      child: Container(
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
                color: category.color.withOpacity(0.12),
                borderRadius: AppRadius.sm,
              ),
              child: Icon(category.icon, color: category.color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  style: AppTypography.headingMedium.copyWith(fontSize: 14),
                ),
                AppSpacing.v4,
                Text(
                  category.description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
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
