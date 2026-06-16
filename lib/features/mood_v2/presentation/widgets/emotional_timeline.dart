import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/design/shadows/app_shadows.dart';

import '../../../mood/models/mood_model.dart';

/// Emotional timeline — reflective, artistic, soft.
/// NOT an aggressive chart. A gentle visual flow of emotional life.
class EmotionalTimeline extends StatelessWidget {
  final List<MoodHistoryEntry> entries;

  const EmotionalTimeline({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.s24),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: AppRadius.md,
        ),
        child: Column(
          children: [
            Icon(Icons.timeline_rounded, color: AppColors.textMuted, size: 32),
            AppSpacing.v12,
            Text(
              'Your emotional timeline will\nappear here as you check in.',
              style: AppTypography.body.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Emotional timeline', style: AppTypography.headingMedium),
        AppSpacing.v4,
        Text(
          'Your recent emotional journey',
          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
        ),
        AppSpacing.v16,
        ...entries.take(7).map((entry) => _TimelineEntry(entry: entry)),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final MoodHistoryEntry entry;

  const _TimelineEntry({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(entry.color);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + line
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                ),
                Container(
                  width: 2,
                  height: 48,
                  color: AppColors.backgroundTertiary,
                ),
              ],
            ),
          ),
          AppSpacing.h12,

          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: AppRadius.sm,
              ),
              child: Row(
                children: [
                  Text(entry.emoji, style: const TextStyle(fontSize: 20)),
                  AppSpacing.h12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.moodName,
                          style: AppTypography.headingMedium.copyWith(fontSize: 14),
                        ),
                        Text(
                          _formatTime(entry.createdAt),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.textMuted;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}
