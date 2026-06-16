import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';

import '../../data/nova_personality.dart';
import 'nova_avatar_widget.dart';
import 'nova_suggestion_chips.dart';

class NovaEmptyState extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;

  const NovaEmptyState({super.key, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = NovaPersonality.getGreeting(hour);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Breathing Nova avatar
            const NovaAvatarWidget(size: 88, isActive: true),
            AppSpacing.v32,

            // Emotional greeting
            Text(
              greeting,
              style: AppTypography.headingLarge,
              textAlign: TextAlign.center,
            ),
            AppSpacing.v12,

            // Supportive message
            Text(
              "You can talk to me about anything.\nNo pressure. We can start small.",
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.v32,

            // Suggestion chips
            NovaSuggestionChips(onSuggestionTap: onSuggestionTap),
          ],
        ),
      ),
    );
  }
}
