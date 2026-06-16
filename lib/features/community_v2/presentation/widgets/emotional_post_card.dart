import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

import '../../data/community_data.dart';

/// Emotional post card — replaces like-based social cards.
/// Reactions are supportive, not competitive.
class EmotionalPostCard extends StatelessWidget {
  final String authorAlias;
  final String content;
  final String timeAgo;
  final String? groupName;
  final Map<String, int> reactions; // reaction_id → count

  const EmotionalPostCard({
    super.key,
    required this.authorAlias,
    required this.content,
    required this.timeAgo,
    this.groupName,
    this.reactions = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: AppRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author + time
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.novaPurple.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    authorAlias.isNotEmpty ? authorAlias[0].toUpperCase() : '?',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.novaPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              AppSpacing.h8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorAlias,
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (groupName != null)
                      Text(
                        'in $groupName • $timeAgo',
                        style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
                      )
                    else
                      Text(
                        timeAgo,
                        style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
                      ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.v16,

          // Content
          Text(
            content,
            style: AppTypography.body.copyWith(height: 1.5),
          ),
          AppSpacing.v16,

          // Emotional reactions (NOT likes)
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: EmotionalReactions.all.map((reaction) {
              final count = reactions[reaction.id] ?? 0;
              return GestureDetector(
                onTap: () {}, // TODO: hook up reaction
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                    vertical: AppSpacing.s4,
                  ),
                  decoration: BoxDecoration(
                    color: count > 0
                        ? AppColors.novaPurple.withOpacity(0.08)
                        : AppColors.backgroundTertiary,
                    borderRadius: AppRadius.full,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(reaction.emoji, style: const TextStyle(fontSize: 13)),
                      if (count > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '$count',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
