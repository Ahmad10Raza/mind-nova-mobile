import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/dashboard_theme.dart';
import '../../../core/theme/tools_theme.dart';
import 'widgets/tool_hero_card.dart';
import 'widgets/tool_tile_card.dart';
import 'widgets/tool_full_card.dart';
import 'widgets/tool_compact_tile.dart';
import '../../ai_reports/providers/weekly_report_provider.dart';
import '../../dashboard/presentation/widgets/sidebar_drawer.dart';
import 'widgets/tool_search_delegate.dart';
import '../../safety/providers/safety_provider.dart';
import '../../safety/models/crisis_model.dart';

class ToolsScreen extends ConsumerStatefulWidget {
  const ToolsScreen({super.key});

  @override
  ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Daily',
    'AI',
    'Assess',
    'Mindful',
    'Crisis',
    'Sleep',
    'Community',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      drawer: SidebarDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── App Bar ───────────────────────────────────────
          SliverAppBar(
            expandedHeight: 90,
            floating: true,
            pinned: false,
            backgroundColor: const Color(0xFFFBFBFE),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Wellness Toolkit',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: DashboardTheme.textPrimary,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 12),
            ),
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded, color: DashboardTheme.textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded,
                    color: DashboardTheme.textSecondary),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: ToolSearchDelegate(),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // ─── Category Filter Chips ─────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 0),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? DashboardTheme.primaryGradient
                              : null,
                          color: isSelected ? null : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(100),
                          border: isSelected
                              ? null
                              : Border.all(color: Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : DashboardTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ─── Hero Card ─────────────────────────────────────
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(child: ToolHeroCard()),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ─── Favorites Section ─────────────────────────────
          if (_selectedCategory == 'All') ...[
            _buildSectionHeader('♡ Your Favorites'),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    ToolCompactTile(
                      title: 'Mood Log',
                      icon: Icons.emoji_emotions_rounded,
                      color: const Color(0xFF29B6F6),
                      onTap: () => context.push('/mood-checkin'),
                    ),
                    const SizedBox(width: 10),
                    ToolCompactTile(
                      title: 'Breathing',
                      icon: Icons.air_rounded,
                      color: const Color(0xFF26A69A),
                      onTap: () => context.push('/breathing'),
                    ),
                    const SizedBox(width: 10),
                    ToolCompactTile(
                      title: 'AI Chat',
                      icon: Icons.auto_awesome_rounded,
                      color: DashboardTheme.primaryPurple,
                      onTap: () => context.go('/chat'),
                    ),
                    const SizedBox(width: 10),
                    ToolCompactTile(
                      title: 'Journal',
                      icon: Icons.edit_note_rounded,
                      color: const Color(0xFF66BB6A),
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    ToolCompactTile(
                      title: 'Groups',
                      icon: Icons.groups_rounded,
                      color: const Color(0xFF9575CD),
                      onTap: () => context.push('/groups'),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
          ],

          // ─── 1. Daily Wellness Section ─────────────────────
          if (_shouldShow('Daily')) ...[
            ..._buildSectionWithBg(
              'Daily Wellness',
              ToolsTheme.dailyBgTint,
              children: [
                _buildTileGrid([
                  ToolTileCard(
                    title: 'Mood Log',
                    subtitle: 'How are you today?',
                    icon: Icons.emoji_emotions_rounded,
                    gradient: ToolsTheme.moodGradient,
                    onTap: () => context.push('/mood-checkin'),
                    progressBadge: 'Logged 4/7 days',
                  ),
                  ToolTileCard(
                    title: 'Gratitude',
                    subtitle: '3 things today',
                    icon: Icons.favorite_rounded,
                    gradient: ToolsTheme.gratitudeGradient,
                    onTap: () => context.push('/gratitude'),
                    progressBadge: '3 day streak',
                  ),
                  ToolTileCard(
                    title: 'Journal',
                    subtitle: 'Express yourself',
                    icon: Icons.edit_note_rounded,
                    gradient: ToolsTheme.journalGradient,
                    onTap: () => context.push('/journal'),
                    progressBadge: '2 active drafts',
                  ),
                  ToolTileCard(
                    title: 'Habit Tracker',
                    subtitle: 'Build consistency',
                    icon: Icons.checklist_rounded,
                    gradient: ToolsTheme.habitGradient,
                    onTap: () => context.push('/habits'),
                    progressBadge: '3 active rituals',
                  ),
                ]),
                const SizedBox(height: 12),
                // Horizontal scroll for secondary daily tools
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      ToolCompactTile(
                        title: 'Reflection',
                        icon: Icons.lightbulb_rounded,
                        color: const Color(0xFF9575CD),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // ─── 2. Nova AI Hub ────────────────────────────
          if (_shouldShow('AI')) ...[
            ..._buildSectionWithBg(
              'MindNova Intelligence',
              ToolsTheme.aiBgTint,
              children: [
                ToolFullCard(
                  title: 'AI Companion',
                  subtitle: 'Ask anything about your mental health.',
                  icon: Icons.auto_awesome_rounded,
                  gradient: ToolsTheme.aiChatGradient,
                  onTap: () => context.go('/chat'),
                  ctaLabel: 'Start Chat',
                ),
                const SizedBox(height: 12),
                // MindNova Intelligence Hub — merged card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: ToolsTheme.intelligenceGradient,
                    borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: DashboardTheme.primaryPurple.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.hub_rounded,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nova AI Hub',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Predictions · Insights · Forecasts',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildHubChip('Risk Score', Icons.shield_rounded),
                          const SizedBox(width: 8),
                          _buildHubChip('Forecast', Icons.trending_up_rounded),
                          const SizedBox(width: 8),
                          _buildHubChip('CMHI', Icons.analytics_rounded),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => context.push('/ai-hub'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Text(
                            'Open Intelligence Hub',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildTileGrid([
                  ToolTileCard(
                    title: 'AI Prediction',
                    subtitle: 'Risk forecast',
                    icon: Icons.batch_prediction_rounded,
                    gradient: ToolsTheme.aiPredictionGradient,
                    onTap: () => context.push('/ai-hub'),
                  ),
                  ToolTileCard(
                    title: 'Weekly Insight',
                    subtitle: 'Your AI report',
                    icon: Icons.insights_rounded,
                    gradient: ToolsTheme.weeklyInsightGradient,
                    onTap: () async {
                      final report = await ref.read(weeklyReportProvider.future);
                      if (report != null && context.mounted) {
                        context.push('/weekly-insight', extra: report);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Weekly report not available yet.')),
                        );
                      }
                    },
                  ),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      ToolCompactTile(
                        title: 'CMHI Score',
                        icon: Icons.analytics_rounded,
                        color: const Color(0xFF7B1FA2),
                        onTap: () => context.push('/cmhi-info'),
                      ),
                      const SizedBox(width: 10),
                      ToolCompactTile(
                        title: 'Smart Recs',
                        icon: Icons.recommend_rounded,
                        color: const Color(0xFFBA68C8),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // ─── 3. Assessments Section ────────────────────────
          if (_shouldShow('Assess')) ...[
            ..._buildSectionWithBg(
              'Clinical Assessments',
              ToolsTheme.assessBgTint,
              children: [
                _buildTileGrid([
                  ToolTileCard(
                    title: 'Depression',
                    subtitle: 'PHQ-9 Scale',
                    icon: Icons.psychology_rounded,
                    gradient: ToolsTheme.depressionGradient,
                    onTap: () => context.push('/assessment/depression'),
                  ),
                  ToolTileCard(
                    title: 'Anxiety',
                    subtitle: 'GAD-7 Scale',
                    icon: Icons.monitor_heart_rounded,
                    gradient: ToolsTheme.anxietyGradient,
                    onTap: () => context.push('/assessment/anxiety'),
                  ),
                  ToolTileCard(
                    title: 'Stress',
                    subtitle: 'PSS Scale',
                    icon: Icons.whatshot_rounded,
                    gradient: ToolsTheme.stressGradient,
                    onTap: () => context.push('/assessment/stress'),
                  ),
                  ToolTileCard(
                    title: 'PTSD',
                    subtitle: 'PCL-5 Scale',
                    icon: Icons.security_rounded,
                    gradient: ToolsTheme.ptsdGradient,
                    onTap: () => context.push('/assessment/ptsd'),
                  ),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      ToolCompactTile(
                        title: 'Panic',
                        icon: Icons.flash_on_rounded,
                        color: const Color(0xFFE53935),
                        onTap: () => context.push('/assessment/panic'),
                      ),
                      const SizedBox(width: 10),
                      ToolCompactTile(
                        title: 'Burnout',
                        icon: Icons.local_fire_department_rounded,
                        color: const Color(0xFF795548),
                        onTap: () => context.push('/assessment/burnout'),
                      ),
                      const SizedBox(width: 10),
                      ToolCompactTile(
                        title: 'Adaptive',
                        icon: Icons.route_rounded,
                        color: const Color(0xFFF57C00),
                        onTap: () =>
                            context.push('/adaptive-assessment/clinical_main'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // ─── 4. Mindfulness Section ────────────────────────
          if (_shouldShow('Mindful')) ...[
            ..._buildSectionWithBg(
              'Mindfulness & Calm',
              ToolsTheme.mindfulBgTint,
              children: [
                ToolFullCard(
                  title: 'Breathing Exercises',
                  subtitle: '6 guided techniques available.',
                  icon: Icons.air_rounded,
                  gradient: ToolsTheme.breathingGradient,
                  onTap: () => context.push('/breathing'),
                  ctaLabel: 'Start Breathing',
                ),
                const SizedBox(height: 12),
                _buildTileGrid([
                  ToolTileCard(
                    title: 'Grounding',
                    subtitle: 'Reconnect',
                    icon: Icons.landscape_rounded,
                    gradient: ToolsTheme.groundingGradient,
                    onTap: () => context.push('/grounding'),
                  ),
                  ToolTileCard(
                    title: 'Meditation',
                    subtitle: 'Find stillness',
                    icon: Icons.self_improvement_rounded,
                    gradient: ToolsTheme.meditationGradient,
                    onTap: () => context.push('/meditation'),
                    progressBadge: '12 min today',
                  ),
                  ToolTileCard(
                    title: 'Sleep Mode',
                    subtitle: 'Wind down',
                    icon: Icons.dark_mode_rounded,
                    gradient: ToolsTheme.sleepModeGradient,
                    onTap: () => context.push('/sleep'),
                  ),
                  ToolTileCard(
                    title: 'Audio Sanctuary',
                    subtitle: 'Relax & focus',
                    icon: Icons.headphones_rounded,
                    gradient: ToolsTheme.musicGradient,
                    onTap: () => context.push('/audio'),
                  ),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      ToolCompactTile(
                        title: 'Focus Timer',
                        icon: Icons.timer_rounded,
                        color: const Color(0xFF2196F3),
                        onTap: () => context.push('/focus'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // ─── 5. Crisis Support Section ─────────────────────
          if (_shouldShow('Crisis')) ...[
            ..._buildSectionWithBg(
              'Crisis Support',
              ToolsTheme.crisisBgTint,
              children: [
                ToolFullCard(
                  title: 'Immediate Support',
                  subtitle: 'You\'re not alone. Help is one tap away.',
                  icon: Icons.emergency_rounded,
                  gradient: ToolsTheme.emergencyGradient,
                  onTap: () => _showImmediateSupportSheet(context),
                  ctaLabel: 'Get Help Now',
                ),
                const SizedBox(height: 12),
                _buildTileGrid([
                  ToolTileCard(
                    title: 'Support Plan',
                    subtitle: 'Your safety plan',
                    icon: Icons.assignment_rounded,
                    gradient: ToolsTheme.crisisPlanGradient,
                    onTap: () => context.push('/support-plan'),
                  ),
                  ToolTileCard(
                    title: 'Safe Contacts',
                    subtitle: 'People who care',
                    icon: Icons.contacts_rounded,
                    gradient: ToolsTheme.safeContactsGradient,
                    onTap: () => context.push('/safe-contacts'),
                  ),
                  ToolTileCard(
                    title: 'Quick Help',
                    subtitle: 'Instant support',
                    icon: Icons.sos_rounded,
                    gradient: ToolsTheme.sosGradient,
                    onTap: () => context.push('/sos-mode'),
                  ),
                  ToolTileCard(
                    title: 'Talk to Expert',
                    subtitle: 'Private & Trusted',
                    icon: Icons.psychology_alt_rounded,
                    gradient: ToolsTheme.therapistGradient,
                    onTap: () => context.push('/therapist/home'),
                  ),
                ]),
              ],
            ),
          ],

          // ─── 6. Sleep & Recovery Section ───────────────────
          if (_shouldShow('Sleep')) ...[
            ..._buildSectionWithBg(
              'Sleep & Recovery',
              ToolsTheme.sleepBgTint,
              children: [
                ToolFullCard(
                  title: 'Sleep Tracker',
                  subtitle: 'Monitor your sleep patterns and quality.',
                  icon: Icons.bedtime_rounded,
                  gradient: ToolsTheme.sleepTrackerGradient,
                  onTap: () => context.push('/sleep'),
                  progressBadge: '6.5h avg',
                ),
                const SizedBox(height: 12),
                ToolFullCard(
                  title: 'Recovery',
                  subtitle: 'MindNova Recovery Engine',
                  icon: Icons.healing_rounded,
                  gradient: ToolsTheme.recoveryGradient,
                  onTap: () => context.push('/recovery-engine'),
                ),
              ],
            ),
          ],

          // ─── 7. Community Section ──────────────────────────
          if (_shouldShow('Community')) ...[
            ..._buildSectionWithBg(
              'Community & Support',
              ToolsTheme.communityBgTint,
              children: [
                ToolFullCard(
                  title: 'Community Feed',
                  subtitle: 'Connect with people who understand.',
                  icon: Icons.forum_rounded,
                  gradient: ToolsTheme.communityGradient,
                  onTap: () => context.push('/community/feed'),
                  ctaLabel: 'Join Now',
                ),
                const SizedBox(height: 12),
                _buildTileGrid([
                  ToolTileCard(
                    title: 'Live Circles',
                    subtitle: 'Join guided support rooms',
                    icon: Icons.headphones_rounded,
                    gradient: ToolsTheme.sessionsGradient,
                    onTap: () => context.push('/community/live_circles'),
                  ),
                  ToolTileCard(
                    title: 'Groups',
                    subtitle: 'Support circles',
                    icon: Icons.groups_rounded,
                    gradient: ToolsTheme.supportGroupGradient,
                    onTap: () => context.push('/groups'),
                  ),
                  ToolTileCard(
                    title: 'Challenges',
                    subtitle: 'Build healthy habits',
                    icon: Icons.emoji_events_rounded,
                    gradient: ToolsTheme.challengesGradient,
                    onTap: () => context.push('/challenges'),
                  ),
                ]),
              ],
            ),
          ],

          // ─── Explore More Section ──────────────────────────
          if (_selectedCategory == 'All') ...[
            _buildSectionHeader('🔮 Coming Soon'),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: DashboardTheme.primaryPurple.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.science_rounded,
                            color: DashboardTheme.primaryPurple, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'More Tools Coming',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: DashboardTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'CBT exercises, guided visualizations, and more.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: DashboardTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Bottom spacing for nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────

  bool _shouldShow(String category) {
    return _selectedCategory == 'All' || _selectedCategory == category;
  }

  Widget _buildTileGrid(List<ToolTileCard> cards) {
    final List<Widget> rows = [];
    for (int i = 0; i < cards.length; i += 2) {
      rows.add(Row(
        children: [
          Expanded(child: cards[i]),
          const SizedBox(width: 12),
          if (i + 1 < cards.length)
            Expanded(child: cards[i + 1])
          else
            const Expanded(child: SizedBox()),
        ],
      ));
      if (i + 2 < cards.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }

  SliverToBoxAdapter _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: DashboardTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSectionWithBg(
    String title,
    Color bgTint, {
    required List<Widget> children,
  }) {
    return [
      _buildSectionHeader(title),
      SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          decoration: BoxDecoration(
            color: bgTint,
            borderRadius: BorderRadius.circular(DashboardTheme.radiusXL),
          ),
          child: Column(children: children),
        ),
      ),
    ];
  }

  Widget _buildHubChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Immediate Support Bottom Sheet ─────────────────────
  void _showImmediateSupportSheet(BuildContext ctx) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: ToolsTheme.emergencyGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.health_and_safety_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Immediate Support',
                          style: GoogleFonts.outfit(
                            fontSize: 20, fontWeight: FontWeight.w800,
                            color: Colors.white,
                          )),
                        Text('You\'re safe. Pick what feels right.',
                          style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.white54,
                          )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Quick actions grid
              Row(
                children: [
                  _sheetAction(
                    icon: Icons.call_rounded,
                    label: 'Call 102',
                    color: const Color(0xFF43A047),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      launchUrl(Uri.parse('tel:102'));
                    },
                  ),
                  const SizedBox(width: 12),
                  _sheetAction(
                    icon: Icons.textsms_rounded,
                    label: 'Text Line',
                    color: const Color(0xFF1E88E5),
                    onTap: () {
                      _showTextLinePicker(ctx, ref, sheetCtx);
                    },
                  ),
                  const SizedBox(width: 12),
                  _sheetAction(
                    icon: Icons.sos_rounded,
                    label: 'SOS Mode',
                    color: ToolsTheme.crisisRed,
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      ctx.push('/sos-mode');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _sheetAction(
                    icon: Icons.assignment_rounded,
                    label: 'My Plan',
                    color: const Color(0xFFFF8A65),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      ctx.push('/support-plan');
                    },
                  ),
                  const SizedBox(width: 12),
                  _sheetAction(
                    icon: Icons.air_rounded,
                    label: 'Breathe',
                    color: const Color(0xFF26A69A),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      ctx.push('/breathing');
                    },
                  ),
                  const SizedBox(width: 12),
                  _sheetAction(
                    icon: Icons.contacts_rounded,
                    label: 'Contacts',
                    color: const Color(0xFFFFAB91),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      ctx.push('/safe-contacts');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Reassurance
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_rounded,
                        color: Color(0xFFEF9A9A), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'It takes courage to seek help. We\'re proud of you.',
                        style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.white60, height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 8),
              Text(label,
                style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color,
                )),
            ],
          ),
        ),
      ),
    );
  }

  void _showTextLinePicker(BuildContext ctx, WidgetRef ref, BuildContext sheetCtx) {
    final safetyState = ref.read(safetyProvider);
    final contacts = safetyState.smsContacts;

    // Close the previous sheet first to avoid overlapping/stacking issues
    Navigator.pop(sheetCtx);

    showModalBottomSheet(
      context: ctx,
      useRootNavigator: true, // Ensures it appears ABOVE the navigation bar
      backgroundColor: const Color(0xFF1E1E26),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reach Out via Text',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select someone you trust to message.',
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            // Professional Crisis Text Line
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.support_agent_rounded, color: Color(0xFF1E88E5), size: 20),
              ),
              title: Text('Crisis Text Line',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
              subtitle: Text('Text HOME to 741741',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                launchUrl(Uri.parse('sms:741741?body=${Uri.encodeComponent("HOME")}'));
              },
            ),
            
            if (contacts.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: Colors.white12),
              ),
              ...contacts.map((c) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white70, size: 20),
                ),
                title: Text(c.name,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text(c.relation ?? 'Safe Contact',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  // Using sms: protocol
                  launchUrl(Uri.parse('sms:${c.phoneNumber}'));
                },
              )),
            ],
            
            if (contacts.isEmpty) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'No safe contacts found with SMS enabled.',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
