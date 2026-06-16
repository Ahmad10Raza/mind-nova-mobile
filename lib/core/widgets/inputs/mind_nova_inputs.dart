import 'package:flutter/material.dart';
import '../../design/colors/app_colors.dart';
import '../../design/radius/app_radius.dart';
import '../../design/spacing/app_spacing.dart';
import '../../design/typography/app_typography.dart';
import '../../design/borders/app_borders.dart';

class MindNovaTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;

  const MindNovaTextField({
    Key? key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTypography.body,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        contentPadding: const EdgeInsets.all(AppSpacing.s16),
        border: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: AppBorders.subtle,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: AppBorders.subtle,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: AppBorders.focus,
        ),
      ),
    );
  }
}

class MindNovaSearchField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const MindNovaSearchField({
    Key? key,
    this.hintText = 'Search...',
    this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTypography.body,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: AppRadius.full,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
