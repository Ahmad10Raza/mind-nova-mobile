import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

import '../../data/emotional_states.dart';

/// Emotionally intelligent check-in grid.
/// Not an emoji picker — each state has description and intent.
class EmotionalStateSelector extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<EmotionalState> onSelect;

  const EmotionalStateSelector({
    super.key,
    this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: AppTypography.headingMedium,
        ),
        AppSpacing.v4,
        Text(
          'Choose what feels closest.',
          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
        ),
        AppSpacing.v20,

        // Group by category
        _buildCategorySection('Feeling good', EmotionalStates.byCategory('positive')),
        AppSpacing.v16,
        _buildCategorySection('Somewhere in between', EmotionalStates.byCategory('neutral')),
        AppSpacing.v16,
        _buildCategorySection('Having a hard time', EmotionalStates.byCategory('difficult')),
        AppSpacing.v16,
        _buildCategorySection('Need support', EmotionalStates.byCategory('critical')),
      ],
    );
  }

  Widget _buildCategorySection(String title, List<EmotionalState> states) {
    if (states.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.caption.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.v8,
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: states.map((state) {
            final isSelected = state.id == selectedId;
            return GestureDetector(
              onTap: () => onSelect(state),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? state.color.withOpacity(0.15)
                      : AppColors.backgroundSecondary,
                  borderRadius: AppRadius.sm,
                  border: Border.all(
                    color: isSelected
                        ? state.color.withOpacity(0.4)
                        : AppColors.backgroundTertiary,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(state.icon, color: state.color, size: 18),
                    AppSpacing.h8,
                    Text(
                      state.label,
                      style: AppTypography.caption.copyWith(
                        color: isSelected ? state.color : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
