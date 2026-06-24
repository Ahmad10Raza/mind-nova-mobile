import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/design/colors/app_colors.dart';
import '../../../core/design/typography/app_typography.dart';
import '../../../core/design/spacing/app_spacing.dart';
import '../../../core/design/surfaces/app_surfaces.dart';
import '../../../core/design/radius/app_radius.dart';
import '../../../core/design/shadows/app_shadows.dart';
import '../../../core/design/gradients/app_gradients.dart';

import '../../mood/models/mood_model.dart';
import '../../mood/providers/mood_log_provider.dart';
import '../../mood/providers/analytics_provider.dart';
import '../../mood/data/mood_theme_mapper.dart';

import '../data/emotional_states.dart';
import 'widgets/mood_hero_section.dart';
import 'widgets/mood_correlation_insights.dart';
import 'widgets/emotional_timeline.dart';
import 'mood_history_screen.dart';

import '../../voice/presentation/widgets/voice_record_button.dart';
import '../../voice/presentation/widgets/transcript_editor.dart';
import '../../voice/data/voice_service.dart';
import '../../profile/presentation/profile_screen.dart';

/// The redesigned Mood Home — an emotional intelligence surface.
/// NOT an analytics dashboard. A reflective emotional awareness space.
class MoodHomeScreenV2 extends ConsumerStatefulWidget {
  const MoodHomeScreenV2({super.key});

  @override
  ConsumerState<MoodHomeScreenV2> createState() => _MoodHomeScreenV2State();
}

class _MoodHomeScreenV2State extends ConsumerState<MoodHomeScreenV2> {
  int _selectedDays = 30;
  bool _showPieChart = false;

  Future<void> _onRefresh() async {
    ref.invalidate(moodAnalyticsSummaryProvider);
    ref.invalidate(weeklyInsightsProvider);
    ref.invalidate(moodDistributionProvider);
    ref.invalidate(triggerAnalysisProvider);
    ref.invalidate(recoveryEffectivenessProvider);
    ref.invalidate(reflectionHighlightsProvider);
    ref.invalidate(novaSuggestsProvider);
    ref.invalidate(analyticsProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F131F),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF44E2CD),
        backgroundColor: const Color(0xFF262A37),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
          // Header / App Bar Space
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
          
          // ─── 1. Emotional Mirror (Hero) ──────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(child: _buildHeroSection()),
          ),
          
          // ─── 2. Nova Noticed ─────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
            sliver: SliverToBoxAdapter(child: _buildNovaNoticed()),
          ),

          // ─── 3. Emotional Journey ────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
            sliver: SliverToBoxAdapter(child: _buildEmotionalJourney()),
          ),

          // ─── 4. Mood Composition ─────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
            sliver: SliverToBoxAdapter(child: _buildMoodComposition()),
          ),

          // ─── 5. What Shapes Your Emotions ────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
            sliver: SliverToBoxAdapter(child: _buildInfluenceCards()),
          ),

          // ─── 6. What Helps You Recover ───────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
            sliver: SliverToBoxAdapter(child: _buildRecoveryActivities()),
          ),

          // ─── 7. Reflection Highlights ────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
            sliver: SliverToBoxAdapter(child: _buildReflectionHighlights()),
          ),

          // ─── 8. Mood History Button ───────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
            sliver: SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodHistoryScreen()));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171B28).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_rounded, color: Color(0xFFDFE2F3)),
                      const SizedBox(width: 12),
                      Text(
                        'View Full Mood History',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFDFE2F3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF938EA1), size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── 9. Nova Suggests ────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
            sliver: SliverToBoxAdapter(child: _buildNovaSuggests()),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF171B28).withOpacity(0.4),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(color: Colors.white.withOpacity(0.05), offset: const Offset(0, 1), blurRadius: 1, spreadRadius: 0, blurStyle: BlurStyle.inner),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final analyticsAsync = ref.watch(moodAnalyticsSummaryProvider(7));
    return _buildGlassCard(
      padding: const EdgeInsets.all(32),
      child: analyticsAsync.when(
        data: (data) {
          final isGrowing = data.trendDirection == 'up';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('YOUR EMOTIONAL MIRROR', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.05 * 14, color: const Color(0xFF44E2CD))),
              const SizedBox(height: 16),
              Text(
                data.summaryMessage ?? 'Start logging to build your emotional mirror.',
                style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w500, height: 1.3, color: const Color(0xFFDFE2F3)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (data.hasData)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF44E2CD).withOpacity(0.1),
                        border: Border.all(color: const Color(0xFF44E2CD).withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isGrowing ? Icons.trending_up : Icons.trending_flat, color: const Color(0xFF44E2CD), size: 16),
                          const SizedBox(width: 8),
                          Text(isGrowing ? 'Growing' : 'Stable', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF44E2CD))),
                        ],
                      ),
                    ),
                  if (data.hasData) const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmotionalCheckinScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCABEFF),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text('Check In', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF2A0088))),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))),
        error: (e, st) => Text('Error loading mirror', style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildNovaNoticed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFCABEFF)),
            const SizedBox(width: 8),
            Text('Nova Noticed', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w500, color: const Color(0xFFDFE2F3))),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Expanded(
                  child: _buildGlassCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: const Color(0xFF44E2CD).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.edit_note, color: Color(0xFF44E2CD)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('You were calmer on days you journaled', style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: const Color(0xFFDFE2F3))),
                              const SizedBox(height: 8),
                              Text('Insight derived from 4 journaling sessions', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF938EA1))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildGlassCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: const Color(0xFFCABEFF).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.bedtime, color: Color(0xFFCABEFF)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sleep appears strongly connected to anxiety spikes', style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: const Color(0xFFDFE2F3))),
                              const SizedBox(height: 8),
                              Text('Observed on Tuesday and Friday', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF938EA1))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmotionalJourney() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Emotional Journey', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w500, color: const Color(0xFFDFE2F3))),
        const SizedBox(height: 24),
        _buildGlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF44E2CD).withOpacity(0.1), border: Border.all(color: const Color(0xFF44E2CD).withOpacity(0.2)), borderRadius: BorderRadius.circular(100)),
                        child: Text('😊 Best: Mon', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF44E2CD))),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFCABEFF).withOpacity(0.1), border: Border.all(color: const Color(0xFFCABEFF).withOpacity(0.2)), borderRadius: BorderRadius.circular(100)),
                        child: Text('😔 Low: Tue', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFCABEFF))),
                      ),
                    ],
                  ),
                  PopupMenuButton<int>(
                    initialValue: _selectedDays,
                    onSelected: (value) {
                      setState(() {
                        _selectedDays = value;
                      });
                    },
                    color: const Color(0xFF262A37),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 7, child: Text('7 Days', style: GoogleFonts.inter(color: const Color(0xFFDFE2F3)))),
                      PopupMenuItem(value: 14, child: Text('14 Days', style: GoogleFonts.inter(color: const Color(0xFFDFE2F3)))),
                      PopupMenuItem(value: 30, child: Text('30 Days', style: GoogleFonts.inter(color: const Color(0xFFDFE2F3)))),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF262A37), border: Border.all(color: Colors.white.withOpacity(0.05)), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Text('$_selectedDays Days', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFDFE2F3))),
                          const SizedBox(width: 4),
                          const Icon(Icons.expand_more, size: 14, color: Color(0xFFDFE2F3)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 192,
                width: double.infinity,
                child: Stack(
                  children: [
                    ref.watch(analyticsProvider(_selectedDays)).isLoading
                        ? const SizedBox(height: 192, child: Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))))
                        : CustomPaint(
                            size: const Size(double.infinity, 192),
                            painter: _EmotionalJourneyPainter(ref.watch(analyticsProvider(_selectedDays)).trends),
                          ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((d) => 
                          Text(d.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, letterSpacing: 0.05 * 10, color: const Color(0xFF938EA1)))
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

      Widget _buildMoodComposition() {
    final distAsync = ref.watch(moodDistributionProvider(_selectedDays));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mood Composition', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w500, color: const Color(0xFFDFE2F3))),
            IconButton(
              icon: Icon(_showPieChart ? Icons.bar_chart : Icons.pie_chart, color: const Color(0xFFDFE2F3)),
              onPressed: () => setState(() => _showPieChart = !_showPieChart),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildGlassCard(
          padding: const EdgeInsets.all(32),
          child: distAsync.when(
            data: (data) {
              if (!data.hasData) return const Center(child: Text('Not enough data', style: TextStyle(color: Colors.white)));
              
              if (_showPieChart) {
                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                          sections: [
                            if (data.positive > 0)
                              PieChartSectionData(color: const Color(0xFF44E2CD), value: data.positive.toDouble(), title: '${data.positive}%', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            if (data.neutral > 0)
                              PieChartSectionData(color: const Color(0xFFCABEFF), value: data.neutral.toDouble(), title: '${data.neutral}%', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            if (data.negative > 0)
                              PieChartSectionData(color: const Color(0xFF938EA1), value: data.negative.toDouble(), title: '${data.negative}%', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            if (data.critical > 0)
                              PieChartSectionData(color: const Color(0xFFFF5E5E), value: data.critical.toDouble(), title: '${data.critical}%', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        if (data.positive > 0) _buildLegendItem('Positive', const Color(0xFF44E2CD)),
                        if (data.neutral > 0) _buildLegendItem('Neutral', const Color(0xFFCABEFF)),
                        if (data.negative > 0) _buildLegendItem('Negative', const Color(0xFF938EA1)),
                        if (data.critical > 0) _buildLegendItem('Critical', const Color(0xFFFF5E5E)),
                      ],
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _buildCompositionRow('Positive', '${data.positive}%', data.positive / 100, const Color(0xFF44E2CD)),
                  const SizedBox(height: 24),
                  _buildCompositionRow('Neutral', '${data.neutral}%', data.neutral / 100, const Color(0xFFCABEFF)),
                  const SizedBox(height: 24),
                  _buildCompositionRow('Negative', '${data.negative}%', data.negative / 100, const Color(0xFF938EA1)),
                  if (data.critical > 0) ...[
                    const SizedBox(height: 24),
                    _buildCompositionRow('Critical', '${data.critical}%', data.critical / 100, const Color(0xFFFF5E5E)),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))),
            error: (e, st) => const Text('Error loading composition', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFC9C4D8))),
      ],
    );
  }

  Widget _buildCompositionRow(String label, String percent, double progress, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFC9C4D8))),
            Text(percent, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF262A37),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildInfluenceCards() {
    final triggerAsync = ref.watch(triggerAnalysisProvider(_selectedDays));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What Shapes Your Emotions', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w500, color: const Color(0xFFDFE2F3))),
        const SizedBox(height: 24),
        triggerAsync.when(
          data: (data) {
            if (!data.hasData || data.topTriggers.isEmpty) return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Text('Not enough data for this period.', style: GoogleFonts.inter(color: const Color(0xFF938EA1)))));
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: data.topTriggers.map((t) {
                  return SizedBox(
                    width: 280,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: _buildInfluenceCard('Influence', t.tag, 'Linked heavily to ${t.linkedMoods.join(" and ")}', Color(int.parse(t.color.replaceFirst('#', '0xFF')))),
                    ),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))),
          error: (e, st) => const Text('Error loading triggers', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildInfluenceCard(String label, String title, String body, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF171B28).withOpacity(0.4),
            border: Border(
              left: BorderSide(color: color, width: 4),
              top: BorderSide(color: Colors.white.withOpacity(0.08)),
              right: BorderSide(color: Colors.white.withOpacity(0.08)),
              bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: -0.05 * 12, color: color)),
              const SizedBox(height: 8),
              Text(title, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w500, color: const Color(0xFFDFE2F3))),
              const SizedBox(height: 12),
              Text(body, style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFC9C4D8))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecoveryActivities() {
    final recoveryAsync = ref.watch(recoveryEffectivenessProvider(_selectedDays));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What Helps You Recover', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w500, color: const Color(0xFFDFE2F3))),
        const SizedBox(height: 24),
        recoveryAsync.when(
          data: (data) {
            if (!data.hasData || data.tools.isEmpty) return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Text('Not enough data for this period.', style: GoogleFonts.inter(color: const Color(0xFF938EA1)))));
            return Column(
              children: data.tools.map((t) {
                int score = (t.helpedPercent / 33).round();
                if (score > 3) score = 3;
                if (score < 1) score = 1;
                final labels = ['EMERGING IMPACT', 'MODERATE IMPACT', 'HIGH IMPACT'];
                final colors = [const Color(0xFFC2C6D1), const Color(0xFFCABEFF), const Color(0xFF44E2CD)];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildRecoveryRow(Icons.healing, t.name, labels[score-1], colors[score-1], score),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))),
          error: (e, st) => const Text('Error loading recovery', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildRecoveryRow(IconData icon, String title, String impactLabel, Color color, int score) {
    return _buildGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFFDFE2F3)))),
          Text(impactLabel, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.05 * 10, color: color)),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) => Container(
              width: 4, height: 16,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: index < score ? color : color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(100),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionHighlights() {
    final highlightsAsync = ref.watch(reflectionHighlightsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reflection Highlights', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w500, color: const Color(0xFFDFE2F3))),
        const SizedBox(height: 24),
        highlightsAsync.when(
          data: (data) {
            if (!data.hasData || data.highlights.isEmpty) return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Text('Not enough data for this period.', style: GoogleFonts.inter(color: const Color(0xFF938EA1)))));
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: data.highlights.map((h) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildQuoteCard(h.category, h.quote, Color(int.parse(h.color.replaceFirst('#', '0xFF')))),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))),
          error: (e, st) => const Text('Error loading highlights', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildQuoteCard(String category, String quote, Color color) {
    return SizedBox(
      width: 220,
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.format_quote, color: color),
            const SizedBox(height: 16),
            Text(quote, style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: const Color(0xFFDFE2F3))),
            const SizedBox(height: 16),
            Text(category.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.05 * 10, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildNovaSuggests() {
    final suggestAsync = ref.watch(novaSuggestsProvider);
    return suggestAsync.when(
      data: (data) {
        return _buildGlassCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.8, -0.8),
                          radius: 1.5,
                          colors: [const Color(0xFF2A0088).withOpacity(0.4), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 100, height: 100,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFFCABEFF).withOpacity(0.3), blurRadius: 48)]),
                              ),
                              ClipOval(
                                child: Image.network('https://lh3.googleusercontent.com/aida-public/AB6AXuB2KJZNVuhrPtu2WGQAm6ocKFWUS5d5X4f96qbnxHowippfD2PhH1mR_ppqClBuSd3tUxZQ6f3FEQGJFqG-3IBOTAQEqJWven0WsBr0LSLcrPHbvVYel3-ujyEKec-AjOOsuuKQRwtxjNzOuOzk8qZMejMbK5CD8A6qA_YetDmU1TdZlQbr6Wkax_N5klQrCepq2lbD2d9RophFcwMNbMJaMC-FefHDtN7lfNi_vyJag_OwVCtEjA9IMMK9NYGU8pwjIexGmEwAPG3-', fit: BoxFit.cover),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(data.title, style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w500, color: const Color(0xFFCABEFF)), textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            Text(data.body, style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFDFE2F3)), textAlign: TextAlign.center),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  decoration: BoxDecoration(color: const Color(0xFF44E2CD), borderRadius: BorderRadius.circular(100), boxShadow: [BoxShadow(color: const Color(0xFF44E2CD).withOpacity(0.4), blurRadius: 20)]),
                                  child: Text(data.actionLabel, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF003731))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))),
      error: (e, st) => const Text('Error loading suggestions', style: TextStyle(color: Colors.red)),
    );
  }
}

class _EmotionalJourneyPainter extends CustomPainter {
  final List<MoodTrend> trends;

  _EmotionalJourneyPainter(this.trends);

  @override
  void paint(Canvas canvas, Size size) {
    if (trends.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final path = Path();
    
    final double widthStep = size.width / (trends.length > 1 ? trends.length - 1 : 1);
    
    for (int i = 0; i < trends.length; i++) {
      final t = trends[i];
      final normalizedScore = (t.score - 1) / 4.0;
      final y = size.height - (normalizedScore * size.height);
      final x = i * widthStep;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * widthStep;
        final prevT = trends[i - 1];
        final prevNorm = (prevT.score - 1) / 4.0;
        final prevY = size.height - (prevNorm * size.height);
        
        path.cubicTo(
          prevX + widthStep / 2, prevY,
          x - widthStep / 2, y,
          x, y,
        );
      }
    }

    paint.shader = const LinearGradient(
      colors: [Color(0xFFCABEFF), Color(0xFF44E2CD)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    // Draw emojis at each point
    for (int i = 0; i < trends.length; i++) {
      final t = trends[i];
      if (t.emoji == null || t.emoji!.isEmpty) continue;

      final normalizedScore = (t.score - 1) / 4.0;
      final y = size.height - (normalizedScore * size.height);
      final x = i * widthStep;

      final textPainter = TextPainter(
        text: TextSpan(text: t.emoji, style: const TextStyle(fontSize: 16)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      // Draw slightly above the point
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height - 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EmotionalJourneyPainter oldDelegate) => true;
}

class EmotionalCheckinScreen extends ConsumerStatefulWidget {
  const EmotionalCheckinScreen({super.key});

  @override
  ConsumerState<EmotionalCheckinScreen> createState() => _EmotionalCheckinScreenState();
}

class _EmotionalCheckinScreenState extends ConsumerState<EmotionalCheckinScreen> {
  bool _isSubmitting = false;
  EmotionalState? _selectedState;
  int _energyLevel = 3; // 1-5
  int _stressLevel = 3; // 1-5
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();
  final List<String> _selectedTriggers = []; // 0: state, 1: levels, 2: reflection
  int _step = 0; // 0: state, 1: levels, 2: reflection

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      appBar: AppBar(
        backgroundColor: AppSurfaces.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _step == 0
              ? 'How are you feeling?'
              : _step == 1
                  ? 'Energy & Stress'
                  : 'Reflection',
          style: AppTypography.headingMedium.copyWith(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: index <= _step
                            ? AppColors.novaPurple
                            : AppColors.backgroundTertiary,
                        borderRadius: AppRadius.full,
                      ),
                    ),
                  );
                }),
              ),
            ),
            AppSpacing.v24,

            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                physics: const BouncingScrollPhysics(),
                child: _buildStep(),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _step--),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSecondary,
                            borderRadius: AppRadius.full,
                          ),
                          child: Center(
                            child: Text('Back', style: AppTypography.button),
                          ),
                        ),
                      ),
                    ),
                  if (_step > 0) AppSpacing.h12,
                  Expanded(
                    child: GestureDetector(
                      onTap: _handleNext,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                        decoration: BoxDecoration(
                          gradient: _canProceed()
                              ? AppGradients.nova
                              : null,
                          color: _canProceed() ? null : AppColors.backgroundTertiary,
                          borderRadius: AppRadius.full,
                        ),
                        child: Center(
                          child: _isSubmitting
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(
                                  _step < 2 ? 'Continue' : 'Complete',
                                  style: AppTypography.button.copyWith(
                                    color: _canProceed() ? Colors.white : AppColors.textMuted,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildStateSelection();
      case 1:
        return _buildLevelSliders();
      case 2:
        return _buildReflection();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Step 0: Emotional State ────────────────────────
  Widget _buildStateSelection() {
    final positive = ['Overjoyed', 'Happy', 'Calm', 'Grateful'];
    final neutral = ['Neutral', 'Tired', 'Numb', 'Distracted'];
    final negative = ['Sad', 'Angry', 'Lonely', 'Stressed'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How are you feeling right now?', style: AppTypography.headingMedium),
        AppSpacing.v20,

        _buildMoodGrid('Positive', positive),
        AppSpacing.v16,
        _buildMoodGrid('Neutral', neutral),
        AppSpacing.v16,
        _buildMoodGrid('Negative', negative),
      ],
    );
  }

  Widget _buildMoodGrid(String title, List<String> moods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.headingMedium.copyWith(color: AppColors.textSecondary, fontSize: 16),
        ),
        AppSpacing.v12,
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: moods.map((mood) {
            final theme = MoodThemeMapper.getTheme(mood);
            // We use the theme's first gradient color as the base color
            final primaryColor = theme.gradient.first;
            // Hack: we store the mood string in the _selectedState id for now
            final isSelected = _selectedState?.id == mood;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedState = EmotionalState(
                    id: mood,
                    label: mood,
                    description: theme.subtitle,
                    icon: Icons.circle, // Fallback icon
                    color: primaryColor,
                    category: theme.category,
                    novaResponse: theme.subtitle,
                  );
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor.withOpacity(0.15) : AppColors.backgroundSecondary.withOpacity(0.5),
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: isSelected ? primaryColor.withOpacity(0.4) : AppColors.backgroundTertiary,
                  ),
                ),
                child: Row(
                  children: [
                    Text(theme.emoji, style: const TextStyle(fontSize: 20)),
                    AppSpacing.h12,
                    Expanded(
                      child: Text(
                        mood,
                        style: AppTypography.body.copyWith(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Step 1: Energy & Stress Levels ────────────────
  Widget _buildLevelSliders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nova response for selected emotion
        if (_selectedState != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: _selectedState!.color.withOpacity(0.06),
              borderRadius: AppRadius.md,
              border: Border.all(color: _selectedState!.color.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: _selectedState!.color, size: 16),
                AppSpacing.h12,
                Expanded(
                  child: Text(
                    _selectedState!.novaResponse,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.v32,
        ],

        // Energy level
        Text('Energy level', style: AppTypography.headingMedium),
        AppSpacing.v4,
        Text(
          'How much energy do you have right now?',
          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
        ),
        AppSpacing.v16,
        _buildLevelSelector(
          value: _energyLevel,
          onChanged: (v) => setState(() => _energyLevel = v),
          lowLabel: 'Empty',
          highLabel: 'Full',
          color: AppColors.warmSupport,
        ),
        AppSpacing.v32,

        // Stress level
        Text('Stress level', style: AppTypography.headingMedium),
        AppSpacing.v4,
        Text(
          'How stressed do you feel?',
          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
        ),
        AppSpacing.v16,
        _buildLevelSelector(
          value: _stressLevel,
          onChanged: (v) => setState(() => _stressLevel = v),
          lowLabel: 'None',
          highLabel: 'Very',
          color: AppColors.calmTeal,
        ),
      ],
    );
  }

  Widget _buildLevelSelector({
    required int value,
    required ValueChanged<int> onChanged,
    required String lowLabel,
    required String highLabel,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final level = index + 1;
            final isSelected = level == value;
            return GestureDetector(
              onTap: () => onChanged(level),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.15) : AppColors.backgroundSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color.withOpacity(0.4) : AppColors.backgroundTertiary,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: AppTypography.headingMedium.copyWith(
                      color: isSelected ? color : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        AppSpacing.v8,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(lowLabel, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
            Text(highLabel, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }

  // ─── Step 2: Reflection ─────────────────────────────
  Widget _buildReflection() {
    final prompt = ReflectionPrompts.forTimeOfDay();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reflection', style: AppTypography.headingMedium),
        AppSpacing.v4,
        Text(
          'Optional. Write freely, or skip.',
          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
        ),
        AppSpacing.v20,

        // Prompt card
        Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: AppColors.novaPurple.withOpacity(0.06),
            borderRadius: AppRadius.md,
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.novaPurple, size: 18),
              AppSpacing.h12,
              Expanded(
                child: Text(
                  prompt.text,
                  style: AppTypography.body.copyWith(
                    color: AppColors.novaPurple,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.v20,

        // Text field
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: AppRadius.md,
          ),
          child: TextField(
            controller: _noteController,
            focusNode: _noteFocusNode,
            maxLines: 4,
            style: AppTypography.body,
            decoration: InputDecoration(
              hintText: 'What\'s on your mind? (optional)',
              hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSpacing.s16),
            ),
          ),
        ),
        AppSpacing.v20,
        Center(
          child: Column(
            children: [
              Text('Or speak your reflection', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              AppSpacing.v12,
              VoiceRecordButton(
                onRecordingComplete: (path) {
                  Navigator.of(context, rootNavigator: true).pop(); // Close recorder
                  _processAudioFile(path);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _processAudioFile(String path) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppSurfaces.primary, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.novaPurple),
              const SizedBox(height: 16),
              Text('Transcribing audio...', style: GoogleFonts.inter(color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );

    try {
      final keepVoice = ref.read(voiceRetentionProvider);
      final result = await ref.read(voiceServiceProvider).transcribeAudio(
        filePath: path,
        featureType: 'MOOD',
        keepRecording: keepVoice,
      );
      
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
        setState(() {
          _noteController.text = _noteController.text.isEmpty
              ? result.transcript
              : '${_noteController.text} ${result.transcript}';
        });
        _noteFocusNode.requestFocus();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transcription failed: $e')));
      }
    }
  }



  bool _canProceed() {
    if (_step == 0) return _selectedState != null;
    return true;
  }

  Future<void> _handleNext() async {
    if (!_canProceed() || _isSubmitting) return;

    if (_step < 2) {
      setState(() => _step++);
    } else {
      // Complete — send to backend
      setState(() => _isSubmitting = true);
      try {
        final service = ref.read(moodServiceProvider);
        
        final mappedIntensity = _stressLevel > 3 ? 'strong' : _stressLevel == 3 ? 'moderate' : 'mild';
        
        await service.logMood(
          moodName: _selectedState?.label ?? 'Unknown',
          category: _selectedState?.category ?? 'neutral',
          intensity: mappedIntensity,
          tags: [_selectedState?.label ?? 'Unknown'],
          notes: _noteController.text.isNotEmpty ? _noteController.text : null,
        );
        
        // Invalidate analytics so it refreshes on the parent screen
        ref.invalidate(analyticsProvider);
        ref.invalidate(moodDistributionProvider);
        ref.invalidate(triggerAnalysisProvider);
        ref.invalidate(recoveryEffectivenessProvider);
        ref.invalidate(moodAnalyticsSummaryProvider);
        
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save mood: $e')));
        }
      }
    }
  }
}
