import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/journal_provider.dart';
import 'package:go_router/go_router.dart';

class JournalHeroCard extends ConsumerWidget {
  const JournalHeroCard({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "What’s on your mind this morning?";
    if (hour < 17) return "Take a moment to reflect.";
    return "How are you feeling tonight?";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(journalAnalyticsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A202C), // Dark premium navy
            Color(0xFF2D3748),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _getGreeting(),
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
              const Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 28),
            ],
          ),
          const SizedBox(height: 16),
          analyticsAsync.when(
            data: (analytics) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem("Streak", "${analytics.currentStreak}d", Icons.bolt_rounded),
                _buildStatItem("Entries", "${analytics.totalEntries}", Icons.edit_note_rounded),
                _buildStatItem("Mind", analytics.mostCommonMood, Icons.psychology_rounded),
              ],
            ),
            loading: () => const LinearProgressIndicator(color: Colors.white24, backgroundColor: Colors.transparent),
            error: (_, __) => const Text("Insights unavailable", style: TextStyle(color: Colors.white60)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildCTAButton(
                "Start Writing",
                Icons.add_task_rounded,
                const Color(0xFF6366F1), // Indigo
                () => context.push('/journal/editor'),
              ),
              const SizedBox(width: 12),
              _buildCTAButton(
                "Voice",
                Icons.mic_rounded,
                Colors.white.withOpacity(0.1),
                () {},
                isOutline: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white60),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white60,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButton(String label, IconData icon, Color bg, VoidCallback onTap, {bool isOutline = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: isOutline ? Border.all(color: Colors.white24) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
