import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/theme/tools_theme.dart';
import '../../providers/habit_provider.dart';

class HabitHomeSummaryCard extends ConsumerWidget {
  const HabitHomeSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(todayHabitsProvider);

    return habitsAsync.maybeWhen(
      data: (habits) {
        if (habits.isEmpty) {
          return InkWell(
            onTap: () => context.push('/habits'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
                border: Border.all(color: DashboardTheme.primaryPurple.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: DashboardTheme.primaryPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_task, color: DashboardTheme.primaryPurple),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start your first habit',
                          style: GoogleFonts.outfit(
                            color: DashboardTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Build consistency, one step at a time.',
                          style: GoogleFonts.outfit(
                            color: DashboardTheme.textTertiary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: DashboardTheme.textTertiary),
                ],
              ),
            ),
          );
        }

        final completed = habits.where((h) => h.logs.isNotEmpty).length;
        final total = habits.length;
        final percent = total > 0 ? completed / total : 0.0;
        final topStreak = habits.isNotEmpty 
          ? habits.map((h) => h.streak?.currentStreak ?? 0).reduce((a, b) => a > b ? a : b)
          : 0;

        return InkWell(
          onTap: () => context.push('/habits'),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        value: percent,
                        strokeWidth: 4,
                        backgroundColor: ToolsTheme.dailyGreen.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation(ToolsTheme.dailyGreen),
                      ),
                    ),
                    Text(
                      '${(percent * 100).toInt()}%',
                      style: GoogleFonts.outfit(
                        color: DashboardTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Consistency',
                        style: GoogleFonts.outfit(
                          color: DashboardTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$completed of $total habits done • $topStreak day streak',
                        style: GoogleFonts.outfit(
                          color: DashboardTheme.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: DashboardTheme.textTertiary),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
