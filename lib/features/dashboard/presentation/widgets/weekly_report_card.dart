import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../ai_reports/models/weekly_report_model.dart';
import '../../../ai_reports/providers/weekly_report_provider.dart';

class WeeklyReportCard extends ConsumerWidget {
  const WeeklyReportCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(weeklyReportProvider);

    return reportAsync.when(
      loading: () => _buildShimmer(),
      error: (_, __) => const SizedBox.shrink(),
      data: (report) {
        if (report == null) return const SizedBox.shrink();
        if (report.isStarter) return _buildStarterState(context, report);
        return _buildCard(context, report);
      },
    );
  }

  Widget _buildCard(BuildContext context, WeeklyReport report) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DashboardTheme.cardWhite,
        borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
        boxShadow: DashboardTheme.softShadow(Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DashboardTheme.primaryPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: DashboardTheme.primaryPurple, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    report.aiTitle ?? 'Weekly AI Insights',
                    style: DashboardTheme.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) => IconButton(
                    icon: Icon(Icons.refresh_rounded, color: DashboardTheme.textTertiary.withValues(alpha: 0.7), size: 20),
                    onPressed: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Generating fresh insights...')),
                        );
                        await ref.read(triggerWeeklyReportProvider(null).future);
                        ref.invalidate(weeklyReportProvider);
                        ref.invalidate(weeklyReportHistoryProvider);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                  ),
                ),
                _buildStatusBadge(report.crisisRiskLevel),
              ],
            ),
            const SizedBox(height: 16),

            // Metrics row
            Row(
              children: [
                _buildMetricChip('Mood', report.avgMoodScore.toStringAsFixed(1), const Color(0xFF00D2FF)),
                const SizedBox(width: 8),
                if (report.wellnessScore != null)
                  _buildMetricChip('Wellness', '${report.wellnessScore!.toInt()}', const Color(0xFF00E676)),
                const SizedBox(width: 8),
                if (report.recoveryScore != null)
                  _buildMetricChip('Recovery', '${report.recoveryScore!.toInt()}', const Color(0xFF7C4DFF)),
              ],
            ),
            const SizedBox(height: 14),

            // Summary
            Text(
              report.aiSummary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: DashboardTheme.bodyRegular.copyWith(height: 1.5),
            ),

            // Delta badge
            if (report.weekDelta != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    report.improved == true ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    color: report.improved == true ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${report.weekDelta! > 0 ? '+' : ''}${report.weekDelta!.toStringAsFixed(0)} vs last week',
                    style: DashboardTheme.bodySmall,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),

            // CTA
            Row(
              children: [
                _buildCTA(context, label: 'Full Report', icon: Icons.article_rounded,
                  onTap: () => context.push('/weekly-insight', extra: report)),
                const SizedBox(width: 8),
                _buildCTA(context, label: 'Talk to AI', icon: Icons.auto_awesome_rounded,
                  onTap: () => context.go('/chat')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: DashboardTheme.bodySmall.copyWith(fontSize: 10, color: DashboardTheme.textTertiary)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String level) {
    Color color;
    switch (level) {
      case 'CRITICAL': case 'HIGH': color = DashboardTheme.crisisRed; break;
      case 'MED': color = DashboardTheme.stressAmber; break;
      default: color = DashboardTheme.moodGreen;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(level, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
    );
  }

  Widget _buildCTA(BuildContext context, {required String label, required IconData icon, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: DashboardTheme.primaryPurple.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DashboardTheme.primaryPurple.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: DashboardTheme.primaryPurple, size: 16),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: DashboardTheme.primaryPurple)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Premium Starter State ──────────────────────────────────────
  Widget _buildStarterState(BuildContext context, WeeklyReport report) {
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: DashboardTheme.cardWhite,
            borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
            boxShadow: DashboardTheme.softShadow(Colors.black),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DashboardTheme.primaryPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: DashboardTheme.primaryPurple, size: 32),
              ),
              const SizedBox(height: 18),
              Text(report.aiTitle ?? 'Your Journey Begins ✨',
                style: DashboardTheme.heading2),
              const SizedBox(height: 10),
              Text(
                'Log moods, practice gratitude, and use wellness tools\nto unlock your personalized weekly insight.',
                textAlign: TextAlign.center,
                style: DashboardTheme.bodyRegular,
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () async {
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generating your weekly insight...')),
                    );
                    await ref.read(triggerWeeklyReportProvider(null).future);
                    ref.invalidate(weeklyReportProvider);
                    ref.invalidate(weeklyReportHistoryProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report generated successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to generate: ${e.toString()}')),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: DashboardTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: DashboardTheme.glowShadow(DashboardTheme.primaryPurple),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Generate Now (Test)',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Standard release: Every Sunday',
                style: DashboardTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(DashboardTheme.radiusXL),
      ),
      child: Center(
        child: CircularProgressIndicator(color: Colors.white.withValues(alpha: 0.3), strokeWidth: 2),
      ),
    );
  }
}
