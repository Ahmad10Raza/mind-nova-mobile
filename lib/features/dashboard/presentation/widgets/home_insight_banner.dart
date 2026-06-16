import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/design/borders/app_borders.dart';

class HomeInsightBanner extends StatelessWidget {
  final String? insightText;

  const HomeInsightBanner({super.key, this.insightText});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Optional Insight
        if (insightText != null && insightText!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s20),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              gradient: LinearGradient(
                colors: [AppColors.calmTeal.withOpacity(0.08), Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.md,
              border: Border.all(color: AppColors.calmTeal.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.calmTeal,
                  size: 20,
                ),
                AppSpacing.h12,
                Expanded(
                  child: Text(
                    insightText!,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

        AppSpacing.v16,

        // Explore Gateway
        GestureDetector(
          onTap: () => context.push('/explore'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s20,
              vertical: AppSpacing.s16,
            ),
            decoration: BoxDecoration(
              color: AppColors.novaPurple.withOpacity(0.06),
              borderRadius: AppRadius.md,
              border: Border.all(color: AppColors.novaPurple.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Support Tools',
                      style: AppTypography.headingMedium.copyWith(fontSize: 15),
                    ),
                    AppSpacing.v4,
                    Text(
                      'Discover more ways to support your journey',
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.novaPurpleLight,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
