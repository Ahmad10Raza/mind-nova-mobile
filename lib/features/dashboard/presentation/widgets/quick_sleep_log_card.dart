import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../sleep/providers/sleep_log_provider.dart';

/// A compact card on the dashboard that either shows a "Log Sleep" prompt
/// or a summary of today's logged sleep. Matches the white dashboard theme.
class QuickSleepLogCard extends ConsumerWidget {
  const QuickSleepLogCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todaySleepLogProvider);

    return todayAsync.when(
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox.shrink(),
      data: (todayLog) {
        if (todayLog != null) {
          return _buildLoggedCard(context, todayLog);
        }
        return _buildPromptCard(context, ref);
      },
    );
  }

  /// Card shown when the user HAS already logged sleep today — white theme.
  Widget _buildLoggedCard(BuildContext context, SleepLog log) {
    final qualityEmoji = log.quality >= 4
        ? '😴'
        : log.quality >= 3
            ? '🌙'
            : '😪';

    return GestureDetector(
      onTap: () => context.push('/sleep/tracking'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DashboardTheme.cardWhite,
          borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
          border: Border.all(
            color: const Color(0xFF5C6BC0).withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: DashboardTheme.softShadow(const Color(0xFF5C6BC0)),
        ),
        child: Row(
          children: [
            // Moon icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(qualityEmoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LAST NIGHT\'S SLEEP',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5C6BC0).withValues(alpha: 0.7),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${log.durationHours.toStringAsFixed(1)}h of sleep',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: DashboardTheme.textPrimary,
                    ),
                  ),
                  if (log.bedtime != null && log.wakeTime != null)
                    Text(
                      '${log.bedtime} → ${log.wakeTime}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: DashboardTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            // Quality stars
            Column(
              children: [
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < log.quality.round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 16,
                      color: i < log.quality.round()
                          ? const Color(0xFFFFB300)
                          : const Color(0xFF5C6BC0).withValues(alpha: 0.2),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to edit',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: DashboardTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Card shown when the user has NOT logged sleep — white theme prompt.
  Widget _buildPromptCard(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showQuickSleepSheet(context, ref),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DashboardTheme.cardWhite,
          borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
          border: Border.all(
            color: const Color(0xFF5C6BC0).withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: DashboardTheme.softShadow(const Color(0xFF5C6BC0)),
        ),
        child: Row(
          children: [
            // Moon icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5C6BC0), Color(0xFF7C4DFF)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(Icons.nights_stay_rounded, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How did you sleep?',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: DashboardTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Log last night\'s sleep',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: DashboardTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5C6BC0), Color(0xFF7C4DFF)],
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Log',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet for quick sleep entry — keeps the dark night-sky aesthetic.
  void _showQuickSleepSheet(BuildContext context, WidgetRef ref) {
    TimeOfDay bedtime = const TimeOfDay(hour: 23, minute: 0);
    TimeOfDay wakeTime = const TimeOfDay(hour: 7, minute: 0);
    double quality = 3;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final bedMinutes = bedtime.hour * 60 + bedtime.minute;
            final wakeMinutes = wakeTime.hour * 60 + wakeTime.minute;
            var diffMin = wakeMinutes - bedMinutes;
            if (diffMin < 0) diffMin += 24 * 60;
            final durationHours = diffMin / 60.0;

            // Label for date
            final now = DateTime.now();
            final isToday = selectedDate.year == now.year &&
                selectedDate.month == now.month &&
                selectedDate.day == now.day;
            final yesterday = now.subtract(const Duration(days: 1));
            final isYesterday = selectedDate.year == yesterday.year &&
                selectedDate.month == yesterday.month &&
                selectedDate.day == yesterday.day;
            final dateLabel = isToday
                ? 'Today'
                : isYesterday
                    ? 'Yesterday'
                    : '${selectedDate.day}/${selectedDate.month}';

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1A2E), Color(0xFF0F0F23)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title row with date picker
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🌙 Log Sleep',
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'When did you go to bed and wake up?',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Date selector chip
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate,
                            firstDate: now.subtract(const Duration(days: 7)),
                            lastDate: now,
                            builder: (ctx2, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Color(0xFF7C4DFF),
                                    surface: Color(0xFF1A1A2E),
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setSheetState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5C6BC0).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFF5C6BC0).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF9FA8DA)),
                              const SizedBox(width: 6),
                              Text(
                                dateLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF9FA8DA),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Time pickers row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeTile(ctx, 'Bedtime', bedtime, (t) {
                          setSheetState(() => bedtime = t);
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimeTile(ctx, 'Wake Up', wakeTime, (t) {
                          setSheetState(() => wakeTime = t);
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Duration display
                  Center(
                    child: Text(
                      '${durationHours.toStringAsFixed(1)}h of sleep',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5C6BC0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quality
                  Text(
                    'Sleep Quality',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final starVal = (i + 1).toDouble();
                      return GestureDetector(
                        onTap: () => setSheetState(() => quality = starVal),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            starVal <= quality
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 36,
                            color: starVal <= quality
                                ? const Color(0xFFFFD54F)
                                : Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  GestureDetector(
                    onTap: () async {
                      await ref.read(sleepLogProvider.notifier).addLog(
                        durationHours: durationHours,
                        quality: quality,
                        bedtime: '${bedtime.hour.toString().padLeft(2, '0')}:${bedtime.minute.toString().padLeft(2, '0')}',
                        wakeTime: '${wakeTime.hour.toString().padLeft(2, '0')}:${wakeTime.minute.toString().padLeft(2, '0')}',
                        forDate: selectedDate,
                      );
                      ref.invalidate(todaySleepLogProvider);
                      ref.invalidate(sleepAverageProvider);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5C6BC0), Color(0xFF7C4DFF)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Save Sleep Log',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Link to full tracker
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        GoRouter.of(context).push('/sleep/tracking');
                      },
                      child: Text(
                        'Open Full Sleep Tracker →',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9FA8DA),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimeTile(
    BuildContext context,
    String label,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (ctx, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF5C6BC0),
                  surface: Color(0xFF1A1A2E),
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
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF9FA8DA).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
