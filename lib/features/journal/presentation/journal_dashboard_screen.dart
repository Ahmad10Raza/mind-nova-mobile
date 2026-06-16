import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';
import '../models/journal_model.dart';
import 'journal_editor_screen.dart';

class JournalDashboardScreen extends ConsumerStatefulWidget {
  const JournalDashboardScreen({super.key});
  @override
  ConsumerState<JournalDashboardScreen> createState() => _JournalDashboardScreenState();
}

class _JournalDashboardScreenState extends ConsumerState<JournalDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  static const _bg = Color(0xFF0F131F);
  static const _surface = Color(0xFF1B1F2C);
  static const _primary = Color(0xFFCABEFF);
  static const _secondary = Color(0xFF44E2CD);
  static const _onSurface = Color(0xFFDFE2F3);
  static const _onSurfaceVariant = Color(0xFFC9C4D8);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(journalAnalyticsProvider);
    final historyState = ref.watch(journalHistoryProvider);
    final memoryAsync = ref.watch(journalMemoryResurfaceProvider);
    final promptAsync = ref.watch(journalDailyPromptProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Atmospheric background glows
          Positioned(top: -60, left: -60, child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [_primary.withValues(alpha: 0.15), Colors.transparent]),
            ),
          )),
          Positioned(bottom: 100, right: -80, child: Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [_secondary.withValues(alpha: 0.1), Colors.transparent]),
            ),
          )),
          // Main content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, analyticsAsync),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                sliver: SliverList(delegate: SliverChildListDelegate([
                  _buildNovaHero(context, analyticsAsync),
                  const SizedBox(height: 24),
                  _buildGuidedPrompt(promptAsync),
                  const SizedBox(height: 24),
                  _buildReflectionSpaces(context),
                  const SizedBox(height: 24),
                  _buildPatternDiscovery(analyticsAsync),
                  const SizedBox(height: 24),
                  _buildMemoryVault(memoryAsync),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Recent Entries'),
                  const SizedBox(height: 12),
                  if (historyState.isLoading && historyState.entries.isEmpty)
                    const Center(child: CircularProgressIndicator(color: _primary))
                  else if (historyState.entries.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...historyState.entries.take(5).map((e) => _buildEntryCard(context, e)),
                ])),
              ),
            ],
          ),
          // FAB
          Positioned(
            right: 20, bottom: 90,
            child: GestureDetector(
              onTap: () => context.push('/journal/editor'),
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [_primary, Color(0xFF937DFF)],
                  ),
                  boxShadow: [BoxShadow(color: _primary.withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 2)],
                ),
                child: const Icon(Icons.add_rounded, color: Color(0xFF1C0062), size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AsyncValue<JournalAnalytics> analyticsAsync) {
    return SliverAppBar(
      backgroundColor: _bg.withValues(alpha: 0.8),
      elevation: 0,
      pinned: true,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        title: Text('Reflection Sanctuary',
          style: GoogleFonts.manrope(color: _onSurface, fontWeight: FontWeight.w700, fontSize: 20)),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: _onSurfaceVariant),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.tune_rounded, color: _onSurfaceVariant),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNovaHero(BuildContext context, AsyncValue<JournalAnalytics> analyticsAsync) {
    return analyticsAsync.when(
      loading: () => _glassCard(child: const SizedBox(height: 160, child: Center(child: CircularProgressIndicator(color: _primary)))),
      error: (_, __) => const SizedBox(),
      data: (analytics) => _glassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ScaleTransition(
              scale: _pulse,
              child: const Icon(Icons.auto_awesome, color: _primary, size: 20),
            ),
            const SizedBox(width: 8),
            Text('NOVA INSIGHT', style: GoogleFonts.inter(color: _primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            const Spacer(),
            Text('Just now', style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 11)),
          ]),
          const SizedBox(height: 16),
          RichText(text: TextSpan(
            style: GoogleFonts.manrope(color: _onSurface, fontSize: 18, fontWeight: FontWeight.w700, height: 1.35),
            children: [
              const TextSpan(text: '"Nova noticed your thoughts have been '),
              TextSpan(text: analytics.mostCommonMood.toLowerCase(), style: const TextStyle(color: _primary, fontStyle: FontStyle.italic)),
              const TextSpan(text: ' lately."'),
            ],
          )),
          const SizedBox(height: 8),
          Row(children: [
            _statChip(Icons.bolt_rounded, '${analytics.currentStreak}d', 'Streak'),
            const SizedBox(width: 16),
            _statChip(Icons.edit_note_rounded, '${analytics.totalEntries}', 'Entries'),
            const SizedBox(width: 16),
            _statChip(Icons.mood_rounded, analytics.mostCommonMood, 'Mind'),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => context.push('/journal/editor'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [_primary, Color(0xFF937DFF)]),
                  boxShadow: [BoxShadow(color: _primary.withValues(alpha: 0.3), blurRadius: 16)],
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.edit_rounded, color: Color(0xFF1C0062), size: 18),
                  const SizedBox(width: 8),
                  Text('Start Writing', style: GoogleFonts.inter(color: const Color(0xFF1C0062), fontWeight: FontWeight.w700)),
                ]),
              ),
            )),
            const SizedBox(width: 12),
            _glassIconBtn(Icons.mic_rounded, onTap: () {}),
          ]),
        ]),
      ),
    );
  }

  Widget _buildGuidedPrompt(AsyncValue<Map<String, dynamic>> promptAsync) {
    return promptAsync.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (prompt) {
        final text = prompt['prompt'] as String? ?? 'What is one thing you appreciate about yourself today?';
        final context_ = prompt['context'] as String? ?? '';
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionLabel('Guided Prompt'),
          const SizedBox(height: 12),
          _glassCard(
            leftAccent: _secondary,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _secondary.withValues(alpha: 0.1),
                ),
                child: const Icon(Icons.psychology_rounded, color: _secondary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('"$text"', style: GoogleFonts.inter(color: _onSurface, fontSize: 15, height: 1.55)),
                const SizedBox(height: 6),
                Text(context_, style: GoogleFonts.inter(color: _secondary.withValues(alpha: 0.7), fontSize: 12, fontStyle: FontStyle.italic)),
              ])),
            ]),
          ),
        ]);
      },
    );
  }

  Widget _buildReflectionSpaces(BuildContext context) {
    final modes = [
      _ModeData('Gratitude Garden', 'Find the joy', Icons.local_florist_rounded, _secondary, 'GRATITUDE', 'assets/images/journal/gratitude_garden.png'),
      _ModeData('Thought Release', 'Let it all out', Icons.cloud_off_rounded, _primary, 'ANXIETY_DUMP', 'assets/images/journal/thought_release.png'),
      _ModeData('Overthinking Reset', "Break the loop with Nova's logic guide", Icons.refresh_rounded, const Color(0xFFFFB4AB), 'FREE_WRITE', null),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _sectionLabel('Reflection Spaces')),
        GestureDetector(
          onTap: () => context.push('/journal/history'),
          child: Row(children: [
            Text('See All', style: GoogleFonts.inter(color: _primary, fontSize: 12)),
            const Icon(Icons.arrow_forward_rounded, color: _primary, size: 14),
          ]),
        ),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _buildModeCard(context, modes[0], tall: true)),
        const SizedBox(width: 12),
        Expanded(child: _buildModeCard(context, modes[1], tall: true)),
      ]),
      const SizedBox(height: 12),
      _buildModeCard(context, modes[2], wide: true),
    ]);
  }

  Widget _buildModeCard(BuildContext context, _ModeData mode, {bool tall = false, bool wide = false}) {
    return GestureDetector(
      onTap: () => context.push('/journal/editor', extra: JournalEntry(
        id: '', userId: '', content: '', journalType: mode.type,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      )),
      child: Container(
        height: tall ? 140 : null,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: _surface.withValues(alpha: 0.5),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          image: mode.imagePath != null ? DecorationImage(
            image: AssetImage(mode.imagePath!), fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.55), BlendMode.darken),
          ) : null,
        ),
        child: wide
            ? Row(children: [
                _modeIcon(mode),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(mode.title, style: GoogleFonts.inter(color: _onSurface, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(mode.subtitle, style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 11)),
                ])),
                Icon(Icons.chevron_right_rounded, color: _onSurfaceVariant.withValues(alpha: 0.4)),
              ])
            : Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _modeIcon(mode),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(mode.title, style: GoogleFonts.inter(color: _onSurface, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(mode.subtitle, style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 11)),
                ]),
              ]),
      ),
    );
  }

  Widget _modeIcon(_ModeData mode) => Container(
    width: 44, height: 44,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: mode.color.withValues(alpha: 0.15),
    ),
    child: Icon(mode.icon, color: mode.color, size: 22),
  );

  Widget _buildPatternDiscovery(AsyncValue<JournalAnalytics> analyticsAsync) {
    return analyticsAsync.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (analytics) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Pattern Discovery'),
        const SizedBox(height: 12),
        _glassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: _secondary)),
            const SizedBox(width: 10),
            Text('Weekly Flow', style: GoogleFonts.inter(color: _onSurface, fontWeight: FontWeight.w600, fontSize: 14)),
            const Spacer(),
            Text('${analytics.mostCommonMood} State', style: GoogleFonts.inter(color: _secondary, fontSize: 12)),
          ]),
          const SizedBox(height: 16),
          // Simple wave visualization
          SizedBox(height: 70, child: CustomPaint(painter: _WavePainter(score: analytics.emotionalTrendScore))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(children: [
              const Icon(Icons.lightbulb_outline_rounded, color: _primary, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'Nova noticed your clarity peaks after morning journaling sessions.',
                style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 12, height: 1.5),
              )),
            ]),
          ),
        ])),
      ]),
    );
  }

  Widget _buildMemoryVault(AsyncValue<JournalEntry?> memoryAsync) {
    return memoryAsync.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (entry) {
        if (entry == null) return const SizedBox();
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionLabel('Memory Vault'),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(children: [
              Image.asset('assets/images/journal/memory_vault.png',
                height: 200, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 200, color: _surface),
              ),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                  ),
                ),
              ),
              Positioned(bottom: 16, left: 16, right: 16, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.history_rounded, color: _primary, size: 14),
                    const SizedBox(width: 4),
                    Text('1 Year Ago', style: GoogleFonts.inter(color: _primary, fontSize: 11, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 4),
                  Text(entry.title ?? 'Finding calm in routine',
                    style: GoogleFonts.manrope(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    entry.content.length > 60 ? '"${entry.content.substring(0, 60)}..."' : '"${entry.content}"',
                    style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ],
              )),
            ]),
          ),
        ]);
      },
    );
  }

  Widget _buildSectionLabel(String label) => _sectionLabel(label);

  Widget _buildEmptyState(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(children: [
        Icon(Icons.edit_note_rounded, size: 56, color: _onSurfaceVariant.withValues(alpha: 0.4)),
        const SizedBox(height: 16),
        Text('Your sanctuary is empty', style: GoogleFonts.manrope(color: _onSurface, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Start your first entry to begin the journey.', style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 14), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => context.push('/journal/editor'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: const LinearGradient(colors: [_primary, Color(0xFF937DFF)]),
            ),
            child: Text('Write your first entry', style: GoogleFonts.inter(color: const Color(0xFF1C0062), fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    ),
  );

  Widget _buildEntryCard(BuildContext context, JournalEntry entry) {
    final moodColor = _moodColor(entry.moodState);
    return GestureDetector(
      onTap: () => context.push('/journal/editor', extra: entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _surface.withValues(alpha: 0.4),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Text(_typeLabel(entry.journalType),
                style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            ),
            const Spacer(),
            Text(DateFormat('h:mm a').format(entry.createdAt),
              style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 11)),
          ]),
          const SizedBox(height: 10),
          Text(entry.title ?? entry.content,
            style: GoogleFonts.manrope(color: _onSurface, fontSize: 16, fontWeight: FontWeight.w700),
            maxLines: 2, overflow: TextOverflow.ellipsis),
          if (entry.content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(entry.content, style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 13, height: 1.5),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 12),
          Row(children: [
            if (entry.moodState != null) ...[
              Icon(Icons.circle, color: moodColor, size: 8),
              const SizedBox(width: 6),
              Text(entry.moodState!, style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 11)),
              const SizedBox(width: 16),
            ],
            const Icon(Icons.text_fields_rounded, color: _onSurfaceVariant, size: 14),
            const SizedBox(width: 4),
            Text('${entry.wordCount} words', style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 11)),
          ]),
        ]),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _glassCard({required Widget child, Color? leftAccent}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: _surface.withValues(alpha: 0.4),
      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
    ),
    child: leftAccent != null
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 4, margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [leftAccent.withValues(alpha: 0), leftAccent])),
            ),
            Expanded(child: child),
          ])
        : child,
  );

  Widget _glassIconBtn(IconData icon, {required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _surface.withValues(alpha: 0.6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Icon(icon, color: _onSurface, size: 22),
    ),
  );

  Widget _statChip(IconData icon, String value, String label) => Column(children: [
    Row(children: [
      Icon(icon, color: _onSurfaceVariant, size: 12),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 10, letterSpacing: 0.5)),
    ]),
    Text(value, style: GoogleFonts.manrope(color: _onSurface, fontSize: 16, fontWeight: FontWeight.w800)),
  ]);

  Widget _sectionLabel(String text) => Text(text.toUpperCase(),
    style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2));

  Color _moodColor(String? mood) {
    switch (mood?.toLowerCase()) {
      case 'calm': return _secondary;
      case 'happy': return const Color(0xFFFFD700);
      case 'anxious': return const Color(0xFFFFB4AB);
      case 'sad': return const Color(0xFF80BDFF);
      default: return _onSurfaceVariant;
    }
  }

  String _typeLabel(String type) => type.replaceAll('_', ' ');
}

// ─── Wave painter for pattern discovery ──────────────────────────────────────
class _WavePainter extends CustomPainter {
  final double score;
  _WavePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(colors: const [Color(0xFFCABEFF), Color(0xFF44E2CD), Color(0xFFCABEFF)])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final segments = 8;
    final dx = size.width / segments;
    final baseline = size.height * 0.55;
    final amp = size.height * 0.35;

    path.moveTo(0, baseline);
    for (int i = 0; i < segments; i++) {
      final x1 = dx * i + dx / 2;
      final x2 = dx * (i + 1);
      final yCtrl = baseline - amp * sin((i + score / 5) * pi / 2);
      final yEnd = baseline + amp * 0.3 * sin((i + 1 + score / 5) * pi / 2);
      path.quadraticBezierTo(x1, yCtrl, x2, yEnd);
    }

    canvas.drawPath(path, paint);

    // Dot at peak
    final dotPaint = Paint()..color = const Color(0xFF44E2CD);
    canvas.drawCircle(Offset(size.width * 0.5, baseline - amp * 0.6), 5, dotPaint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.score != score;
}

// ─── Mode data ───────────────────────────────────────────────────────────────
class _ModeData {
  final String title, subtitle, type;
  final IconData icon;
  final Color color;
  final String? imagePath;
  const _ModeData(this.title, this.subtitle, this.icon, this.color, this.type, this.imagePath);
}
