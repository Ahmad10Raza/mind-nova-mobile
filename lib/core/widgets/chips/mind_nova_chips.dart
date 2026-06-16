import 'package:flutter/material.dart';
import '../../design/colors/app_colors.dart';
import '../../design/radius/app_radius.dart';
import '../../design/spacing/app_spacing.dart';
import '../../design/typography/app_typography.dart';

class EmotionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? activeColor;

  const EmotionChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.novaPurple;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppColors.backgroundSecondary,
          borderRadius: AppRadius.full,
          border: Border.all(
            color: isSelected ? color : AppColors.backgroundSecondary,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? color : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
