import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../providers/habit_provider.dart';

class HabitHistoryScreen extends ConsumerStatefulWidget {
  const HabitHistoryScreen({super.key});

  @override
  ConsumerState<HabitHistoryScreen> createState() => _HabitHistoryScreenState();
}

class _HabitHistoryScreenState extends ConsumerState<HabitHistoryScreen> {
  int _selectedDays = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161622),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'History & Analytics',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeFilter(),
            const SizedBox(height: 32),
            _buildAnalyticsSummary(),
            const SizedBox(height: 32),
            _buildHabitBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildFilterChip('7 Days', 7),
          _buildFilterChip('30 Days', 30),
          _buildFilterChip('90 Days', 90),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int days) {
    final isSelected = _selectedDays == days;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDays = days),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7C4DFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsSummary() {
    final analyticsAsync = ref.watch(habitAnalyticsProvider);

    return analyticsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
      error: (e, _) => Center(child: Text('Failed to load analytics: $e', style: const TextStyle(color: Colors.red))),
      data: (data) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Completions',
                data['totalCompletions'].toString(),
                Icons.check_circle_outline_rounded,
                const Color(0xFF00E676),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Best Streak',
                '${data['longestStreakOverall']} Days',
                Icons.local_fire_department_rounded,
                const Color(0xFFFF9100),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitBreakdown() {
    final historyAsync = ref.watch(habitHistoryProvider(_selectedDays));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Breakdown',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
          error: (e, _) => Center(child: Text('Failed to load history: $e', style: const TextStyle(color: Colors.red))),
          data: (habits) {
            if (habits.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No habits found for this period.',
                    style: GoogleFonts.inter(color: Colors.white54),
                  ),
                ),
              );
            }

            // Sort habits by completion count in the selected period (descending)
            final sortedHabits = List.of(habits);
            sortedHabits.sort((a, b) => b.logs.length.compareTo(a.logs.length));

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedHabits.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final habit = sortedHabits[index];
                final completionRate = habit.logs.length / _selectedDays;
                
                return _buildHabitHistoryCard(habit, completionRate);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildHabitHistoryCard(habit, double completionRate) {
    // Generate a miniature activity graph (last 7 days of the selected period)
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DateTime(date.year, date.month, date.day);
    });

    final logsSet = habit.logs.map((l) {
      final d = l.completedAt.toLocal();
      return DateTime(d.year, d.month, d.day).toIso8601String();
    }).toSet();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  habit.title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: completionRate > 0.7 
                    ? const Color(0xFF00E676).withValues(alpha: 0.2)
                    : const Color(0xFFFF9100).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${(completionRate * 100).toStringAsFixed(0)}% Rate',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: completionRate > 0.7 ? const Color(0xFF00E676) : const Color(0xFFFF9100),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat('Completions', '${habit.logs.length}'),
              const SizedBox(width: 24),
              _buildMiniStat('Current Streak', '${habit.streak?.currentStreak ?? 0}'),
            ],
          ),
          const SizedBox(height: 20),
          // Activity Graph
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: last7Days.map((day) {
              final isCompleted = logsSet.contains(day.toIso8601String());
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted 
                        ? const Color(0xFF7C4DFF) 
                        : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCompleted 
                          ? Colors.transparent 
                          : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: isCompleted 
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('E').format(day).substring(0, 1), // M, T, W...
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
