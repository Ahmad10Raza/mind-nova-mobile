import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../../ai_reports/providers/weekly_report_provider.dart';

class ExploreHeroSection extends ConsumerWidget {
  const ExploreHeroSection({super.key});

  String _getRouteForSuggestion(String suggestion) {
    final lower = suggestion.toLowerCase();
    if (lower.contains('mood') || lower.contains('check-in')) return '/mood-analytics';
    if (lower.contains('breath') || lower.contains('4-7-8')) return '/breathing';
    if (lower.contains('sleep')) return '/sleep';
    if (lower.contains('recovery')) return '/recovery';
    if (lower.contains('journal') || lower.contains('write')) return '/journal';
    if (lower.contains('meditat') || lower.contains('mindful')) return '/meditation';
    if (lower.contains('ground')) return '/grounding';
    if (lower.contains('gratitude')) return '/gratitude';
    if (lower.contains('audio') || lower.contains('sound')) return '/sleep/sounds';
    return '/tools';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState.displayName ?? 'Explorer';

    final reportAsync = ref.watch(weeklyReportProvider);
    
    // Fallback and dynamic values
    final report = reportAsync.value;
    final scoreValue = report?.cmhiWeeklyScore ?? report?.wellnessScore ?? 84.0;
    final wellnessScoreStr = reportAsync.isLoading ? '--' : scoreValue.round().toString();
    
    String scoreLabel = 'Pending';
    if (!reportAsync.isLoading) {
      if (scoreValue >= 80) scoreLabel = 'Strong';
      else if (scoreValue >= 60) scoreLabel = 'Balanced';
      else scoreLabel = 'Needs Attention';
    }

    String moodForecast = 'Analyzing...';
    if (!reportAsync.isLoading) {
      if (report != null) {
        final trend = report.moodTrend.toUpperCase();
        if (trend == 'IMPROVING') moodForecast = 'Clear Skies';
        else if (trend == 'DECLINING') moodForecast = 'Storm Warning';
        else if (trend == 'VOLATILE') moodForecast = 'Turbulent';
        else moodForecast = 'Stable';
      } else {
        moodForecast = 'Clear Skies';
      }
    }

    // Dynamic greeting
    final hour = DateTime.now().hour;
    String timeGreeting = 'Good evening';
    if (hour < 12) timeGreeting = 'Good morning';
    else if (hour < 17) timeGreeting = 'Good afternoon';

    // Dynamic suggestion
    String nextSuggestion = '4-7-8 Breathing (2m)';
    if (report != null && report.aiRecommendations.isNotEmpty) {
      nextSuggestion = report.aiRecommendations.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // AI Wellness Command Center (Hero)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          decoration: BoxDecoration(
            borderRadius: AppRadius.xl,
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.surfaceHighest,
                AppColors.backgroundPrimary,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'NOVA INTELLIGENCE',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              AppSpacing.v16,
              Text(
                '$timeGreeting, $userName. Your internal resonance is stabilizing.',
                style: AppTypography.displayMedium.copyWith(fontSize: 28, height: 1.2),
              ),
              AppSpacing.v24,
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wellness Score',
                          style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted),
                        ),
                        RichText(
                          text: TextSpan(
                            text: '$wellnessScoreStr ',
                            style: AppTypography.headingLarge.copyWith(color: AppColors.secondary, fontSize: 24),
                            children: [
                              TextSpan(
                                text: scoreLabel,
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted.withOpacity(0.6)),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mood Forecast',
                          style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted),
                        ),
                        Text(
                          moodForecast,
                          style: AppTypography.headingLarge.copyWith(fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.v32,
              ElevatedButton.icon(
                onPressed: () => context.push('/chat'),
                icon: const Icon(Icons.mic, color: AppColors.onPrimary),
                label: Text('Speak with Nova', style: AppTypography.headingSmall.copyWith(color: AppColors.onPrimary)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                  elevation: 0,
                ),
              ),
                  ],
                ),
              ),
              // Suggestion moved to bottom card
            ],
          ),
        ),
        AppSpacing.v16,
        // Nova Dynamic Suggestion Card
        GestureDetector(
          onTap: () => context.push(_getRouteForSuggestion(nextSuggestion)),
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
            padding: const EdgeInsets.all(AppSpacing.s24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary.withOpacity(0.6),
              borderRadius: AppRadius.xl,
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.novaPurple, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'NOVA SUGGESTS',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.novaPurple,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                AppSpacing.v12,
                Text(nextSuggestion, style: AppTypography.displaySmall.copyWith(fontSize: 22)),
                AppSpacing.v8,
                Text(
                  'Based on your recent check-in, this will help balance your mood.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                ),
                AppSpacing.v16,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.novaPurple.withOpacity(0.2),
                    borderRadius: AppRadius.pill,
                    border: Border.all(color: AppColors.novaPurple.withOpacity(0.4)),
                  ),
                  child: Text(
                    'Begin Session',
                    style: AppTypography.labelMedium.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
