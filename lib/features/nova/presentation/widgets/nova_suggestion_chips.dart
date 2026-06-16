import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

import '../../data/nova_personality.dart';

class NovaSuggestionChips extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;

  const NovaSuggestionChips({super.key, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s8,
      runSpacing: AppSpacing.s8,
      alignment: WrapAlignment.center,
      children: NovaPersonality.conversationStarters.map((suggestion) {
        return GestureDetector(
          onTap: () => onSuggestionTap(suggestion.text),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s12,
            ),
            decoration: BoxDecoration(
              color: suggestion.color.withOpacity(0.08),
              borderRadius: AppRadius.full,
              border: Border.all(color: suggestion.color.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(suggestion.icon, color: suggestion.color, size: 16),
                AppSpacing.h8,
                Text(
                  suggestion.text,
                  style: AppTypography.caption.copyWith(
                    color: suggestion.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
