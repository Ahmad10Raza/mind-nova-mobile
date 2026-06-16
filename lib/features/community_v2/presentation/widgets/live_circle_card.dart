import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/design/shadows/app_shadows.dart';

import '../../data/community_data.dart';

/// Live circle card — atmospheric, calming, no engagement pressure.
class LiveCircleCard extends StatelessWidget {
  final LiveCircleType circle;
  final bool isLiveNow;
  final int participantCount;
  final VoidCallback? onTap;

  const LiveCircleCard({
    super.key,
    required this.circle,
    this.isLiveNow = false,
    this.participantCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: AppRadius.md,
          boxShadow: AppShadows.shadowSubtle,
          border: Border.all(
            color: isLiveNow
                ? circle.color.withOpacity(0.25)
                : AppColors.backgroundTertiary,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s8),
                  decoration: BoxDecoration(
                    color: circle.color.withOpacity(0.12),
                    borderRadius: AppRadius.sm,
                  ),
                  child: Icon(circle.icon, color: circle.color, size: 18),
                ),
                if (isLiveNow)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
                    decoration: BoxDecoration(
                      color: AppColors.calmTeal.withOpacity(0.15),
                      borderRadius: AppRadius.full,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.calmTeal,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Live',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.calmTeal,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Title + description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(circle.title, style: AppTypography.headingMedium.copyWith(fontSize: 14)),
                AppSpacing.v4,
                Text(
                  circle.description,
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // Host type
            Row(
              children: [
                Icon(
                  circle.hostType == 'therapist'
                      ? Icons.verified_rounded
                      : Icons.person_rounded,
                  color: AppColors.textMuted,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  circle.hostType == 'therapist' ? 'Therapist-led' : 'Peer-hosted',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
