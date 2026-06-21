import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/design/colors/app_colors.dart';
import '../../../core/design/surfaces/app_surfaces.dart';
import '../../../core/design/typography/app_typography.dart';
import '../../ai_reports/models/weekly_report_model.dart';
import '../providers/weekly_report_provider.dart';
import '../utils/weekly_report_pdf_generator.dart';

class WeeklyInsightScreen extends StatelessWidget {
  final WeeklyReport report;
  const WeeklyInsightScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final dateRange =
        '${DateFormat('MMM d').format(report.weekStartDate)} – ${DateFormat('MMM d, yyyy').format(report.weekEndDate)}';

    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeroHeader(context, dateRange),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  if (report.isStarter) ...[
                    _buildStarterCard(),
                  ] else ...[
                    _buildWellnessRing(),
                    const SizedBox(height: 28),
                    _buildSectionLabel('Key Metrics'),
                    const SizedBox(height: 12),
                    _buildMetricsGrid(),
                    const SizedBox(height: 28),
                    _buildSectionLabel('Emotional Radar'),
                    const SizedBox(height: 12),
                    _buildRadarChart(),
                    if (report.moodChartData.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      _buildSectionLabel('Mood Trend'),
                      const SizedBox(height: 12),
                      _buildMoodTrendChart(),
                    ],
                    const SizedBox(height: 28),
                    _buildSectionLabel('Wins This Week'),
                    const SizedBox(height: 12),
                    _buildWinsRow(),
                    const SizedBox(height: 28),
                    const SizedBox(height: 28),
                    _buildSectionLabel('Activity Overview'),
                    const SizedBox(height: 12),
                    _buildActivityOverviewRow(),
                    if (report.topToolsUsed.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildTopToolsRow(),
                    ],
                    if (report.assessmentHistory.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      _buildSectionLabel('Clinical Assessments'),
                      const SizedBox(height: 12),
                      _buildAssessmentHistory(),
                    ],
                    if (report.therapistData.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      _buildSectionLabel('Professional Care'),
                      const SizedBox(height: 12),
                      _buildTherapistData(),
                    ],
                    if (report.communityPostsCreated > 0 || report.communityComments > 0) ...[
                      const SizedBox(height: 28),
                      _buildSectionLabel('Community Impact'),
                      const SizedBox(height: 12),
                      _buildCommunityCard(),
                    ],
                    if (report.diaryEntriesDetailed.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      _buildSectionLabel('Diary Highlights'),
                      const SizedBox(height: 12),
                      _buildDiaryHighlightsCard(),
                    ],
                    const SizedBox(height: 28),
                    _buildSectionLabel('AI Deep Insight'),
                    const SizedBox(height: 12),
                    _buildAiInsightCard(),
                    const SizedBox(height: 20),
                    if (report.aiRecommendations.isNotEmpty) ...[
                      _buildSectionLabel('Recommendations'),
                      const SizedBox(height: 12),
                      ...report.aiRecommendations.asMap().entries.map(
                            (e) => _buildRecommendationTile(e.key + 1, e.value),
                          ),
                      const SizedBox(height: 20),
                    ],
                    if (report.weekDelta != null) ...[
                      _buildComparisonCard(),
                      const SizedBox(height: 20),
                    ],
                    _buildConfidenceBadge(),
                    const SizedBox(height: 20),
                    _buildCrisisStatusCard(),
                  ],
                  const SizedBox(height: 100), // Bottom padding for navigation bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  HERO HEADER
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildHeroHeader(BuildContext context, String dateRange) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppSurfaces.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white70),
          tooltip: 'Export as PDF',
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Preparing clinical PDF report...')),
            );
            try {
              await WeeklyReportPdfGenerator.exportAndShare(report);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to export: $e'), backgroundColor: Colors.red),
                );
              }
            }
          },
        ),
        Consumer(
          builder: (context, ref, _) => IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Re-generate Report',
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                        const SizedBox(height: 16),
                        Text(
                          'MindNova AI is analyzing your week...',
                          style: AppTypography.headingMedium.copyWith(fontSize: 14, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              try {
                await ref.read(triggerWeeklyReportProvider(null).future);
                ref.invalidate(weeklyReportProvider);
                ref.invalidate(weeklyReportHistoryProvider);
                
                // Close dialog
                if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Text('Weekly insights successfully generated!', style: AppTypography.body.copyWith(color: Colors.white)),
                        ],
                      ),
                      backgroundColor: const Color(0xFF7C4DFF),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              } catch (e) {
                // Close dialog
                if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error generating report: $e'),
                      backgroundColor: const Color(0xFFFF5252),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.backgroundSecondary.withOpacity(0.5), AppSurfaces.primary],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF5E4B8B), Color(0xFF00D2FF)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.face_3_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              report.aiTitle ?? 'Your Weekly MindNova Insight',
                              style: AppTypography.headingLarge.copyWith(fontSize: 20, color: AppColors.textPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(dateRange, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  WELLNESS SCORE RING
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildWellnessRing() {
    final score = report.wellnessScore ?? 0;
    final color = score >= 70 ? const Color(0xFF00E676) : score >= 40 ? const Color(0xFFFFAB00) : const Color(0xFFFF5252);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.08), AppSurfaces.primary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${score.toInt()}', style: AppTypography.heroXL.copyWith(fontSize: 28, color: color)),
                    Text('/ 100', style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textDisabled)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wellness Score', style: AppTypography.headingLarge.copyWith(fontSize: 18, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                if (report.improved != null)
                  Row(
                    children: [
                      Icon(
                        report.improved! ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        color: report.improved! ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        report.weekDelta != null
                            ? '${report.weekDelta! > 0 ? '+' : ''}${report.weekDelta!.toStringAsFixed(0)} vs last week'
                            : 'First report',
                        style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  METRICS GRID (6 cards)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.95,
      children: [
        _metricCard('Mood', report.avgMoodScore.toStringAsFixed(1), '/5', Icons.emoji_emotions_rounded, const Color(0xFF00D2FF)),
        _metricCard('Sleep', report.avgSleepHours != null ? report.avgSleepHours!.toStringAsFixed(1) : '0.0', 'hrs', Icons.bedtime_rounded, const Color(0xFF7C4DFF)),
        _metricCard('Volatility', report.emotionalVolatility != null ? report.emotionalVolatility!.toStringAsFixed(1) : '0.0', 'σ', Icons.show_chart_rounded, _volColor(report.emotionalVolatility)),
        _metricCard('Burnout', report.burnoutRisk != null ? '${(report.burnoutRisk! * 100).toInt()}' : '—', '%', Icons.local_fire_department_rounded, _burnColor(report.burnoutRisk)),
        _metricCard('Recovery', report.recoveryScore != null ? '${report.recoveryScore!.toInt()}' : '—', '/100', Icons.favorite_rounded, const Color(0xFF00E676)),
        _metricCard('Engage', report.engagementScore != null ? '${report.engagementScore!.toInt()}' : '—', '/100', Icons.bolt_rounded, const Color(0xFFFFAB00)),
      ],
    );
  }

  Widget _metricCard(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: AppTypography.headingLarge.copyWith(fontSize: 20, color: AppColors.textPrimary)),
                const SizedBox(width: 2),
                Text(unit, style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textDisabled)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Color _volColor(double? v) => v == null ? Colors.grey : v > 1.5 ? const Color(0xFFFF5252) : v > 1.0 ? const Color(0xFFFFAB00) : const Color(0xFF00E676);
  Color _burnColor(double? b) => b == null ? Colors.grey : b > 0.7 ? const Color(0xFFFF5252) : b > 0.4 ? const Color(0xFFFFAB00) : const Color(0xFF00E676);

  // ══════════════════════════════════════════════════════════════════════
  //  RADAR CHART
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildRadarChart() {
    final moodN = (report.avgMoodScore / 5.0).clamp(0.0, 1.0);
    final sleepN = ((report.avgSleepHours ?? 0) / 9.0).clamp(0.0, 1.0);
    final stabilityN = (1.0 - (report.emotionalVolatility ?? 0) / 2.0).clamp(0.0, 1.0);
    final recoveryN = ((report.recoveryScore ?? 0) / 100.0).clamp(0.0, 1.0);
    final engageN = ((report.engagementScore ?? 0) / 100.0).clamp(0.0, 1.0);

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 4,
          ticksTextStyle: AppTypography.caption.copyWith(fontSize: 8, color: AppColors.textDisabled),
          tickBorderData: BorderSide(color: Colors.white.withOpacity(0.08)),
          gridBorderData: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5),
          titleTextStyle: AppTypography.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
          titlePositionPercentageOffset: 0.2,
          dataSets: [
            RadarDataSet(
              fillColor: const Color(0xFF5E4B8B).withOpacity(0.2),
              borderColor: const Color(0xFF9C27B0),
              borderWidth: 2,
              entryRadius: 4,
              dataEntries: [
                RadarEntry(value: moodN),
                RadarEntry(value: sleepN),
                RadarEntry(value: stabilityN),
                RadarEntry(value: recoveryN),
                RadarEntry(value: engageN),
              ],
            ),
          ],
          getTitle: (index, angle) {
            const titles = ['Mood', 'Sleep', 'Stability', 'Recovery', 'Engage'];
            return RadarChartTitle(text: titles[index]);
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  MOOD TREND CHART
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildMoodTrendChart() {
    // Map data to FlSpot
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final Map<String, double> dataMap = {};
    for (var d in report.moodChartData) {
      if (d['day'] != null && d['score'] != null) {
        dataMap[d['day']] = (d['score'] as num).toDouble();
      }
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < days.length; i++) {
      spots.add(FlSpot(i.toDouble(), dataMap[days[i]] ?? 0));
    }

    // Filter out 0s if they mean "no data" for a cleaner line, or leave as 0? 
    // We'll just plot it as is to show the trend. If it's 0, it means no logs that day.
    
    return Container(
      height: 220,
      padding: const EdgeInsets.only(top: 24, right: 24, left: 16, bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0F3460).withOpacity(0.4), Colors.transparent],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 5,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, // Fixes the duplicate half-day labels
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= days.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(days[value.toInt()], style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textDisabled)),
                  );
                },
                reservedSize: 22,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(value.toInt().toString(), style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textDisabled));
                },
                reservedSize: 28,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots.where((s) => s.y > 0).toList(), // Only connect dots where there's data
              isCurved: true,
              curveSmoothness: 0.35,
              color: const Color(0xFF00D2FF),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF00D2FF),
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF0F3460),
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [const Color(0xFF00D2FF).withOpacity(0.3), const Color(0xFF00D2FF).withOpacity(0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  WINS ROW
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildWinsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          if (report.streakScore > 0)
            _winChip('🔥 ${report.streakScore} day streak', const Color(0xFFFF9100)),
          if (report.meditationMinutes > 0)
            _winChip('🧘 ${report.meditationMinutes}m meditation', const Color(0xFF7C4DFF)),
          if (report.gratitudeCount > 0)
            _winChip('🙏 ${report.gratitudeCount} gratitudes', const Color(0xFF00E676)),
          if (report.journalCount > 0)
            _winChip('📝 ${report.journalCount} journals', const Color(0xFF00D2FF)),
          if (report.groundingSessions > 0)
            _winChip('🌿 ${report.groundingSessions} grounding', const Color(0xFF4CAF50)),
          if (report.audioMinutes > 0)
            _winChip('🎵 ${report.audioMinutes}m audio', const Color(0xFFFFAB00)),
        ],
      ),
    );
  }

  Widget _winChip(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.25), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32), // Apple Fitness style pill
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: AppTypography.headingMedium.copyWith(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  AI INSIGHT CARD
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildAiInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF5E4B8B).withOpacity(0.15), const Color(0xFF0F3460).withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: Color(0xFF9C27B0), size: 20),
              const SizedBox(width: 8),
              Text('Nova AI', style: AppTypography.headingMedium.copyWith(fontSize: 14, color: const Color(0xFF9C27B0))),
            ],
          ),
          const SizedBox(height: 14),
          Text(report.aiSummary, style: AppTypography.body.copyWith(fontSize: 14, color: AppColors.textPrimary, height: 1.65)),
          if (report.aiWhatHelped != null) ...[
            const SizedBox(height: 16),
            _aiSubSection('💡 What Helped', report.aiWhatHelped!),
          ],
          if (report.aiChallenges != null) ...[
            const SizedBox(height: 12),
            _aiSubSection('⚡ Challenges', report.aiChallenges!),
          ],
          if (report.aiEncouragement != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(report.aiEncouragement!, style: AppTypography.body.copyWith(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textMuted, height: 1.5)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _aiSubSection(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.headingMedium.copyWith(fontSize: 13, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(text, style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  ACTIVITY, COMMUNITY, AND DIARY SECTIONS
  // ══════════════════════════════════════════════════════════════════════
  
  Widget _buildActivityOverviewRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF00D2FF).withOpacity(0.15), const Color(0xFF00D2FF).withOpacity(0.02)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.timer_rounded, color: Color(0xFF00D2FF), size: 28),
                const SizedBox(height: 12),
                Text('${report.totalTimeSpentMinutes}m', style: AppTypography.headingLarge.copyWith(fontSize: 24, color: AppColors.textPrimary)),
                Text('Time Spent', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF7C4DFF).withOpacity(0.15), const Color(0xFF7C4DFF).withOpacity(0.02)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.phone_iphone_rounded, color: Color(0xFF7C4DFF), size: 28),
                const SizedBox(height: 12),
                Text('${report.totalAppSessions}', style: AppTypography.headingLarge.copyWith(fontSize: 24, color: AppColors.textPrimary)),
                Text('Sessions', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopToolsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Tools Used', style: AppTypography.headingMedium.copyWith(fontSize: 14, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: report.topToolsUsed.map((tool) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00E676).withOpacity(0.2)),
            ),
            child: Text(tool, style: AppTypography.caption.copyWith(color: const Color(0xFF00E676))),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCommunityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9100).withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF9100).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFF9100).withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.people_rounded, color: Color(0xFFFF9100), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Community Activity', style: AppTypography.headingMedium.copyWith(fontSize: 16, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  '${report.communityPostsCreated} Posts created · ${report.communityComments} Comments shared',
                  style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryHighlightsCard() {
    return Column(
      children: report.diaryEntriesDetailed.take(3).map((entry) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry['date'] ?? 'This week',
                style: AppTypography.caption.copyWith(color: AppColors.textDisabled, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                '"${entry['snippet'] ?? ''}"',
                style: AppTypography.body.copyWith(fontSize: 14, color: AppColors.textPrimary, fontStyle: FontStyle.italic, height: 1.5),
              ),
              if (entry['mood'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Color(0xFF00D2FF)),
                    const SizedBox(width: 6),
                    Text(entry['mood']!, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ]
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAssessmentHistory() {
    return Column(
      children: report.assessmentHistory.map((assessment) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63).withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFE91E63).withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.assignment_rounded, color: Color(0xFFE91E63), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assessment['name'] ?? 'Clinical Assessment',
                      style: AppTypography.headingMedium.copyWith(fontSize: 16, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Score: ${assessment['score']} • ${assessment['severity'] ?? 'Completed'}',
                      style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTherapistData() {
    final sessions = report.therapistData['sessionsThisWeek'] ?? 0;
    final dataShared = report.therapistData['dataShared'] ?? false;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00BFA5).withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF00BFA5).withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.medical_services_rounded, color: Color(0xFF00BFA5), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Care Team Update', style: AppTypography.headingMedium.copyWith(fontSize: 16, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  '$sessions Sessions Completed',
                  style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.textMuted),
                ),
                if (dataShared) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF00BFA5), size: 14),
                      const SizedBox(width: 4),
                      Text('Weekly insights shared with therapist', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  RECOMMENDATIONS
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildRecommendationTile(int idx, String text) {
    final colors = [const Color(0xFF00D2FF), const Color(0xFF7C4DFF), const Color(0xFF00E676)];
    final color = colors[(idx - 1) % colors.length];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text('$idx', style: AppTypography.headingLarge.copyWith(fontSize: 14, color: color))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.textPrimary, height: 1.4))),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  COMPARISON CARD
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildComparisonCard() {
    final delta = report.weekDelta ?? 0;
    final isUp = delta > 0;
    final color = isUp ? const Color(0xFF00E676) : delta < 0 ? const Color(0xFFFF5252) : Colors.white54;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('vs Last Week', style: AppTypography.headingMedium.copyWith(fontSize: 14, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  report.aiComparison ?? '${isUp ? '+' : ''}${delta.toStringAsFixed(0)} wellness points',
                  style: AppTypography.body.copyWith(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  CONFIDENCE BADGE
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildConfidenceBadge() {
    final pct = report.dataCompleteness;
    final label = report.dataConfidence;
    final color = label == 'FULL' ? const Color(0xFF00E676) : label == 'LIMITED' ? const Color(0xFFFFAB00) : Colors.white38;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Text('Data Confidence: ${pct.toStringAsFixed(0)}%', style: AppTypography.caption.copyWith(fontSize: 12, color: AppColors.textMuted)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(label, style: AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  CRISIS STATUS
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildCrisisStatusCard() {
    Color color; IconData icon; String label;
    switch (report.crisisRiskLevel) {
      case 'HIGH': case 'SEVERE': case 'CRITICAL':
        color = const Color(0xFFFF5252); icon = Icons.warning_amber_rounded;
        label = 'Elevated risk detected. Consider speaking to a professional.';
        break;
      case 'MED':
        color = const Color(0xFFFFAB00); icon = Icons.info_outline_rounded;
        label = 'Moderate signals. Stay mindful of your routines this week.';
        break;
      default:
        color = const Color(0xFF00E676); icon = Icons.check_circle_outline_rounded;
        label = 'Stable. Keep up the great work!';
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wellness Status: ${report.crisisRiskLevel}', style: AppTypography.headingMedium.copyWith(fontSize: 13, color: color)),
                const SizedBox(height: 4),
                Text(label, style: AppTypography.body.copyWith(fontSize: 12, color: AppColors.textMuted, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  STARTER STATE
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildStarterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF5E4B8B).withOpacity(0.15), const Color(0xFF0F3460).withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF5E4B8B).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF00D2FF), size: 48),
          const SizedBox(height: 16),
          Text('Your Journey Begins', style: AppTypography.headingLarge.copyWith(fontSize: 22, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Text(
            report.aiSummary,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(fontSize: 14, color: AppColors.textMuted, height: 1.6),
          ),
          const SizedBox(height: 20),
          ...report.aiRecommendations.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: Color(0xFF00D2FF)),
                    const SizedBox(width: 10),
                    Text(r, style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.textPrimary)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: AppTypography.headingLarge.copyWith(fontSize: 18, color: AppColors.textPrimary));
  }
}
