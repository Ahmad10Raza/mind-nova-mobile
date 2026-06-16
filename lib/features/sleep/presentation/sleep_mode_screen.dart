import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/sleep_colors.dart';
import 'widgets/night_sky_background.dart';
import 'widgets/sleep_hero_card.dart';
import 'widgets/sleep_score_card.dart';
import 'widgets/sleep_debt_card.dart';
import 'widgets/sleep_emergency_card.dart';
import '../providers/sleep_log_provider.dart';

class SleepModeScreen extends ConsumerStatefulWidget {
  const SleepModeScreen({super.key});

  @override
  ConsumerState<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends ConsumerState<SleepModeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SleepColors.midnightBlack,
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          return NightSkyBackground(
            animationValue: _bgController.value,
            child: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ─── App Bar ─────────────────────────────────
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    pinned: false,
                    floating: true,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: SleepColors.textSecondary),
                      onPressed: () => context.pop(),
                    ),
                    title: Text(
                      'Sleep Mode',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: SleepColors.textPrimary,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings_rounded, color: SleepColors.textMuted, size: 22),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  // ─── 1. Hero Section ─────────────────────────
                  SliverToBoxAdapter(
                    child: SleepHeroCard(animationValue: _bgController.value),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // ─── 2. Start Night Routine CTA ──────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _buildRoutineCTA(),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // ─── 3. Sleep Score Card ─────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: ref.watch(sleepMetricsProvider).when(
                        data: (metrics) => SleepScoreCard(
                          score: metrics['score'],
                          quality: metrics['quality'],
                          consistency: metrics['consistency'],
                          avgHours: metrics['avgHours'],
                        ),
                        loading: () => const Center(child: CircularProgressIndicator(color: SleepColors.moonGold)),
                        error: (e, _) => const SleepScoreCard(), // Fallback to defaults on error
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // ─── 4. Sleep Debt Card ─────────────────────
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: SleepDebtCard(),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // ─── 5. Feature Grid ────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _buildFeatureGrid(context),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // ─── 6. Quick Stats Row ─────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: ref.watch(sleepMetricsProvider).when(
                        data: (metrics) => Container(
                          padding: const EdgeInsets.all(20),
                          decoration: SleepColors.glassCard,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStat('Recovery', '${(metrics['score'] * 100).toInt()}%', SleepColors.successGreen),
                              _buildStatDivider(),
                              _buildStat('Stress', metrics['stressLevel'], SleepColors.calmTeal),
                              _buildStatDivider(),
                              _buildStat('Streak', '${metrics['streak']} days', SleepColors.moonGold),
                            ],
                          ),
                        ),
                        loading: () => const SizedBox(height: 80),
                        error: (e, _) => _buildQuickStats(), // Fallback
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // ─── 7. Sleep Emergency Card ────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: SleepEmergencyCard(
                        onBreathingTap: () => context.push('/sleep/breathing'),
                        onChatTap: () => context.go('/chat'),
                        onFullTap: () => context.push('/sleep/emergency'),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // ─── 8. Smart Alarm (Coming Soon) ───────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _buildComingSoonCard(),
                    ),
                  ),

                  // Bottom spacing
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoutineCTA() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            context.push('/sleep/routine');
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: SleepColors.ctaGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C4DFF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bedtime_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Start Night Routine',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 12,
                  child: IconButton(
                    icon: const Icon(Icons.tune_rounded, color: Colors.white70, size: 20),
                    onPressed: () {
                      context.push('/sleep/ritual-builder');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sleep Tools',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: SleepColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildFeatureTile(
              'Moon Breathing',
              Icons.air_rounded,
              SleepColors.calmTeal,
              () => context.push('/sleep/breathing'),
            ),
            const SizedBox(width: 12),
            _buildFeatureTile(
              'Sleep Tracking',
              Icons.bar_chart_rounded,
              SleepColors.softBlue,
              () => context.push('/sleep/tracking'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildFeatureTile(
              'Sounds',
              Icons.music_note_rounded,
              SleepColors.lavenderGlow,
              () => context.push('/sleep/sounds'),
            ),
            const SizedBox(width: 12),
            _buildFeatureTile(
              'Stories',
              Icons.auto_stories_rounded,
              SleepColors.moonGold,
              () {}, // Phase 2
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureTile(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: SleepColors.glassCardWithGlow(color),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: SleepColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SleepColors.glassCard,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Recovery', '72%', SleepColors.successGreen),
          _buildStatDivider(),
          _buildStat('Stress', 'Low', SleepColors.calmTeal),
          _buildStatDivider(),
          _buildStat('Streak', '5 days', SleepColors.moonGold),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: SleepColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 30, width: 1, color: SleepColors.glassBorder);
  }

  Widget _buildComingSoonCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(SleepColors.cardRadius),
        border: Border.all(color: SleepColors.textMuted.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SleepColors.textMuted.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.alarm_rounded, color: SleepColors.textMuted, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Alarm',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: SleepColors.textMuted,
                  ),
                ),
                Text(
                  'Wake up gently during light sleep — Coming Soon',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: SleepColors.textMuted.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
