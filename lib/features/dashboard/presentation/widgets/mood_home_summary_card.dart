import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../mood/providers/analytics_provider.dart';
import '../../../mood/models/mood_model.dart';

class MoodHomeSummaryCard extends ConsumerWidget {
  const MoodHomeSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(moodHomeWidgetProvider);

    return homeDataAsync.when(
      loading: () => _buildShimmer(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        if (!data.hasLogs) return _buildEmptyState(context);
        return _buildCard(context, data);
      },
    );
  }

  Widget _buildCard(BuildContext context, MoodHomeWidget data) {
    final color = _parseColor(data.latestColor) ?? DashboardTheme.primaryPurple;

    return GestureDetector(
      onTap: () => context.push('/mood-analytics'),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DashboardTheme.radiusXL),
          boxShadow: DashboardTheme.softShadow(color),
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  // Mood Circle
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        data.latestEmoji ?? '😐',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              data.latestMood ?? 'Steady',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: DashboardTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                (data.latestCategory ?? 'neutral').toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.loggedAt != null 
                              ? 'Last logged ${DateFormat('jm').format(data.loggedAt!)}'
                              : 'Just logged',
                          style: DashboardTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Streak Badge
                  _buildStreakBadge(data.streaks.dailyCheckin),
                ],
              ),
            ),

            // Sparkline / Mini Chart Section
            if (data.sparkline.isNotEmpty)
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Past 7 days',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: DashboardTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSparklineEffect(data.sparkline, color),
                    ),
                  ],
                ),
              ),

            const Divider(height: 1, thickness: 0.5, indent: 20, endIndent: 20),

            // Bottom Message Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: DashboardTheme.accentViolet, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.insightMessage,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: DashboardTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: DashboardTheme.textTertiary, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSparklineEffect(List<double> points, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: points.map((p) {
        // Map 1-5 score to height
        final height = (p / 5.0) * 24 + 4;
        return Container(
          width: 4,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: points.indexOf(p) == points.length - 1 ? 0.8 : 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStreakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE65100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/mood-checkin'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DashboardTheme.radiusXL),
          border: Border.all(color: DashboardTheme.primaryPurple.withValues(alpha: 0.1)),
          boxShadow: DashboardTheme.softShadow(Colors.black),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DashboardTheme.primaryPurple.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('✨', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log your mood',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: DashboardTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Track your emotions to unlock insights.',
                    style: DashboardTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: DashboardTheme.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DashboardTheme.radiusXL),
      ),
      child: const Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  Color? _parseColor(String? hex) {
    if (hex == null) return null;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }
}
