import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/dashboard_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../scoring/providers/scoring_provider.dart';
import '../../mood/providers/mood_log_provider.dart';
import '../../scoring/models/scoring_model.dart';
import 'painters/floating_particles_painter.dart';
import 'painters/blob_painter.dart';
import 'widgets/hero_greeting_section.dart';
import 'widgets/cmhi_orb.dart';
import 'widgets/premium_metric_card.dart';
import 'widgets/quick_actions_section.dart';
import 'widgets/today_focus_card.dart';
import '../../../../core/utils/number_formatter.dart';
import 'widgets/weekly_report_card.dart';
import 'widgets/feature_carousel_section.dart';
import 'widgets/mood_trend_chart.dart';
import 'widgets/resume_assessment_card.dart';
import 'widgets/mindful_moment_card.dart';
import 'widgets/streak_card.dart';
import 'widgets/emergency_support_card.dart';
import 'widgets/mood_home_summary_card.dart';
import '../../habits/presentation/widgets/habit_home_summary_card.dart';
import 'widgets/expandable_fab.dart';
import 'widgets/discovery_section.dart';
import 'widgets/growth_progress_card.dart';
import 'widgets/sidebar_drawer.dart';
import 'widgets/quick_sleep_log_card.dart';
import '../../scoring/services/scoring_service.dart';
import '../../sleep/providers/sleep_log_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with TickerProviderStateMixin {
  late AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building DashboardScreen...');
    final authState = ref.watch(authProvider);
    final cmhiAsync = ref.watch(latestCMHIProvider);
    final todayFocusAsync = ref.watch(todayFocusProvider);
    
    // Explicitly watch for name changes to trigger rebuild when profile is updated
    final userName = authState.displayName ?? 'Friend';
    final userId = authState.userId;
    
    // Auto-refresh profile if name is missing but we have a session
    // Removed automatic refresh loop from build method to prevent infinite refreshes.
    // AuthNotifier already handles profile loading during session initialization.

    final bool isIdle = todayFocusAsync.value?.score != null && (todayFocusAsync.value!.score < 5.0);

    return Scaffold(
      backgroundColor: DashboardTheme.surfaceWhite,
      drawer: SidebarDrawer(),
      floatingActionButton: ExpandableFab(isVisible: isIdle),
      body: Stack(
        children: [
          // ─── Animated Background Layer (Blobs + Particles) ────
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _bgAnimController,
              builder: (context, _) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: BlobPainter(
                    animationValue: _bgAnimController.value,
                    riskLevel: cmhiAsync.value?.riskCategory,
                  ),
                );
              },
            ),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _bgAnimController,
              builder: (context, _) {
                Color particlesColor = DashboardTheme.primaryPurple;
                final risk = cmhiAsync.value?.riskCategory;
                if (risk == RiskCategory.high || risk == RiskCategory.severe || risk == RiskCategory.emergency) {
                  particlesColor = DashboardTheme.crisisRed;
                } else if (risk == RiskCategory.minimal || risk == RiskCategory.mild) {
                  particlesColor = DashboardTheme.moodGreen;
                }
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: FloatingParticlesPainter(
                    animationValue: _bgAnimController.value,
                    particleCount: 10,
                    baseColor: particlesColor,
                  ),
                );
              },
            ),
          ),

          // ─── Main Content ─────────────────────────────────────
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(latestCMHIProvider);
              ref.invalidate(moodTrendsProvider);
              ref.invalidate(moodStreakProvider);
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Hero Greeting Section
                SliverToBoxAdapter(
                  child: cmhiAsync.when(
                    data: (score) {
                      final streakAsync = ref.watch(moodStreakProvider);
                      return HeroGreetingSection(
                        userName: userName,
                        riskLevel: score?.riskCategory,
                        streakDays: streakAsync.value ?? 0,
                      );
                    },
                    loading: () => HeroGreetingSection(userName: userName),
                    error: (_, __) => HeroGreetingSection(userName: userName),
                  ),
                ),

                // 2. Feature Carousel (Explore MindNova)
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  sliver: SliverToBoxAdapter(
                    child: FeatureCarouselSection(),
                  ),
                ),

                // 3. State Dashboard (CMHI Orb)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: cmhiAsync.when(
                        data: (score) => CMHIOrb(
                          score: score?.cmhi ?? 0,
                          risk: score?.riskCategory ?? RiskCategory.minimal,
                          size: 180,
                        ),
                        loading: () => _buildOrbShimmer(),
                        error: (_, __) => const CMHIOrb(score: 0, risk: RiskCategory.minimal, size: 180),
                      ),
                    ),
                  ),
                ),

                // 4. Today Focus (Moved after Circle)
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverToBoxAdapter(
                    child: TodayFocusCard(),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMetricsSection(cmhiAsync),
                  ),
                ),

                // 5. Smart Shortcuts
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: cmhiAsync.when(
                      data: (score) => QuickActionsSection(riskLevel: score?.riskCategory),
                      loading: () => const QuickActionsSection(),
                      error: (_, __) => const QuickActionsSection(),
                    ),
                  ),
                ),

                // 6. Secondary Daily Cards
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverToBoxAdapter(child: HabitHomeSummaryCard()),
                ),

                // Quick Sleep Log
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverToBoxAdapter(child: QuickSleepLogCard()),
                ),

                // ─── Progress Section ──────────────────────────────────
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Text('Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverToBoxAdapter(child: GrowthProgressCard()),
                ),

                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverToBoxAdapter(child: WeeklyReportCard()),
                ),

                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                  sliver: SliverToBoxAdapter(child: MoodHomeSummaryCard()),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverToBoxAdapter(child: _buildTrendsSection()),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: ref.watch(moodStreakProvider).when(
                      data: (days) => StreakCard(streakDays: days),
                      loading: () => const StreakCard(streakDays: 0),
                      error: (_, __) => const StreakCard(streakDays: 0),
                    ),
                  ),
                ),

                // 11. Emergency Support (conditional)
                SliverToBoxAdapter(
                  child: cmhiAsync.when(
                    data: (score) {
                      if (score?.riskCategory == RiskCategory.moderate ||
                          score?.riskCategory == RiskCategory.high ||
                          score?.riskCategory == RiskCategory.severe ||
                          score?.riskCategory == RiskCategory.emergency) {
                        return const Padding(
                          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                          child: EmergencySupportCard(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),

                // 12. Bottom spacing for floating nav bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Metrics Section ──────────────────────────────────────
  Widget _buildMetricsSection(AsyncValue<CMHIScore?> cmhiAsync) {
    return cmhiAsync.when(
      data: (score) {
        final dims = score?.dimensions;
        return SizedBox(
          // Allow height to breathe to accommodate dynamic badge presence and glow bounds without clipping.
          // Enforced minimum sizing on inner structure to prevent 99k overflow inside slippers.
          height: 195,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            // Clip padding allows the children's drop shadow to render without getting chopped off by scroll boundary
            clipBehavior: Clip.none,
            children: [
              PremiumMetricCard(
                title: 'Cognitive',
                value: NumberFormatter.formatMetric(100.0 - (dims?.cognitive ?? 0.0)),
                unit: '%',
                progress: (100 - (dims?.cognitive ?? 0)) / 100,
                color: DashboardTheme.moodGreen,
                icon: Icons.psychology_rounded,
                trend: 'Clear',
                badge: 'Stable',
              ),
              const SizedBox(width: 12),
              PremiumMetricCard(
                title: 'Physiological',
                value: NumberFormatter.formatMetric(100.0 - (dims?.physiological ?? 0.0)),
                unit: '%',
                progress: (100 - (dims?.physiological ?? 0)) / 100,
                color: DashboardTheme.sleepBlue,
                icon: Icons.bedtime_rounded,
                trend: '-2%',
                isImproving: true,
                badge: 'Improving',
              ),
              const SizedBox(width: 12),
              PremiumMetricCard(
                title: 'Emotional',
                value: NumberFormatter.formatMetric(100.0 - (dims?.emotional ?? 0.0)),
                unit: '%',
                progress: (100 - (dims?.emotional ?? 0)) / 100,
                color: DashboardTheme.anxietyPink,
                icon: Icons.favorite_rounded,
                trend: '+5%',
                badge: 'Growing',
              ),
              const SizedBox(width: 12),
              Builder(
                builder: (context) {
                  final sleepAsync = ref.watch(sleepAverageProvider);
                  final sleepData = sleepAsync.value ?? {'avg': 0.0, 'trend': 0.0, 'badge': 'No data', 'progress': 0.0};
                  final avg = sleepData['avg'] as double;
                  final trend = sleepData['trend'] as double;
                  final badge = sleepData['badge'] as String;
                  final progress = sleepData['progress'] as double;
                  return PremiumMetricCard(
                    title: 'Sleep',
                    value: avg > 0 ? avg.toStringAsFixed(1) : '—',
                    unit: 'hrs',
                    progress: progress,
                    color: const Color(0xFF5C6BC0),
                    icon: Icons.nights_stay_rounded,
                    trend: trend != 0 ? '${trend > 0 ? "+" : ""}${trend.toStringAsFixed(1)}h' : '',
                    badge: badge,
                  );
                },
              ),
              const SizedBox(width: 12),
              PremiumMetricCard(
                title: 'Anxiety',
                value: (dims?.behavioral ?? 20).toInt().toString(),
                unit: '%',
                progress: (dims?.behavioral ?? 20) / 100,
                color: DashboardTheme.stressAmber,
                icon: Icons.monitor_heart_rounded,
                trend: '-3%',
                isImproving: true,
              ),
            ],
          ),
        );
      },
      loading: () => SizedBox(
        height: 195,
        child: Row(
          children: List.generate(
            3,
            (i) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
                ),
              ),
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ─── Trends Section ───────────────────────────────────────
  Widget _buildTrendsSection() {
    return ref.watch(moodTrendsProvider).when(
      data: (trends) => MoodTrendChart(trends: trends),
      loading: () => Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: DashboardTheme.primaryPurple.withValues(alpha: 0.3),
            strokeWidth: 2,
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ─── Orb Loading Shimmer ──────────────────────────────────
  Widget _buildOrbShimmer() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: DashboardTheme.primaryPurple.withValues(alpha: 0.05),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: DashboardTheme.primaryPurple.withValues(alpha: 0.3),
          strokeWidth: 2,
        ),
      ),
    );
  }
}
