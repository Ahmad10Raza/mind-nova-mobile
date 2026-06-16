import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../mood/models/mood_model.dart';

class MoodTrendChart extends StatelessWidget {
  final List<MoodTrend> trends;
  final int days;
  final bool showLabels;

  const MoodTrendChart({
    super.key,
    required this.trends,
    this.days = 7,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return _buildEmptyState();
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < trends.length; i++) {
      spots.add(FlSpot(i.toDouble(), trends[i].score));
    }

    // Find best/worst days
    int bestIdx = 0, worstIdx = 0;
    for (int i = 1; i < trends.length; i++) {
      if (trends[i].score > trends[bestIdx].score) bestIdx = i;
      if (trends[i].score < trends[worstIdx].score) worstIdx = i;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DashboardTheme.cardWhite,
        borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
        boxShadow: DashboardTheme.softShadow(DashboardTheme.primaryPurple),
      ),
      child: Stack(
        children: [
          // Background watermark doodle
          Positioned(
            right: 20,
            top: 60,
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/illustrations/Roller_Of_Mix_Emotion.png',
                height: 140,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Text('Your Mood Flow', style: DashboardTheme.heading2),
                    const Spacer(),
                    // Weekly badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: DashboardTheme.primaryPurple.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$days Days',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: DashboardTheme.primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Best/Worst day badges
              if (trends.length >= 3)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    children: [
                      _buildDayBadge(
                        '😁 Best: ${DateFormat('EEE').format(trends[bestIdx].date)}',
                        DashboardTheme.moodGreen,
                      ),
                      const SizedBox(width: 8),
                      _buildDayBadge(
                        '😔 Low: ${DateFormat('EEE').format(trends[worstIdx].date)}',
                        DashboardTheme.stressAmber,
                      ),
                    ],
                  ),
                ),

              // Chart
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 26, 8), // Increased right padding from 20 to 26
                child: SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      minY: 1,
                      maxY: 5,
                      minX: 0,
                      maxX: math.max(1.0, (trends.length - 1).toDouble()), // Ensure at least 1.0 range to avoid fl_chart crash
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: const Color(0xFFE5E5EA),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= trends.length) return const SizedBox.shrink();
                              if (trends.length > 10 && index % (trends.length / 5).ceil() != 0 && index != trends.length - 1) {
                                return const SizedBox.shrink();
                              }
                              return SideTitleWidget(
                                meta: meta,
                                space: 8,
                                child: Text(
                                  DateFormat('E').format(trends[index].date),
                                  style: GoogleFonts.inter(
                                    color: DashboardTheme.textTertiary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              const emojis = {1: '😔', 2: '😟', 3: '😐', 4: '🙂', 5: '😁'};
                              final emoji = emojis[value.toInt()];
                              if (emoji == null) return const SizedBox.shrink();
                              return SideTitleWidget(
                                meta: meta,
                                space: 6,
                                child: Text(emoji, style: const TextStyle(fontSize: 13)),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: DashboardTheme.primaryPurple,
                          barWidth: 3.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4.5,
                                color: Colors.white,
                                strokeWidth: 2.5,
                                strokeColor: DashboardTheme.primaryPurple,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                DashboardTheme.primaryPurple.withValues(alpha: 0.25),
                                DashboardTheme.primaryPurple.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((touchedSpot) {
                              return LineTooltipItem(
                                '${touchedSpot.y.toStringAsFixed(1)} ⭐',
                                GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Emotional heatmap strip
              // Container needs to be constrained so that flex expansion doesn't clip on the right
              Container(
                margin: const EdgeInsets.fromLTRB(20, 4, 34, 16), // Increased right margin from 20 to 34 to avoid edge clipping
                child: Row(
                  children: List.generate(trends.length.clamp(0, 7), (i) {
                    final score = trends[i].score;
                    return Expanded(
                      child: Container(
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: _scoreColor(score),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 4.5) return DashboardTheme.moodGreen;
    if (score >= 3.5) return const Color(0xFF8BC34A);
    if (score >= 2.5) return DashboardTheme.energyYellow;
    if (score >= 1.5) return DashboardTheme.stressAmber;
    return DashboardTheme.crisisRed;
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: DashboardTheme.cardWhite,
        borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
        boxShadow: DashboardTheme.softShadow(Colors.black),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.3,
            child: Image.asset(
              'assets/illustrations/Roller_Of_Mix_Emotion.png',
              height: 60,
              errorBuilder: (_, __, ___) => const Icon(Icons.show_chart_rounded, size: 40, color: DashboardTheme.textTertiary),
            ),
          ),
          const SizedBox(height: 12),
          Text('Log your mood to see trends!', style: DashboardTheme.bodyRegular),
          const SizedBox(height: 4),
          Text('Your weekly mood flow will appear here.', style: DashboardTheme.bodySmall),
        ],
      ),
    );
  }
}
