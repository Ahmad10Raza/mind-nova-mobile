import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'providers/meditation_provider.dart';
import '../domain/meditation_model.dart';

class MeditationHistoryScreen extends ConsumerStatefulWidget {
  const MeditationHistoryScreen({super.key});

  @override
  ConsumerState<MeditationHistoryScreen> createState() => _MeditationHistoryScreenState();
}

class _MeditationHistoryScreenState extends ConsumerState<MeditationHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  int _limit = 30;

  @override
  Widget build(BuildContext context) {
    final recentAsync = ref.watch(recentSessionsProvider);
    final statsAsync = ref.watch(meditationDashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Meditation History',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat("${statsAsync.asData?.value.totalSessions ?? 0}", "Sessions"),
                    _buildDivider(),
                    _buildStat("${statsAsync.asData?.value.totalMinutes ?? 0}m", "Total Time"),
                    _buildDivider(),
                    _buildStat("${statsAsync.asData?.value.averageCalmImprovement.toStringAsFixed(1) ?? '——'}%", "Avg Lift"),
                  ],
                ),
              ),
            ),
          ),
          recentAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))),
            error: (e, _) => const SliverFillRemaining(child: Center(child: Text('Failed to load history', style: TextStyle(color: Colors.white54)))),
            data: (sessions) {
              if (sessions.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("🌿", style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 16),
                        Text(
                          "No sessions yet",
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Start your first meditation session\nto build your history.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(color: Colors.white54, fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Group by date
              final grouped = <String, List<MeditationSession>>{};
              final now = DateTime.now();
              final todayStr = '${now.year}-${now.month}-${now.day}';
              final yesterday = now.subtract(const Duration(days: 1));
              final yesterdayStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';

              for (final session in sessions) {
                final dateStr = '${session.completedAt.year}-${session.completedAt.month}-${session.completedAt.day}';
                String label = dateStr;
                if (dateStr == todayStr) label = 'Today';
                else if (dateStr == yesterdayStr) label = 'Yesterday';
                else {
                  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                  label = '${months[session.completedAt.month - 1]} ${session.completedAt.day}';
                }
                grouped.putIfAbsent(label, () => []).add(session);
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final key = grouped.keys.elementAt(index);
                      final groupSessions = grouped[key]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHistoryGroupLabel(key),
                          const SizedBox(height: 8),
                          ...groupSessions.map((s) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildSessionCard(s))),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                    childCount: grouped.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  Widget _buildHistoryGroupLabel(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: GoogleFonts.inter(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSessionCard(MeditationSession session) {
    final mins = session.durationSecs ~/ 60;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
            ),
            child: const Icon(Icons.self_improvement_rounded, color: Color(0xFFD8B4FE), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.content?.title ?? "Unknown Track",
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.timer_rounded, color: Colors.white38, size: 12),
                    const SizedBox(width: 4),
                    Text('${mins}m', style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
                    const SizedBox(width: 12),
                    if (session.content != null) ...[
                      const Icon(Icons.category_rounded, color: Colors.white38, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        session.content!.category.replaceAll('_', ' '),
                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (session.calmAfter != null && session.calmBefore != null)
            Column(
              children: [
                Text(
                  "+${(session.calmAfter! - session.calmBefore!).clamp(0, 10).toInt()}",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF86EFAC),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text("lift", style: GoogleFonts.inter(color: Colors.white38, fontSize: 10)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
        Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 36, color: Colors.white.withOpacity(0.15));
  }
}
