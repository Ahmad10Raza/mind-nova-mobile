import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/gratitude_provider.dart';

class GratitudeHeroCard extends ConsumerWidget {
  const GratitudeHeroCard({super.key});

  String _getDynamicGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "What are you looking forward to today?";
    if (hour < 17) return "What has been good about your day so far?";
    if (hour < 21) return "What made today meaningful?";
    return "Before you sleep, reflect on one good thing.";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(gratitudeAnalyticsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B2A20), // Dark warm peach
            Color(0xFF332030), // Dark warm pink
            Color(0xFF1B1F2C), // Standard dark surface
          ],
        ),
        border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header & Badge ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _getDynamicGreeting(),
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFDFE2F3),
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFFFB74D),
                  size: 28,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // ─── Stats Row (Riverpod Async) ─────────────────────────
          analyticsAsync.when(
            data: (analytics) => Row(
              children: [
                _buildStatItem('Streak', '${analytics.currentStreak} Days', Icons.local_fire_department_rounded, const Color(0xFFFFB74D)),
                const SizedBox(width: 24),
                _buildStatItem('Total', '${analytics.totalEntries} Logs', Icons.book_rounded, const Color(0xFFF687B3)),
              ],
            ),
            loading: () => const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFD700)),
            error: (_, __) => const Text('Could not load stats', style: TextStyle(color: Color(0xFFC9C4D8))),
          ),

          const SizedBox(height: 24),

          // ─── AI Insight Glass Pill ──────────────────────────────
          if (analyticsAsync.value?.moodLiftMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1F2C).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.2), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_graph_rounded, color: Color(0xFFFFD700), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      analyticsAsync.value!.moodLiftMessage,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFC9C4D8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: const Color(0xFFC9C4D8),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFDFE2F3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
