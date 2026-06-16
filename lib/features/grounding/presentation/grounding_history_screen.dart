import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/grounding_model.dart';
import '../providers/grounding_provider.dart';

class GroundingHistoryScreen extends ConsumerStatefulWidget {
  const GroundingHistoryScreen({super.key});

  @override
  ConsumerState<GroundingHistoryScreen> createState() => _GroundingHistoryScreenState();
}

class _GroundingHistoryScreenState extends ConsumerState<GroundingHistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(groundingHistoryProvider.notifier).fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(groundingHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0F1E),
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: Text(
              "Grounding History",
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),

          // Stats bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D6B6B), Color(0xFF0F2444)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat("${historyState.sessions.length}", "Sessions"),
                    _buildDivider(),
                    _buildStat(
                      historyState.sessions.isEmpty ? "0m" :
                        "${historyState.sessions.fold(0, (a, b) => a + b.durationSecs) ~/ 60}m",
                      "Total Time",
                    ),
                    _buildDivider(),
                    _buildStat(
                      historyState.sessions.isEmpty ? "—" :
                        "${(historyState.sessions.where((s) => s.calmAfter != null).fold(0, (a, b) => a + (b.calmAfter ?? 0)) / (historyState.sessions.where((s) => s.calmAfter != null).length.clamp(1, 999))).toStringAsFixed(1)}/10",
                      "Avg Calm",
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sessions list
          if (historyState.isLoading && historyState.sessions.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFF0D9488))),
            )
          else if (historyState.sessions.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("🌱", style: const TextStyle(fontSize: 56)),
                    const SizedBox(height: 16),
                    Text(
                      "No sessions yet",
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Start your first grounding exercise\nto build your history.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => context.push('/grounding/sensory'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text("Start 5-4-3-2-1", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == historyState.sessions.length) {
                      return historyState.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator(color: Color(0xFF0D9488))),
                            )
                          : const SizedBox.shrink();
                    }
                    return _buildSessionCard(historyState.sessions[index]);
                  },
                  childCount: historyState.sessions.length + 1,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSessionCard(GroundingSession session) {
    final typeColors = {
      GroundingExerciseType.sensory54321: const Color(0xFF0D9488),
      GroundingExerciseType.panicReset: const Color(0xFF7C3AED),
      GroundingExerciseType.touchHold: const Color(0xFF0369A1),
      GroundingExerciseType.bodyScan: const Color(0xFF059669),
      GroundingExerciseType.colorBreathing: const Color(0xFF0369A1),
      GroundingExerciseType.safePlace: const Color(0xFF065F46),
    };

    final color = typeColors[session.exerciseType] ?? const Color(0xFF0D9488);
    final mins = session.durationSecs ~/ 60;
    final secs = session.durationSecs % 60;
    final duration = mins > 0 ? '${mins}m ${secs}s' : '${secs}s';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(Icons.self_improvement_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.exerciseType.label,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.timer_rounded, color: Colors.white38, size: 12),
                    const SizedBox(width: 4),
                    Text(duration, style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
                    const SizedBox(width: 12),
                    Icon(Icons.calendar_today_rounded, color: Colors.white38, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(session.completedAt),
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (session.calmAfter != null)
            Column(
              children: [
                Text(
                  "${session.calmAfter}",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF5EEAD4),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text("/10", style: GoogleFonts.inter(color: Colors.white38, fontSize: 10)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 36, color: Colors.white.withOpacity(0.15));
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt).inDays;
    if (diff == 0) return "Today";
    if (diff == 1) return "Yesterday";
    return "${dt.day}/${dt.month}";
  }
}
