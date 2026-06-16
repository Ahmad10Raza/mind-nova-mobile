import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/design/shadows/app_shadows.dart';

import '../../data/community_data.dart';

/// Safe group card — intimate, emotionally labeled.
class SafeGroupCard extends StatelessWidget {
  final SafeGroup group;
  final VoidCallback? onTap;

  const SafeGroupCard({super.key, required this.group, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: AppRadius.md,
          boxShadow: AppShadows.shadowSubtle,
          border: Border.all(color: group.color.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s8),
                  decoration: BoxDecoration(
                    color: group.color.withOpacity(0.12),
                    borderRadius: AppRadius.sm,
                  ),
                  child: Icon(group.icon, color: group.color, size: 18),
                ),
                if (group.isModerated)
                  Icon(Icons.verified_rounded, color: AppColors.calmTeal.withOpacity(0.5), size: 14),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.title, style: AppTypography.headingMedium.copyWith(fontSize: 14)),
                AppSpacing.v4,
                Text(
                  group.description,
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
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
