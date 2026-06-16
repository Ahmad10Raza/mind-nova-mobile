import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

class _JourneyData {
  final String title;
  final String emoji;
  final double progress;
  final int day;
  final int total;
  final int mins;
  final List<Color> gradient;

  const _JourneyData({
    required this.title,
    required this.emoji,
    required this.progress,
    required this.day,
    required this.total,
    required this.mins,
    required this.gradient,
  });
}

const _journeys = [
  _JourneyData(
    title: '7 Day Overthinking Reset',
    emoji: '😰',
    progress: 0.43,
    day: 3,
    total: 7,
    mins: 10,
    gradient: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
  ),
  _JourneyData(
    title: '10 Day Sleep Recovery',
    emoji: '🌙',
    progress: 0.30,
    day: 3,
    total: 10,
    mins: 15,
    gradient: [Color(0xFF1E3A8A), Color(0xFF312E81)],
  ),
  _JourneyData(
    title: '7 Day Stress Detox',
    emoji: '🧘',
    progress: 0.0,
    day: 0,
    total: 7,
    mins: 12,
    gradient: [Color(0xFF0D9488), Color(0xFF0E7490)],
  ),
  _JourneyData(
    title: '14 Day Burnout Recovery',
    emoji: '🔥',
    progress: 0.14,
    day: 2,
    total: 14,
    mins: 15,
    gradient: [Color(0xFFEA580C), Color(0xFFB91C1C)],
  ),
  _JourneyData(
    title: '7 Day Emotional Healing',
    emoji: '💜',
    progress: 0.0,
    day: 0,
    total: 7,
    mins: 10,
    gradient: [Color(0xFFBE185D), Color(0xFF9333EA)],
  ),
  _JourneyData(
    title: '14 Day Confidence Builder',
    emoji: '⭐',
    progress: 0.0,
    day: 0,
    total: 14,
    mins: 8,
    gradient: [Color(0xFFD97706), Color(0xFFEA580C)],
  ),
];

class RecoveryJourneysSection extends StatelessWidget {
  const RecoveryJourneysSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 195,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
        physics: const BouncingScrollPhysics(),
        itemCount: _journeys.length,
        separatorBuilder: (_, __) => AppSpacing.h12,
        itemBuilder: (context, index) {
          final j = _journeys[index];
          final started = j.progress > 0;
          final completionPct = (j.progress * 100).toInt();

          return Container(
            width: 200,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: j.gradient,
              ),
              borderRadius: AppRadius.lg,
              border: Border.all(color: Colors.white.withAlpha(20)),
              boxShadow: [
                BoxShadow(
                  color: j.gradient.first.withAlpha(89),
                  blurRadius: 22,
                  spreadRadius: -4,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(j.emoji, style: const TextStyle(fontSize: 22)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(38),
                        borderRadius: AppRadius.xs,
                      ),
                      child: Text(
                        'Day ${j.day}/${j.total}',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.v8,
                Text(
                  j.title,
                  style: AppTypography.headingSmall
                      .copyWith(color: Colors.white, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${j.mins} min · $completionPct% done',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withAlpha(178),
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: AppRadius.xs,
                  child: LinearProgressIndicator(
                    value: j.progress,
                    backgroundColor: Colors.white.withAlpha(51),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 4,
                  ),
                ),
                AppSpacing.v8,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/meditation/player'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(51),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.sm),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                    ),
                    child: Text(
                      started ? 'Continue →' : 'Begin →',
                      style: AppTypography.labelMedium
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
