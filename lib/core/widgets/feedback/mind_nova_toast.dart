import 'package:flutter/material.dart';
import '../../design/colors/app_colors.dart';
import '../../design/typography/app_typography.dart';
import '../../design/radius/app_radius.dart';
import '../../design/spacing/app_spacing.dart';

class MindNovaToast {
  MindNovaToast._();

  static void show(BuildContext context, {required String message, IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
        margin: const EdgeInsets.all(AppSpacing.s24),
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.novaPurpleLight, size: 20),
              AppSpacing.h12,
            ],
            Expanded(
              child: Text(
                message,
                style: AppTypography.body.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
