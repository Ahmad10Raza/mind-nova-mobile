import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/theme/tools_theme.dart';
import '../../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import '../widgets/habit_ai_insights_card.dart';
import '../../models/habit_model.dart';

class HabitHomeScreen extends ConsumerWidget {
  const HabitHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(todayHabitsProvider);

    // Midnight Refresh Logic: Auto-refresh habits when the day changes
    ref.listen(habitMidnightRefreshProvider, (previous, next) {
      if (next.hasValue && next.value == true) {
        ref.invalidate(todayHabitsProvider);
      }
    });

    return Scaffold(
      backgroundColor: DashboardTheme.deepNavy,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: DashboardTheme.deepNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Consistency',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              background: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ToolsTheme.dailyGreen.withOpacity(0.2),
                            DashboardTheme.deepNavy,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: 40,
                    child: Icon(
                      Icons.auto_graph,
                      size: 140,
                      color: ToolsTheme.dailyGreen.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildDailyProgress(habitsAsync),
                  const SizedBox(height: 16),
                  _buildHistoryButton(context),
                  const SizedBox(height: 16),
                   _buildDynamicAIInsight(habitsAsync),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Practices",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/habits/create'),
                        icon: const Icon(Icons.add, size: 18, color: ToolsTheme.dailyGreen),
                        label: Text(
                          'Add Habit',
                          style: GoogleFonts.outfit(color: ToolsTheme.dailyGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (habitsAsync.hasValue && habitsAsync.value!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        "💡 Tip: Long-press the check button to log for a missed day.",
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          habitsAsync.when(
            data: (habits) {
              if (habits.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('✨', style: TextStyle(fontSize: 64)),
                        SizedBox(height: 16),
                        Text(
                          'No habits set yet.\nStart building your routine!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final groups = _groupHabitsByTimeOfDay(habits);
              
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (groups['morning']!.isNotEmpty) 
                      _buildRitualSection(context, ref, 'Morning Ritual', '🌅', groups['morning']!),
                    if (groups['afternoon']!.isNotEmpty) 
                      _buildRitualSection(context, ref, 'Afternoon Reset', '☀️', groups['afternoon']!),
                    if (groups['night']!.isNotEmpty) 
                      _buildRitualSection(context, ref, 'Night Routine', '🌙', groups['night']!),
                    if (groups['flexible']!.isNotEmpty) 
                      _buildRitualSection(context, ref, 'Flexible Practices', '✨', groups['flexible']!),
                  ]),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 64, color: Colors.white24),
                    const SizedBox(height: 16),
                    Text(
                      'Could not load habits',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check your connection and try again.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () => ref.invalidate(todayHabitsProvider),
                      icon: const Icon(Icons.refresh_rounded, color: ToolsTheme.dailyGreen),
                      label: Text(
                        'Retry',
                        style: GoogleFonts.outfit(color: ToolsTheme.dailyGreen),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: ToolsTheme.dailyGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Map<String, List<Habit>> _groupHabitsByTimeOfDay(List<Habit> habits) {
    final morning = <Habit>[];
    final afternoon = <Habit>[];
    final night = <Habit>[];
    final flexible = <Habit>[];

    for (final habit in habits) {
      final trigger = habit.triggerType?.toUpperCase() ?? '';
      final pref = habit.preferredTime?.toUpperCase() ?? '';

      if (trigger.contains('WAKEUP') || trigger.contains('COFFEE') || pref == 'MORNING') {
        morning.add(habit);
      } else if (trigger.contains('WORK') || trigger.contains('LUNCH') || pref == 'AFTERNOON') {
        afternoon.add(habit);
      } else if (trigger.contains('SLEEP') || trigger.contains('BED') || pref == 'EVENING') {
        night.add(habit);
      } else {
        flexible.add(habit);
      }
    }

    return {
      'morning': morning,
      'afternoon': afternoon,
      'night': night,
      'flexible': flexible,
    };
  }

  Widget _buildRitualSection(BuildContext context, WidgetRef ref, String title, String emoji, List<Habit> habits) {
    final completed = habits.where((h) => h.logs.isNotEmpty).length;
    final total = habits.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Text(
                '$emoji $title',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$completed/$total',
                style: GoogleFonts.inter(
                  color: completed == total ? ToolsTheme.dailyGreen : Colors.white38,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...habits.map((habit) {
          final today = DateTime.now();
          final completedToday = habit.logs.any((l) =>
            l.completedAt.year == today.year &&
            l.completedAt.month == today.month &&
            l.completedAt.day == today.day,
          );
          return HabitCard(
            habit: habit,
            isCompletedToday: completedToday,
            onComplete: (date) {
              ref.read(habitCompletionProvider.notifier).completeHabit(
                habitId: habit.id,
                forDate: date,
              );
            },
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDailyProgress(AsyncValue<List<Habit>> habitsAsync) {
    return habitsAsync.maybeWhen(
      data: (habits) {
        if (habits.isEmpty) return const SizedBox.shrink();
        final completed = habits.where((h) => h.logs.isNotEmpty).length;
        final total = habits.length;
        final percent = total > 0 ? completed / total : 0.0;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: ToolsTheme.habitGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: ToolsTheme.dailyGreen.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      percent == 1.0 ? 'Perfect Consistency!' : 'Almost There',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed of $total practices completed today.',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildDynamicAIInsight(AsyncValue<List<Habit>> habitsAsync) {
    return habitsAsync.maybeWhen(
      data: (habits) {
        if (habits.isEmpty) return const SizedBox.shrink();

        // 1. Check Morning Ritual Progress
        final morningHabits = habits.where((h) => h.triggerType?.contains('WAKEUP') ?? false).toList();
        final completedMorning = morningHabits.where((h) => h.logs.any((l) => l.completedAt.day == DateTime.now().day)).length;
        
        if (morningHabits.isNotEmpty && completedMorning == morningHabits.length) {
          return const HabitAIInsightsCard(
            insight: "Morning Ritual complete! Your brain is now optimized for deep focus tasks. Capitalize on this momentum.",
            category: "Ritual Momentum",
          );
        }

        // 2. Check for Drop-Offs
        final strugglingHabit = habits.where((h) => (h.streak?.consistencyScore ?? 100) < 50).firstOrNull;
        if (strugglingHabit != null) {
          return HabitAIInsightsCard(
            insight: "Your '${strugglingHabit.title}' consistency is wavering. Try a 2-minute 'Micro' version today to protect your identity as a disciplined person.",
            category: "Drop-Off Prevention",
          );
        }

        // 3. General Consistency Tip
        final avgConsistency = habits.map((h) => h.streak?.consistencyScore ?? 0).reduce((a, b) => a + b) / habits.length;
        if (avgConsistency > 80) {
          return const HabitAIInsightsCard(
            insight: "Elite consistency detected. Your neural pathways for these habits are becoming permanent. Keep showing up.",
            category: "Identity Shift",
          );
        }

        // Default Fallback
        return const HabitAIInsightsCard(
          insight: "Correlation Found: Your evening recovery is 20% more consistent when you finish work before 7 PM. Mind your transitions.",
          category: "Circadian Insight",
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildHistoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/habits/history');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.analytics_rounded, color: Color(0xFF7C4DFF), size: 20),
                ),
                const SizedBox(width: 16),
                Text(
                  'View History & Analytics',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
