import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/sleep_colors.dart';
import 'widgets/night_sky_background.dart';
import 'widgets/sleep_chart_card.dart';
import 'widgets/sleep_debt_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sleep_log_provider.dart';

/// Full sleep tracking dashboard with log entry and analytics.
class SleepTrackingScreen extends ConsumerStatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  ConsumerState<SleepTrackingScreen> createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends ConsumerState<SleepTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  // Form state
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  double _quality = 3;
  double _awakenings = 1;
  double _stressBefore = 3;
  double _morningMood = 7;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  double get _sleepDuration {
    final bedMinutes = _bedtime.hour * 60 + _bedtime.minute;
    final wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    var diff = wakeMinutes - bedMinutes;
    if (diff < 0) diff += 24 * 60; // Handle overnight
    return diff / 60.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SleepColors.midnightBlack,
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          return NightSkyBackground(
            animationValue: _bgController.value,
            showMoon: false,
            child: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ─── App Bar ─────────────────────────────
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    floating: true,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: SleepColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      'Sleep Tracking',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: SleepColors.textPrimary,
                      ),
                    ),
                  ),

                  // ─── Weekly Chart ────────────────────────
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(child: SleepChartCard()),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // ─── Sleep Debt ──────────────────────────
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(child: SleepDebtCard()),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // ─── Log Entry Header ────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Log Last Night\'s Sleep',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: SleepColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // ─── Time Pickers ────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(child: _buildTimePicker('Bedtime', _bedtime, (t) => setState(() => _bedtime = t))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTimePicker('Wake Up', _wakeTime, (t) => setState(() => _wakeTime = t))),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // ─── Duration Display ────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: SleepColors.glassCard,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.schedule_rounded, color: SleepColors.softBlue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Duration: ${_sleepDuration.toStringAsFixed(1)}h',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: SleepColors.softBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // ─── Quality Slider ──────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _buildSlider('Sleep Quality', _quality, 1, 5, (v) => setState(() => _quality = v),
                        labels: ['Poor', '', 'Fair', '', 'Great']),
                    ),
                  ),

                  // ─── Night Awakenings ────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _buildSlider('Night Awakenings', _awakenings, 0, 5, (v) => setState(() => _awakenings = v)),
                    ),
                  ),

                  // ─── Stress Before Bed ───────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _buildSlider('Stress Before Bed', _stressBefore, 1, 10, (v) => setState(() => _stressBefore = v)),
                    ),
                  ),

                  // ─── Morning Mood ────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _buildSlider('Morning Mood', _morningMood, 1, 10, (v) => setState(() => _morningMood = v)),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // ─── Save Button ─────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: GestureDetector(
                        onTap: _saveSleepLog,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: SleepColors.ctaGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C4DFF).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Save Sleep Log',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: SleepColors.lavenderGlow,
                  surface: SleepColors.cardSurface,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: SleepColors.glassCard,
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, color: SleepColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              time.format(context),
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: SleepColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged,
      {List<String>? labels}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: SleepColors.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SleepColors.textPrimary,
                ),
              ),
              Text(
                value.toInt().toString(),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: SleepColors.lavenderGlow,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: SleepColors.lavenderGlow,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: SleepColors.lavenderGlow,
              overlayColor: SleepColors.lavenderGlow.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _saveSleepLog() async {
    await ref.read(sleepLogProvider.notifier).addLog(
      durationHours: _sleepDuration,
      quality: _quality,
      bedtime: '${_bedtime.hour.toString().padLeft(2, '0')}:${_bedtime.minute.toString().padLeft(2, '0')}',
      wakeTime: '${_wakeTime.hour.toString().padLeft(2, '0')}:${_wakeTime.minute.toString().padLeft(2, '0')}',
      awakenings: _awakenings.toInt(),
      stressBefore: _stressBefore,
      morningMood: _morningMood,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🌙 Sleep log saved! Duration: ${_sleepDuration.toStringAsFixed(1)}h',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: SleepColors.darkPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }
}
