import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../domain/meditation_model.dart';
import '../providers/meditation_provider.dart';

class RecoveryRecentSection extends ConsumerWidget {
  const RecoveryRecentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentSessionsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: recentAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) return _buildEmptyState();
          return _buildSessionList(sessions.take(5).toList());
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(
                color: AppColors.novaPurple, strokeWidth: 2),
          ),
        ),
        error: (_, __) => _buildEmptyState(),
      ),
    );
  }

  Widget _buildSessionList(List<MeditationSession> sessions) {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';

    final grouped = <String, List<MeditationSession>>{};
    for (final s in sessions) {
      final dateStr =
          '${s.completedAt.year}-${s.completedAt.month}-${s.completedAt.day}';
      String label;
      if (dateStr == todayStr) {
        label = 'Today';
      } else if (dateStr == yesterdayStr) {
        label = 'Yesterday';
      } else {
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ];
        label = '${months[s.completedAt.month - 1]} ${s.completedAt.day}';
      }
      grouped.putIfAbsent(label, () => []).add(s);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupLabel(entry.key),
            AppSpacing.v8,
            ...entry.value.map((session) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SessionCard(session: session),
                )),
            AppSpacing.v4,
          ],
        );
      }).toList(),
    );
  }

  Widget _buildGroupLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.novaPurple,
            borderRadius: AppRadius.xs,
          ),
        ),
        AppSpacing.h8,
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s32),
      child: Center(
        child: Column(
          children: [
            const Text('🌱', style: TextStyle(fontSize: 40)),
            AppSpacing.v12,
            Text(
              'No sessions yet. Start your recovery.',
              style:
                  AppTypography.body.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final MeditationSession session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final title = session.content?.title ?? 'Recovery Session';
    final improvement = (session.calmAfter ?? 0) - (session.calmBefore ?? 0);
    final category = session.content?.category ?? 'General';
    final targetSecs = (session.content?.durationMinutes ?? 10) * 60;
    final completion = (session.durationSecs / targetSecs).clamp(0.0, 1.0);
    final completionPct = (completion * 100).toInt();

    // Time
    final hour = session.completedAt.hour;
    final min = session.completedAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hr12 = hour % 12 == 0 ? 12 : hour % 12;
    final timeStr = '$hr12:$min $period';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: AppRadius.md,
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                  borderRadius: AppRadius.sm,
                ),
                child: const Icon(Icons.self_improvement_rounded,
                    color: Colors.white, size: 18),
              ),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headingSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeStr,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    improvement >= 0 ? '+$improvement' : '$improvement',
                    style: AppTypography.headingSmall.copyWith(
                      color: improvement >= 0
                          ? AppColors.successSoft
                          : AppColors.emotionalDangerMuted,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'mood lift',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.textMuted, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.v12,
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.novaPurple.withAlpha(26),
                  borderRadius: AppRadius.xs,
                ),
                child: Text(
                  _formatCategory(category),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.novaPurpleLight,
                    fontSize: 10,
                  ),
                ),
              ),
              AppSpacing.h8,
              Text(
                '${session.durationSecs ~/ 60} min',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textMuted, fontSize: 11),
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: AppRadius.xs,
                child: SizedBox(
                  width: 70,
                  child: LinearProgressIndicator(
                    value: completion,
                    backgroundColor: Colors.white.withAlpha(20),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completionPct >= 95
                          ? AppColors.successSoft
                          : AppColors.warmSupport,
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
              AppSpacing.h4,
              Text(
                '$completionPct%',
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.textMuted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCategory(String cat) {
    return cat
        .split('_')
        .map((w) => w.isNotEmpty
            ? w[0].toUpperCase() + w.substring(1).toLowerCase()
            : '')
        .join(' ');
  }
}
