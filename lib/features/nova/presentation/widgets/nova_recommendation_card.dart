import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

import '../../data/nova_personality.dart';

/// An inline tool recommendation card that Nova can display
/// mid-conversation when it detects relevant emotional context.
class NovaRecommendationCard extends StatelessWidget {
  final NovaToolRecommendation recommendation;

  const NovaRecommendationCard({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16, left: 48),
      child: GestureDetector(
        onTap: () => context.push(recommendation.route),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: recommendation.color.withOpacity(0.08),
            borderRadius: AppRadius.md,
            border: Border.all(color: recommendation.color.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s8),
                decoration: BoxDecoration(
                  color: recommendation.color.withOpacity(0.15),
                  borderRadius: AppRadius.sm,
                ),
                child: Icon(
                  recommendation.icon,
                  color: recommendation.color,
                  size: 20,
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.toolName,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: recommendation.color,
                      ),
                    ),
                    AppSpacing.v4,
                    Text(
                      recommendation.message,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: recommendation.color,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
