import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/sleep_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/sleep_colors.dart';
import '../../providers/sleep_log_provider.dart';

/// Weekly sleep bar chart widget with quality color coding.
class SleepChartCard extends ConsumerWidget {
  const SleepChartCard({super.key});

  Color _qualityColor(double quality) {
    if (quality >= 0.8) return SleepColors.successGreen;
    if (quality >= 0.6) return SleepColors.moonGold;
    if (quality >= 0.4) return Colors.orange;
    return SleepColors.emergencyRed;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(sleepLogProvider);
    
    return logsAsync.when(
      loading: () => const SizedBox(height: 200),
      error: (_, __) => const SizedBox.shrink(),
      data: (logs) => _buildChart(context, logs),
    );
  }

  Widget _buildChart(BuildContext context, List<SleepLog> logs) {
    // Map logs to week format
    final List<Map<String, dynamic>> weekData = [];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // Fill with empty data
    for (int i=0; i<7; i++) {
      weekData.add({'day': days[i], 'hours': 0.0, 'quality': 0.0});
    }

    // Overlay real data over the last N days 
    for(int i=0; i<logs.length; i++) {
        final log = logs[i];
        final dayStr = days[log.date.weekday - 1]; // 1=Mon, 7=Sun
        final idx = weekData.indexWhere((e) => e['day'] == dayStr);
        if (idx != -1) {
            weekData[idx] = {
                'day': dayStr,
                'hours': log.durationHours,
                'quality': log.quality / 5.0, // map back to 0-1 range
            };
        }
    }

    // Calc average
    double totalHours = logs.fold(0.0, (sum, log) => sum + log.durationHours);
    double avgHours = logs.isNotEmpty ? totalHours / logs.length : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(SleepColors.cardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: SleepColors.glassBlurSigma,
          sigmaY: SleepColors.glassBlurSigma,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: SleepColors.glassCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart_rounded, color: SleepColors.softBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Weekly Sleep',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: SleepColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Avg: ${avgHours.toStringAsFixed(1)}h',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: SleepColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Bar Chart ──────────────────────────────
              SizedBox(
                height: 160,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: weekData.map((data) {
                    final hours = (data['hours'] as double);
                    final quality = (data['quality'] as double);
                    final barHeight = (hours / 10.0) * 140; // Max 10h
                    final isToday = data['day'] == _getCurrentDay();

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Hours label
                          Text(
                            '${hours.toStringAsFixed(1)}h',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isToday ? SleepColors.textPrimary : SleepColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Bar
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            height: barHeight,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: _qualityColor(quality),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isToday
                                  ? [
                                      BoxShadow(
                                        color: _qualityColor(quality).withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Day label
                          Text(
                            data['day'],
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                              color: isToday ? SleepColors.textPrimary : SleepColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // ─── Legend ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegend('Good', SleepColors.successGreen),
                  const SizedBox(width: 16),
                  _buildLegend('Fair', SleepColors.moonGold),
                  const SizedBox(width: 16),
                  _buildLegend('Poor', SleepColors.emergencyRed),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: SleepColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getCurrentDay() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[DateTime.now().weekday - 1];
  }
}
