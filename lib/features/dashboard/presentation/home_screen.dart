import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/design/colors/app_colors.dart';
import 'widgets/sidebar_drawer.dart';
import 'widgets/ambient_background.dart';
import '../../auth/providers/auth_provider.dart';
import '../../scoring/providers/scoring_provider.dart';
import '../../mood/providers/analytics_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../ai_reports/providers/weekly_report_provider.dart';
import '../../ai_reports/models/weekly_report_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _orbPulseController;
  late final AnimationController _ringLightController;

  @override
  void initState() {
    super.initState();
    _orbPulseController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
    _ringLightController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _orbPulseController.dispose();
    _ringLightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(authProvider).displayName ?? 'Friend';
    final firstName = userName.split(' ').first;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      drawer: const SidebarDrawer(),
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackground(currentState: EmotionalState.night)),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // APP BAR
                SliverToBoxAdapter(child: _buildAppBar(firstName)),
                // HERO: SOUL SIGNATURE
                SliverToBoxAdapter(child: _buildSoulSignature(firstName)),
                // HEALTH METRICS
                SliverToBoxAdapter(child: _buildHealthMetricsSection()),
                // GRID SECTIONS
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(child: _buildGridSections()),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  APP BAR
  // ═══════════════════════════════════════════
  Widget _buildAppBar(String firstName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.menu_rounded, 
                color: AppColors.novaPurpleLight, 
                size: 28
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('MindNova', style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: AppColors.novaPurpleLight)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.novaPurpleLight, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  SOUL SIGNATURE HERO
  // ═══════════════════════════════════════════
  Widget _buildSoulSignature(String firstName) {
    final moodAsync = ref.watch(moodHomeWidgetProvider);
    final focusAsync = ref.watch(todayFocusProvider);
    
    // Dynamic quote from AI based on user history. Fallbacks to focus title.
    final dynamicQuote = moodAsync.whenOrNull(data: (d) => d.insightMessage) ?? 
                         focusAsync.whenOrNull(data: (d) => d.title) ?? 
                         'Your soul is stirring';

    // To prevent the name being repeatedly appended if already in the AI string
    final displayQuote = dynamicQuote.contains(firstName) 
        ? dynamicQuote 
        : '$dynamicQuote, $firstName.';

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      child: Column(
        children: [
          // Orb
          AnimatedBuilder(
            animation: _orbPulseController,
            builder: (context, child) {
              final v = _orbPulseController.value;
              return Container(
                width: 220, height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.calmTeal.withValues(alpha: 0.15 + v * 0.15), blurRadius: 40 + v * 20, spreadRadius: 10),
                    BoxShadow(color: AppColors.novaPurpleLight.withValues(alpha: 0.1 + v * 0.1), blurRadius: 60 + v * 20, spreadRadius: 5),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    children: [
                      // Glass bg
                      BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle,
                            color: const Color(0xFF171B28).withValues(alpha: 0.4),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                        ),
                      ),
                      // Nova Avatar
                      SizedBox.expand(
                        child: Image.asset('assets/images/ai_meditation.png', fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.novaPurpleLight.withValues(alpha: 0.1),
                            ),
                            child: const Icon(Icons.auto_awesome, color: AppColors.novaPurpleLight, size: 64),
                          ),
                        ),
                      ),
                      // Shimmer
                      _SoulShimmer(animation: _orbPulseController),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // Dynamic Quote
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(displayQuote, textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white, height: 1.3)),
          ),
          const SizedBox(height: 24),
          // Primary CTA Button
          GestureDetector(
            onTap: () => context.push('/mood-analytics'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFD3BFFF), // Light purple from screenshot
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFD3BFFF).withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 4)),
                ],
              ),
              child: Text(
                "Start Today's Check-In",
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF5A2A94)), // Dark purple text
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  GRID SECTIONS
  // ═══════════════════════════════════════════
  Widget _buildGridSections() {
    return Column(
      children: [
        _buildResilienceCard(),
        const SizedBox(height: 16),
        _buildPersonalJourneyCard(),
        const SizedBox(height: 16),
        _buildEmotionalTrendsCard(),
        const SizedBox(height: 16),
        _buildWeeklyReportCard(),
        const SizedBox(height: 16),
        _buildReflectionHistoryCard(),
      ],
    );
  }

  // ═══════════════════════════════════════════
  //  HEALTH METRICS (HORIZONTAL LIST)
  // ═══════════════════════════════════════════
  Widget _buildHealthMetricsSection() {
    final cmhiAsync = ref.watch(latestCMHIProvider);
    final dims = cmhiAsync.whenOrNull(data: (d) => d?.dimensions);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('Health Dimensions', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 210,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildHealthMetricCard(
                title: 'Cognitive',
                value: dims == null ? '--' : (100.0 - dims.cognitive).toStringAsFixed(0),
                unit: dims == null ? '' : '%',
                progress: dims == null ? 0.0 : (100.0 - dims.cognitive) / 100.0,
                color: const Color(0xFF00E676),
                icon: Icons.psychology_rounded,
                trend: dims == null ? '--' : 'Clear',
                badge: dims == null ? 'Pending' : 'Stable',
              ),
              const SizedBox(width: 12),
              _buildHealthMetricCard(
                title: 'Physiological',
                value: dims == null ? '--' : (100.0 - dims.physiological).toStringAsFixed(0),
                unit: dims == null ? '' : '%',
                progress: dims == null ? 0.0 : (100.0 - dims.physiological) / 100.0,
                color: const Color(0xFF7C4DFF),
                icon: Icons.bedtime_rounded,
                trend: dims == null ? '--' : '-2%',
                badge: dims == null ? 'Pending' : 'Improving',
              ),
              const SizedBox(width: 12),
              _buildHealthMetricCard(
                title: 'Emotional',
                value: dims == null ? '--' : (100.0 - dims.emotional).toStringAsFixed(0),
                unit: dims == null ? '' : '%',
                progress: dims == null ? 0.0 : (100.0 - dims.emotional) / 100.0,
                color: const Color(0xFFFF4081),
                icon: Icons.favorite_rounded,
                trend: dims == null ? '--' : '+5%',
                badge: dims == null ? 'Pending' : 'Growing',
              ),
              const SizedBox(width: 12),
              _buildHealthMetricCard(
                title: 'Behavioral',
                value: dims == null ? '--' : (100.0 - dims.behavioral).toStringAsFixed(0),
                unit: dims == null ? '' : '%',
                progress: dims == null ? 0.0 : (100.0 - dims.behavioral) / 100.0,
                color: const Color(0xFFFFB300),
                icon: Icons.groups_rounded,
                trend: dims == null ? '--' : '-3%',
                badge: dims == null ? 'Pending' : 'Easing',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHealthMetricCard({
    required String title,
    required String value,
    required String unit,
    required double progress,
    required Color color,
    required IconData icon,
    required String trend,
    required String badge,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF171B28).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Row(
                children: [
                  Icon(Icons.trending_up_rounded, color: color, size: 14),
                  const SizedBox(width: 4),
                  Text(trend, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(unit, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.5))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(badge, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  PERSONAL JOURNEY CARD
  // ═══════════════════════════════════════════
  Widget _buildPersonalJourneyCard() {
    final moodAsync = ref.watch(moodHomeWidgetProvider);
    final streaks = moodAsync.whenOrNull(data: (d) => d.streaks);

    return _GlassCard(
      minHeight: 280,
      child: Stack(
        children: [
          // Animated stars
          ..._buildStars(),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Personal Journey', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.novaPurpleLight)),
                    const SizedBox(height: 4),
                    Text('Milestones as stars in your sky', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: const Color(0xFF938EA1))),
                  ]),
                  Icon(Icons.auto_graph_rounded, color: AppColors.calmTeal.withValues(alpha: 0.6)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildStatTile('${streaks?.calmDay ?? 0}', 'Days of Calm', AppColors.calmTeal)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatTile('${streaks?.positiveMood ?? 0}', 'Breakthroughs', AppColors.novaPurpleLight)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatTile('${streaks?.dailyCheckin ?? 0}', 'Reflections', AppColors.calmTeal)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatTile('${streaks?.longest ?? 0}', 'Deep Flows', AppColors.novaPurpleLight)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: const Color(0xFFC9C4D8))),
        ],
      ),
    );
  }

  List<Widget> _buildStars() {
    final rng = Random(42);
    return List.generate(6, (i) {
      final isSecondary = i % 2 == 0;
      final color = isSecondary ? AppColors.calmTeal : AppColors.novaPurpleLight;
      final size = 4.0 + rng.nextDouble() * 6;
      return Positioned(
        top: rng.nextDouble() * 200, left: rng.nextDouble() * 300,
        child: _BlinkingStar(color: color, size: size, delay: Duration(milliseconds: (rng.nextDouble() * 3000).toInt()), duration: Duration(seconds: 3 + rng.nextInt(4))),
      );
    });
  }

  // ═══════════════════════════════════════════
  //  RESILIENCE / CMHI CARD
  // ═══════════════════════════════════════════
  Widget _buildResilienceCard() {
    final cmhiAsync = ref.watch(latestCMHIProvider);
    final growthAsync = ref.watch(growthSummaryProvider);

    final score = cmhiAsync.whenOrNull(data: (d) => d?.cmhi) ?? 0;
    final growthData = growthAsync.whenOrNull(data: (d) => d);
    final delta = growthData?['weeklyChange']?.toString() ?? '0';

    return _GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('Resilience', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.calmTeal)),
          ),
          const SizedBox(height: 16),
          // Ring
          SizedBox(
            width: 140, height: 140,
            child: AnimatedBuilder(
              animation: _ringLightController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _CMHIRingPainter(score: score.toDouble(), lightProgress: _ringLightController.value),
                  child: Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(score.toStringAsFixed(0), style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w600, color: AppColors.calmTeal)),
                      Text('CMHI SCORE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: const Color(0xFF938EA1))),
                    ],
                  )),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('$delta% vs last week', textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: const Color(0xFFC9C4D8))),
          ),
          const SizedBox(height: 24),
          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(width: double.infinity, height: 1, color: Colors.white.withValues(alpha: 0.1)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('Quick Actions', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: const Color(0xFF938EA1))),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildQuickAction(Icons.emoji_emotions_rounded, 'Mood', const Color(0xFF29B6F6), () => context.push('/mood-checkin')),
                const SizedBox(width: 16),
                _buildQuickAction(Icons.edit_note_rounded, 'Journal', AppColors.calmTeal, () => context.push('/journal')),
                const SizedBox(width: 16),
                _buildQuickAction(Icons.air_rounded, 'Breathe', const Color(0xFF26A69A), () => context.push('/breathing/intro')),
                const SizedBox(width: 16),
                _buildQuickAction(Icons.auto_awesome_rounded, 'AI Chat', AppColors.novaPurpleLight, () => context.go('/chat')),
                const SizedBox(width: 16),
                _buildQuickAction(Icons.bedtime_rounded, 'Sleep', AppColors.calmTeal, () => context.push('/sleep')),
                const SizedBox(width: 16),
                _buildQuickAction(Icons.groups_rounded, 'Groups', const Color(0xFF9575CD), () => context.push('/groups')),
                const SizedBox(width: 16),
                _buildQuickAction(Icons.self_improvement_rounded, 'Meditate', const Color(0xFF29B6F6), () => context.push('/meditation')),
                const SizedBox(width: 16),
                _buildQuickAction(Icons.sos_rounded, 'SOS', const Color(0xFFE53935), () => context.push('/sos-mode')),
                const SizedBox(width: 16),
                _buildQuickAction(Icons.psychology_alt_rounded, 'Therapy', const Color(0xFF00E676), () => context.push('/therapist/home')),
                const SizedBox(width: 16),
                _buildQuickAction(Icons.favorite_rounded, 'Gratitude', const Color(0xFFFF4081), () => context.push('/gratitude')),
                const SizedBox(width: 16),
                _buildQuickAction(Icons.checklist_rounded, 'Habits', const Color(0xFF7C4DFF), () => context.push('/habits')),
                const SizedBox(width: 16),
                _buildQuickAction(Icons.headphones_rounded, 'Audio', const Color(0xFF2196F3), () => context.push('/audio')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withValues(alpha: 0.05), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
            child: Icon(icon, color: color.withValues(alpha: 0.7), size: 20),
          ),
          const SizedBox(height: 6),
          Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: const Color(0xFFC9C4D8))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  EMOTIONAL TRENDS CARD
  // ═══════════════════════════════════════════
  Widget _buildEmotionalTrendsCard() {
    final trendsAsync = ref.watch(moodTrendsProvider);
    final trends = trendsAsync.whenOrNull(data: (d) => d) ?? [];

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Emotional Trends', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
              GestureDetector(
                onTap: () => context.push('/weekly-history'),
                child: Text('Weekly View', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.calmTeal)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Bars
          if (trends.isEmpty)
            Container(
              height: 140 + 12 + 16, // Height of bars + spacing + labels
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_rounded, color: Colors.white.withValues(alpha: 0.2), size: 40),
                  const SizedBox(height: 12),
                  Text("No mood data yet", style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.5))),
                  const SizedBox(height: 4),
                  Text("Complete a check-in to see your weekly trends", style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.3))),
                ],
              ),
            )
          else ...[
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(trends.length, (i) {
                  final score = (trends[i].score / 5.0).clamp(0.0, 1.0);
                  final hexColor = trends[i].color;
                  
                  Color baseColor;
                  if (hexColor != null && hexColor.isNotEmpty) {
                    try {
                      baseColor = Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
                    } catch (_) {
                      baseColor = AppColors.novaPurpleLight;
                    }
                  } else {
                    if (score >= 0.8) {
                      baseColor = AppColors.calmTeal;
                    } else if (score >= 0.5) {
                      baseColor = AppColors.novaPurpleLight;
                    } else if (score >= 0.3) {
                      baseColor = const Color(0xFFF4A261); // Warm orange
                    } else {
                      baseColor = const Color(0xFFE76F51); // Coral red
                    }
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FractionallySizedBox(
                        heightFactor: max(0.1, score.toDouble()), // Minimum height of 10%
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(999)),
                            boxShadow: [
                              BoxShadow(color: baseColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, -2)),
                            ],
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter, end: Alignment.topCenter,
                              colors: [
                                baseColor.withValues(alpha: 0.2),
                                baseColor,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(trends.length, (i) {
                String dayLabel = DateFormat('E').format(trends[i].date).substring(0, 3);
                return Text(dayLabel, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF938EA1)));
              }),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  WEEKLY HEALTH REPORT CARD
  // ═══════════════════════════════════════════
  Widget _buildWeeklyReportCard() {
    final reportAsync = ref.watch(weeklyReportProvider);
    
    return _GlassCard(
      child: reportAsync.when(
        loading: () => const SizedBox(
          height: 120, 
          child: Center(child: CircularProgressIndicator(color: AppColors.novaPurpleLight))
        ),
        error: (e, _) => SizedBox(
          height: 120, 
          child: Center(child: Text('Error loading report', style: GoogleFonts.inter(color: Colors.white54)))
        ),
        data: (report) {
          if (report == null || report.isStarter) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Health Report', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
                    const Icon(Icons.health_and_safety_rounded, color: AppColors.calmTeal, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.novaPurpleLight, size: 32),
                      const SizedBox(height: 12),
                      Text('Your Journey Begins ✨', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text('Log moods to unlock your personalized weekly insight.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                           showDialog(
                             context: context,
                             barrierDismissible: false,
                             builder: (context) => Center(
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                 decoration: BoxDecoration(
                                   color: const Color(0xFF1E1E2E),
                                   borderRadius: BorderRadius.circular(16),
                                   border: Border.all(color: const Color(0xFF7C4DFF).withValues(alpha: 0.3)),
                                 ),
                                 child: Column(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     const CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                                     const SizedBox(height: 16),
                                     Text(
                                       'MindNova AI is analyzing your week...',
                                       style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                           );

                           try {
                             final result = await ref.read(triggerWeeklyReportProvider(null).future);
                             ref.invalidate(weeklyReportProvider);
                             
                             if (context.mounted) Navigator.of(context, rootNavigator: true).pop(); // Close dialog
                             
                             if (context.mounted) {
                               // Get nested data if wrapped, else use directly
                               final reportData = result.containsKey('data') ? result['data'] : result;
                               final newReport = WeeklyReport.fromJson(reportData);
                               
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                   content: Row(
                                     children: [
                                       const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                                       const SizedBox(width: 12),
                                       Text('Insight successfully generated!', style: GoogleFonts.inter(color: Colors.white)),
                                     ],
                                   ),
                                   backgroundColor: const Color(0xFF7C4DFF),
                                   behavior: SnackBarBehavior.floating,
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                   margin: const EdgeInsets.all(16),
                                 ),
                               );
                               
                               // Navigate to the new report!
                               context.push('/weekly-insight', extra: newReport);
                             }
                           } catch (e) {
                             if (context.mounted) Navigator.of(context, rootNavigator: true).pop(); // Close dialog
                             if (context.mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                             }
                           }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.novaPurpleLight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.novaPurpleLight.withValues(alpha: 0.5)),
                          ),
                          child: Text('Generate Now', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.novaPurpleLight)),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          }

          Color badgeColor = const Color(0xFF00E676);
          if (report.crisisRiskLevel == 'CRITICAL' || report.crisisRiskLevel == 'HIGH') badgeColor = const Color(0xFFFF6B6B);
          else if (report.crisisRiskLevel == 'MED') badgeColor = const Color(0xFFF4A261);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weekly AI Insight', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(report.crisisRiskLevel, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildReportMetric('Mood', report.avgMoodScore.toStringAsFixed(1), const Color(0xFF00D2FF)),
                  const SizedBox(width: 8),
                  if (report.wellnessScore != null)
                    _buildReportMetric('Wellness', '${report.wellnessScore!.toInt()}', const Color(0xFF00E676)),
                  const SizedBox(width: 8),
                  if (report.recoveryScore != null)
                    _buildReportMetric('Recovery', '${report.recoveryScore!.toInt()}', AppColors.novaPurpleLight),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                report.aiSummary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.8), height: 1.5),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/weekly-insight', extra: report),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.calmTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.calmTeal.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.article_rounded, color: AppColors.calmTeal, size: 16),
                            const SizedBox(width: 8),
                            Text('Full Report', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.calmTeal)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go('/chat'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.novaPurpleLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.novaPurpleLight.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: AppColors.novaPurpleLight, size: 16),
                            const SizedBox(width: 8),
                            Text('Talk to AI', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.novaPurpleLight)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildReportMetric(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  REFLECTION HISTORY CARD
  // ═══════════════════════════════════════════
  Widget _buildReflectionHistoryCard() {
    final historyState = ref.watch(moodHistoryProvider);
    final entries = historyState.filteredEntries.take(3).toList();

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reflection History', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
              GestureDetector(
                onTap: () => context.push('/mood-analytics'),
                child: Text('Enter Vault', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.novaPurpleLight)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No reflections yet.\nStart your first mood check-in.', textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF938EA1), height: 1.6))),
            )
          else
            ...entries.map((e) => _buildHistoryTile(e.moodName, e.emoji, '${e.createdAt.month}/${e.createdAt.day}', e.category == 'positive' ? AppColors.novaPurpleLight : AppColors.calmTeal)),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(String title, String emoji, String date, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.withValues(alpha: 0.2)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(date, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF938EA1))),
              ],
            )),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: const Color(0xFF938EA1)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  REUSABLE WIDGETS
// ═══════════════════════════════════════════

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double minHeight;
  final EdgeInsetsGeometry padding;
  const _GlassCard({required this.child, this.minHeight = 0, this.padding = const EdgeInsets.all(24)});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF171B28).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.05), blurRadius: 1, offset: const Offset(0, 1))],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SoulShimmer extends StatelessWidget {
  final Animation<double> animation;
  const _SoulShimmer({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + animation.value * 2, -1 + animation.value * 2),
              end: Alignment(animation.value * 2, animation.value * 2),
              colors: [Colors.transparent, Colors.white.withValues(alpha: 0.1), AppColors.calmTeal.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.1), Colors.transparent],
              stops: const [0.3, 0.45, 0.5, 0.55, 0.7],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcOver,
          child: Container(color: Colors.transparent),
        );
      },
    );
  }
}

class _BlinkingStar extends StatefulWidget {
  final Color color;
  final double size;
  final Duration delay;
  final Duration duration;
  const _BlinkingStar({required this.color, required this.size, required this.delay, required this.duration});

  @override
  State<_BlinkingStar> createState() => _BlinkingStarState();
}

class _BlinkingStarState extends State<_BlinkingStar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    Future.delayed(widget.delay, () { if (mounted) _controller.repeat(reverse: true); });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = 0.3 + _controller.value * 0.7;
        return Opacity(
          opacity: v,
          child: Container(
            width: widget.size, height: widget.size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color,
              boxShadow: [BoxShadow(color: widget.color, blurRadius: widget.size * 2)]),
          ),
        );
      },
    );
  }
}

class _CMHIRingPainter extends CustomPainter {
  final double score;
  final double lightProgress;
  _CMHIRingPainter({required this.score, required this.lightProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 8.0;

    // Background ring
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF313442)..style = PaintingStyle.stroke..strokeWidth = strokeWidth);

    // Score arc
    final scorePercent = (score / 100).clamp(0.0, 1.0);
    final sweepAngle = scorePercent * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius), -pi / 2, sweepAngle,
      false, Paint()..color = AppColors.calmTeal..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round,
    );

    // Moving light
    final lightAngle = lightProgress * 2 * pi - pi / 2;
    final lightSweep = pi / 4;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius), lightAngle, lightSweep,
      false, Paint()..color = Colors.white.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CMHIRingPainter old) => old.score != score || old.lightProgress != lightProgress;
}
