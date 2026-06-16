import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/tools_theme.dart';
import '../../models/habit_model.dart';
import '../../data/habit_identity_messages.dart';
import 'dart:math';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final Function(DateTime?) onComplete;
  final bool isCompletedToday;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onComplete,
    required this.isCompletedToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompletedToday
              ? ToolsTheme.dailyGreen.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildCategoryIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: isCompletedToday ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      '${habit.duration} min • ${habit.triggerType?.replaceAll('_', ' ') ?? 'Flexible'}',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildCompleteButton(context),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Streak', '${habit.streak?.currentStreak ?? 0} days', Icons.fireplace, Colors.orange),
              _buildStat(
                'Consistency', 
                '${(habit.streak?.consistencyScore ?? 0).toInt()}%', 
                Icons.auto_graph, 
                (habit.streak?.consistencyScore ?? 0) < 40 ? Colors.red : Colors.blue,
                showWarning: (habit.streak?.consistencyScore ?? 0) < 40,
              ),
            ],
          ),
          if (habit.recoveryState?.recoveryPlanActive == true)
            _buildRecoveryPrompt(context),
          if (!isCompletedToday && (habit.streak?.currentStreak ?? 0) > 0)
            _buildFailureAnalysisButton(context),
        ],
      ),
    );
  }

  Widget _buildFailureAnalysisButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: InkWell(
        onTap: () => _showFailureAnalysis(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: ToolsTheme.aiPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ToolsTheme.aiPurple.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: ToolsTheme.aiPurple, size: 14),
              const SizedBox(width: 8),
              Text(
                "Why did I miss this?",
                style: GoogleFonts.inter(color: ToolsTheme.aiPurple, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFailureAnalysis(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)), margin: const EdgeInsets.only(bottom: 24)),
            Text('Behavioral Analysis', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Text(
              "MindNova AI analyzed your last 48 hours. You missed '${habit.title}' because your stress levels spiked by 30% after work. This suggests your current 'After Work' trigger is too high-friction on difficult days.",
              style: GoogleFonts.inter(color: Colors.white70, height: 1.6),
            ),
            const SizedBox(height: 24),
            Text('Smart Suggestion', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: ToolsTheme.aiPurple)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: ToolsTheme.aiPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Text(
                "Try moving this habit to 'After Morning Coffee' for 3 days to bypass end-of-day fatigue.",
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryPrompt(BuildContext context) {
    return InkWell(
      onTap: () => _showSoftStartDialog(context),
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.amber, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "It's been a few days. Want a 'Soft Start' today? (Reduced to 2 mins)",
                style: GoogleFonts.outfit(color: Colors.amber, fontSize: 12),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 12),
          ],
        ),
      ),
    );
  }

  void _showSoftStartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Recovery Mode', style: GoogleFonts.outfit(color: Colors.white)),
        content: Text(
          "Consistency is better than intensity. Let's do a 2-minute 'Micro' version of ${habit.title} to get back in the flow.",
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Maybe later', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onComplete(null); // Passing null for current day
            },
            child: const Text('Start Soft', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon() {
    IconData icon;
    Color color;
    switch (habit.category) {
      case 'MIND': icon = Icons.psychology; color = ToolsTheme.dailyGreen; break;
      case 'BODY': icon = Icons.fitness_center; color = ToolsTheme.mindfulBlue; break;
      case 'FOCUS': icon = Icons.center_focus_strong; color = ToolsTheme.aiPurple; break;
      case 'RECOVERY': icon = Icons.battery_charging_full; color = ToolsTheme.assessAmber; break;
      default: icon = Icons.star; color = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color, {bool showWarning = false}) {
    return Row(
      children: [
        Icon(icon, color: color.withOpacity(0.7), size: 16),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 12),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        if (showWarning) ...[
          const SizedBox(width: 4),
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 14),
        ],
      ],
    );
  }

  Widget _buildCompleteButton(BuildContext context) {
    return InkWell(
      onLongPress: isCompletedToday ? null : () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 1)),
          firstDate: DateTime.now().subtract(const Duration(days: 7)),
          lastDate: DateTime.now().subtract(const Duration(days: 1)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: ToolsTheme.dailyGreen,
                  onPrimary: Colors.white,
                  surface: Color(0xFF1A1A2E),
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onComplete(picked);
        }
      },
      onTap: isCompletedToday ? null : () {
        HapticFeedback.heavyImpact();
        onComplete(null);
        
        // Show identity reinforcement
        final randomMessage = habitIdentityMessages[Random().nextInt(habitIdentityMessages.length)];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    randomMessage,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: ToolsTheme.dailyGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompletedToday
              ? ToolsTheme.dailyGreen
              : Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isCompletedToday ? Icons.check : Icons.radio_button_unchecked,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
