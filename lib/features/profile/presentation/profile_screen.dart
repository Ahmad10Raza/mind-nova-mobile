import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_hub_provider.dart';
import '../../assessment/providers/assessment_history_provider.dart';
import '../../assessment/models/assessment_model.dart';
import '../../scoring/models/scoring_model.dart';
import '../../challenges/providers/challenge_provider.dart';
import '../../challenges/models/challenge_model.dart';
import 'edit_profile_sheet.dart';
import '../../auth/presentation/guest_upgrade_sheet.dart';
import '../../auth/services/profile_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/design/colors/app_colors.dart';
import '../../../core/design/typography/app_typography.dart';
import '../../../core/design/surfaces/app_surfaces.dart';
import '../../../core/design/radius/app_radius.dart';
import '../../../core/design/gradients/app_gradients.dart';
import 'package:shared_preferences/shared_preferences.dart';

final voiceRetentionProvider = NotifierProvider<VoiceRetentionNotifier, bool>(() {
  return VoiceRetentionNotifier();
});

class VoiceRetentionNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadSetting();
    return false;
  }

  Future<void> _loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('keep_voice_recordings') ?? false;
  }

  Future<void> toggle(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keep_voice_recordings', value);
  }
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final historyAsync = ref.watch(assessmentHistoryProvider);
    final hubState = ref.watch(profileHubProvider);
    final activeChallengeAsync = ref.watch(activeChallengeProvider);

    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Settings App Bar ──────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.transparent, // Let hero background show through
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profile Hub',
                        style: AppTypography.heroXL.copyWith(
                          fontSize: 22,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      _buildAppBarAction(
                        icon: Icons.settings_outlined,
                        onTap: () => _showSettingsMenu(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Identity Hero Section ────────────────
          SliverToBoxAdapter(
            child: _buildHeroSection(authState, profileAsync, hubState, context),
          ),

          // ─── Guest Conversion Banner ─────────
          if (authState.status == AuthStatus.anonymous)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 24),
              sliver: SliverToBoxAdapter(
                child: _buildGuestBanner(context),
              ),
            ),

          // ─── User Basics Section (New) ───────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: _buildUserBasics(authState, profileAsync),
            ),
          ),

          // ─── Growth Score Card ──────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            sliver: SliverToBoxAdapter(
              child: _buildGrowthScoreCard(hubState),
            ),
          ),

          // ─── Life Dashboard ────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: _buildLifeDashboard(hubState),
            ),
          ),

          // ─── Weekly AI Insights ─────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            sliver: SliverToBoxAdapter(
              child: _buildWeeklyInsights(hubState),
            ),
          ),

          // ─── Community & Therapy ─────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: _buildCommunitySection(hubState),
            ),
          ),

          // ─── Active Challenge ───────────────
          activeChallengeAsync.when(
            data: (challenge) => challenge != null 
              ? SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  sliver: SliverToBoxAdapter(
                    child: _buildActiveChallengeCard(challenge),
                  ),
                )
              : const SliverToBoxAdapter(child: SizedBox.shrink()),
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // ─── Tool Usage Insights ─────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: _buildToolUsageInsights(hubState),
            ),
          ),

          // ─── Your Journey Timeline ────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Journey',
                        style: AppTypography.headingLarge.copyWith(
                          fontSize: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/profile/history'),
                        child: Text(
                          'View All',
                          style: AppTypography.button.copyWith(
                            fontSize: 14,
                            color: AppColors.novaPurpleLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  historyAsync.when(
                    data: (history) => _buildRecentActivityBox(context, history),
                    loading: () => _buildSkeletonActivity(),
                    error: (e, _) => _buildErrorState('We couldn\'t load your timeline.', () => ref.refresh(assessmentHistoryProvider)),
                  ),
                ],
              ),
            ),
          ),

          // ─── Logout Section ──────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100), // Increased padding for bottom nav
            sliver: SliverToBoxAdapter(
              child: _buildLogoutButton(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  // --- Hero Section ---
  Widget _buildHeroSection(AuthState authState, AsyncValue profileAsync, ProfileHubState hubState, BuildContext context) {
    if (hubState.isLoading) {
      return _buildSkeletonHero();
    }

    final fullName = profileAsync.whenOrNull(data: (p) => '${p?.firstName ?? ''} ${p?.lastName ?? ''}'.trim()) 
                     ?? authState.displayName 
                     ?? 'MindNova User';
                     
    final finalName = fullName.isNotEmpty ? fullName : 'MindNova User';

    Color avatarBorderColor = AppColors.novaPurpleLight;
    if (hubState.moodTrend == 'Declining') avatarBorderColor = AppColors.emotionalWarning;
    if (hubState.moodTrend == 'Improving') avatarBorderColor = AppColors.successSoft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      // Removed light gradient, letting AppSurfaces.primary show through
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: avatarBorderColor.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 8))],
                  border: Border.all(color: avatarBorderColor, width: 4),
                ),
                child: ClipOval(child: _buildAvatar(finalName, authState.avatarUrl)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => profileAsync.whenData((p) => p != null ? _showEditProfile(context, p) : null),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.novaPurple, shape: BoxShape.circle),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (authState.status == AuthStatus.anonymous)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.warmSupport.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
              child: Text('GUEST MODE', style: AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.warmSupport)),
            ),
          Text(
            finalName,
            style: AppTypography.heroXL.copyWith(fontSize: 26, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              hubState.identityLine,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(fontSize: 14, color: AppColors.novaPurpleLight, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPillIndicator(
                icon: Icons.local_fire_department_rounded,
                color: AppColors.warmSupport,
                label: '${(hubState.habitConsistency * 100).toInt()}% Consistency',
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => profileAsync.whenData((p) => p != null ? _showEditProfile(context, p) : null),
                child: _buildPillIndicator(
                  icon: Icons.person_outline_rounded,
                  color: AppColors.novaPurpleLight,
                  label: 'Edit Profile',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillIndicator({required IconData icon, required Color color, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.backgroundTertiary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  // --- User Basics ---
  Widget _buildUserBasics(AuthState authState, AsyncValue profileAsync) {
    final email = authState.email ?? 'Not provided';
    final memberSince = 'Since ${DateFormat('MMM yyyy').format(DateTime.now().subtract(const Duration(days: 30)))}'; // Placeholder

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppSurfaces.glassSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.backgroundTertiary),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildBasicItem('Email Address', email, Icons.email_outlined),
          ),
          Container(width: 1, height: 32, color: AppColors.backgroundTertiary),
          Expanded(
            child: _buildBasicItem('Membership', memberSince, Icons.calendar_today_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(label, style: AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.body.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // --- Growth Score Card ---
  Widget _buildGrowthScoreCard(ProfileHubState hubState) {
    if (hubState.isLoading) return _buildSkeletonGrowth();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.nova,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Growth Score', style: AppTypography.headingMedium.copyWith(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                const SizedBox(height: 4),
                Text(hubState.growthScore.toInt().toString(), style: AppTypography.heroXL.copyWith(fontSize: 48, color: Colors.white)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(100)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(hubState.growthDelta >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('${hubState.growthDelta > 0 ? "+" : ""}${hubState.growthDelta}% this week', style: AppTypography.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100, height: 100,
            child: CustomPaint(painter: _GrowthGaugePainter(hubState.growthScore / 100), child: Center(child: Icon(Icons.auto_graph_rounded, color: Colors.white.withOpacity(0.5), size: 30))),
          ),
        ],
      ),
    );
  }

  // --- Life Dashboard ---
  Widget _buildLifeDashboard(ProfileHubState hubState) {
    if (hubState.isLoading) return _buildSkeletonDashboard();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Life Dashboard', style: AppTypography.headingLarge.copyWith(fontSize: 18, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppSurfaces.glassSoft, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.backgroundTertiary)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Clinical Index', style: AppTypography.caption.copyWith(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(hubState.latestCMHI?.cmhi.toStringAsFixed(1) ?? '--', style: AppTypography.heroXL.copyWith(fontSize: 32, color: AppColors.textPrimary)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: _getRiskColor(hubState.latestCMHI?.riskCategory).withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: _getRiskColor(hubState.latestCMHI?.riskCategory).withOpacity(0.3))),
                    child: Row(
                      children: [
                        Icon(Icons.shield_rounded, size: 16, color: _getRiskColor(hubState.latestCMHI?.riskCategory)),
                        const SizedBox(width: 6),
                        Text(hubState.latestCMHI?.riskCategory.name.toUpperCase() ?? 'PENDING', style: AppTypography.caption.copyWith(fontSize: 12, fontWeight: FontWeight.w800, color: _getRiskColor(hubState.latestCMHI?.riskCategory))),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: AppColors.backgroundTertiary)),
              Row(
                children: [
                  Expanded(child: _buildDashboardMetric(title: 'Mood Trend', value: hubState.moodTrend, icon: _getMoodIcon(hubState.moodTrend), color: _getMoodColor(hubState.moodTrend))),
                  Container(width: 1, height: 40, color: AppColors.backgroundTertiary),
                  Expanded(child: _buildDashboardMetric(title: 'Recovery', value: '${hubState.recoveryScore.toInt()}/100', icon: Icons.battery_charging_full_rounded, color: AppColors.calmTeal)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardMetric({required String title, required String value, required IconData icon, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.3))), child: Icon(icon, size: 16, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)), Text(value, style: AppTypography.body.copyWith(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)])),
        ],
      ),
    );
  }

  // --- Weekly AI Insights ---
  Widget _buildWeeklyInsights(ProfileHubState hubState) {
    if (hubState.isLoading) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppSurfaces.glassSoft, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.novaPurple.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.auto_awesome_rounded, color: AppColors.novaPurpleLight, size: 20), const SizedBox(width: 10), Text('Weekly AI Insight', style: AppTypography.headingMedium.copyWith(fontSize: 16, color: AppColors.novaPurpleLight))]),
          const SizedBox(height: 12),
          Text(hubState.weeklyInsightSummary ?? "Keep logging your mood to unlock deeper insights into your growth journey.", style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.textPrimary, height: 1.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Row(children: [_buildInsightCTA('Full Report', Icons.bar_chart_rounded, () => context.push('/profile/reports')), const SizedBox(width: 12), _buildInsightCTA('Talk to AI', Icons.chat_bubble_outline_rounded, () => context.go('/chat'))]),
        ],
      ),
    );
  }

  Widget _buildInsightCTA(String label, IconData icon, VoidCallback onTap) {
    return Expanded(child: GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: AppColors.novaPurple.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.novaPurple.withOpacity(0.3))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 14, color: AppColors.novaPurpleLight), const SizedBox(width: 8), Text(label, style: AppTypography.button.copyWith(fontSize: 12, color: AppColors.novaPurpleLight))]))));
  }

  // --- Community & Therapy Section ---
  Widget _buildCommunitySection(ProfileHubState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Support & Connection', style: AppTypography.headingLarge.copyWith(fontSize: 18, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildCompactCard(
              title: 'Active Groups', 
              value: '${state.activeGroupsCount} Groups', 
              icon: Icons.group_rounded, 
              color: AppColors.recoveryBlue
            )),
            const SizedBox(width: 16),
            Expanded(child: _buildCompactCard(
              title: 'Next Session', 
              value: state.nextSessionDate != null 
                  ? DateFormat('EEE, h a').format(state.nextSessionDate!) 
                  : 'No session', 
              icon: Icons.video_call_rounded, 
              color: AppColors.warmSupport
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppSurfaces.glassSoft, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.backgroundTertiary)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.caption.copyWith(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          Text(value, style: AppTypography.body.copyWith(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  // --- Active Challenge Card ---
  Widget _buildActiveChallengeCard(UserChallenge challenge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Active Challenge', style: AppTypography.headingLarge.copyWith(fontSize: 18, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.novaPurpleLight.withOpacity(0.3))),
          child: Column(
            children: [
              Row(
                children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.novaPurple.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.workspace_premium_rounded, color: AppColors.warmSupport, size: 24)),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(challenge.challenge.title, style: AppTypography.headingMedium.copyWith(fontSize: 16, color: Colors.white)), Text('Day ${challenge.currentDay} of ${challenge.challenge.durationDays}', style: AppTypography.caption.copyWith(fontSize: 12, color: AppColors.textSecondary))]))
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: challenge.completionRate, backgroundColor: AppColors.backgroundSecondary, valueColor: const AlwaysStoppedAnimation(AppColors.successSoft), minHeight: 8)),
            ],
          ),
        ),
      ],
    );
  }

  // --- Tool Usage Insights ---
  Widget _buildToolUsageInsights(ProfileHubState hubState) {
    if (hubState.isLoading) return _buildSkeletonUsage();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tool Usage', style: AppTypography.headingLarge.copyWith(fontSize: 18, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildUsagePill('Most Used', 'AI Chat', Icons.auto_awesome_rounded, AppColors.novaPurple),
              _buildUsagePill('Focus Time', '${hubState.focusMinutes}m', Icons.timer_rounded, AppColors.calmTeal),
              _buildUsagePill('Mood Logs', '${hubState.moodLogsCount}', Icons.emoji_emotions_rounded, AppColors.warmSupport),
              _buildUsagePill('Grounding', '${hubState.groundingSessionsCount}x', Icons.fingerprint_rounded, AppColors.recoveryBlue),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsagePill(String label, String value, IconData icon, Color color) {
    return Container(margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: AppSurfaces.glassSoft, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.backgroundTertiary)), child: Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, size: 14, color: color)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)), Text(value, style: AppTypography.body.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary))])]));
  }

  // --- Timeline ---
  Widget _buildRecentActivityBox(BuildContext context, List<AssessmentResult> history) {
    if (history.isEmpty) return _buildEmptyActivity();
    final timelineItems = history.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppSurfaces.glassSoft, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.backgroundTertiary)),
      child: Column(
        children: timelineItems.map((result) {
          final dateStr = DateFormat('dd MMM').format(result.createdAt);
          return Column(children: [ListTile(contentPadding: EdgeInsets.zero, leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.novaPurple.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.assessment_rounded, color: AppColors.novaPurpleLight, size: 20)), title: Text('Clinical Screening', style: AppTypography.body.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)), subtitle: Text('Result: ${result.severityLevel}', style: AppTypography.caption.copyWith(fontSize: 12, color: AppColors.textMuted)), trailing: Text(dateStr, style: AppTypography.caption.copyWith(fontSize: 12, color: AppColors.textMuted)), onTap: () => context.push('/assessment-result', extra: result)), if (result != timelineItems.last) const Divider(height: 1, indent: 48, color: AppColors.backgroundTertiary)]);
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppSurfaces.glassSoft, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.backgroundTertiary)), child: Column(children: [Icon(Icons.history_toggle_off_rounded, size: 40, color: AppColors.textDisabled), const SizedBox(height: 12), Text('No meaningful milestones yet.', style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)), const SizedBox(height: 8), TextButton(onPressed: () => context.push('/adaptive-assessment/clinical_main'), child: Text('Take Assessment', style: AppTypography.button.copyWith(color: AppColors.novaPurpleLight, fontWeight: FontWeight.w700)))]));
  }

  // --- Skeletons & Helpers ---
  Widget _buildSkeletonHero() { return Container(width: double.infinity, height: 250, padding: const EdgeInsets.only(top: 20), child: Column(children: [Container(width: 110, height: 110, decoration: BoxDecoration(color: AppColors.backgroundTertiary, shape: BoxShape.circle)), const SizedBox(height: 16), Container(width: 150, height: 28, decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(8))), const SizedBox(height: 12), Container(width: 250, height: 16, decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(4)))])); }
  Widget _buildSkeletonGrowth() { return Container(height: 140, decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(28))); }
  Widget _buildSkeletonDashboard() { return Container(height: 180, decoration: BoxDecoration(color: AppSurfaces.glassSoft, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.backgroundTertiary)), padding: const EdgeInsets.all(20), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(width: 80, height: 40, color: AppColors.backgroundTertiary), Container(width: 60, height: 30, decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(12)))]), const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: AppColors.backgroundTertiary)), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(width: 100, height: 40, color: AppColors.backgroundTertiary), Container(width: 100, height: 40, color: AppColors.backgroundTertiary)])])); }
  Widget _buildSkeletonUsage() { return Container(height: 80, padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(children: List.generate(3, (i) => Container(width: 100, height: 50, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(16)))))); }
  Widget _buildSkeletonActivity() { return Container(height: 200, decoration: BoxDecoration(color: AppSurfaces.glassSoft, borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.all(16), child: Column(children: List.generate(3, (i) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(10))), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 120, height: 14, color: AppColors.backgroundTertiary), const SizedBox(height: 6), Container(width: 80, height: 10, color: AppColors.backgroundTertiary)])]))))); }
  Widget _buildErrorState(String message, VoidCallback onRetry) { return Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.emotionalDangerMuted.withOpacity(0.1), borderRadius: BorderRadius.circular(24)), child: Column(children: [Icon(Icons.error_outline_rounded, size: 40, color: AppColors.emotionalDangerMuted), const SizedBox(height: 12), Text(message, style: AppTypography.caption.copyWith(color: AppColors.emotionalDangerMuted, fontSize: 13, fontWeight: FontWeight.w500)), const SizedBox(height: 8), TextButton(onPressed: onRetry, child: Text('Retry', style: AppTypography.button.copyWith(color: AppColors.emotionalDangerMuted, fontWeight: FontWeight.w700)))])); }
  Widget _buildAvatar(String name, String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      String fullUrl = avatarUrl;
      if (!avatarUrl.startsWith('http')) {
        final baseUrl = ref.read(apiClientProvider).baseUrl;
        fullUrl = '$baseUrl${avatarUrl.startsWith('/') ? '' : '/'}$avatarUrl';
      }

      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Avatar load error: $error');
          return _buildAvatarFallback(name);
        },
      );
    }
    return _buildAvatarFallback(name);
  }

  Widget _buildAvatarFallback(String name) {
    return Container(
      color: AppColors.backgroundTertiary,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: AppTypography.heroXL.copyWith(fontSize: 44, color: AppColors.novaPurpleLight),
        ),
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: AppSurfaces.secondary, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), 
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            const SizedBox(height: 8), 
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textDisabled, borderRadius: BorderRadius.circular(2))), 
            const SizedBox(height: 24), 
            Text('Settings & Control', style: AppTypography.headingLarge.copyWith(fontSize: 20, color: AppColors.textPrimary)), 
            const SizedBox(height: 16), 
            ListTile(leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.textSecondary), title: Text('Data & Privacy', style: AppTypography.body.copyWith(color: AppColors.textPrimary)), onTap: () {}), 
            Consumer(
              builder: (context, ref, child) {
                final keepVoice = ref.watch(voiceRetentionProvider);
                return SwitchListTile(
                  secondary: const Icon(Icons.record_voice_over_rounded, color: AppColors.textSecondary),
                  title: Text('Keep Voice Recordings', style: AppTypography.body.copyWith(color: AppColors.textPrimary)),
                  subtitle: Text(keepVoice ? 'Audio is saved securely for insights' : 'Audio is deleted immediately after processing', style: AppTypography.body.copyWith(fontSize: 12, color: AppColors.textMuted)),
                  value: keepVoice,
                  onChanged: (val) {
                    ref.read(voiceRetentionProvider.notifier).toggle(val);
                  },
                  activeColor: AppColors.novaPurple,
                );
              }
            ),
            ListTile(leading: const Icon(Icons.download_rounded, color: AppColors.textSecondary), title: Text('Export Health Report', style: AppTypography.body.copyWith(color: AppColors.textPrimary)), onTap: () {}), 
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent), 
              title: Text('Logout', style: AppTypography.body.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold)), 
              onTap: () {
                final auth = ref.read(authProvider.notifier);
                Navigator.pop(context);
                auth.logout();
              }
            ),
            ListTile(leading: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted), title: Text('Clear All Local Data', style: AppTypography.body.copyWith(color: AppColors.textMuted)), onTap: () {}), 
            const SizedBox(height: 24)
          ]
        )
      )
    );
  }

  void _showEditProfile(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileSheet(profile: profile),
    );
  }

  Color _getRiskColor(RiskCategory? risk) { switch (risk) { case RiskCategory.minimal: return AppColors.successSoft; case RiskCategory.mild: return AppColors.calmTeal; case RiskCategory.moderate: return AppColors.warmSupport; case RiskCategory.high: case RiskCategory.severe: case RiskCategory.emergency: return AppColors.emotionalDangerMuted; default: return AppColors.textMuted; } }
  Color _getMoodColor(String trend) { if (trend == 'Improving') return AppColors.successSoft; if (trend == 'Declining') return AppColors.emotionalWarning; return AppColors.novaPurpleLight; }
  IconData _getMoodIcon(String trend) { if (trend == 'Improving') return Icons.trending_up_rounded; if (trend == 'Declining') return Icons.trending_down_rounded; return Icons.trending_flat_rounded; }
  Widget _buildGuestBanner(BuildContext context) { return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: AppGradients.nova, borderRadius: BorderRadius.circular(16)), child: Column(children: [Text('Save Your Progress', style: AppTypography.headingLarge.copyWith(fontSize: 18, color: Colors.white)), const SizedBox(height: 8), Text('Create an account to protect your history and sync data.', textAlign: TextAlign.center, style: AppTypography.body.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.9))), const SizedBox(height: 16), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) => const GuestUpgradeSheet()), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.novaPurple), child: const Text('Create Account')))])); }
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) { return SizedBox(width: double.infinity, height: 58, child: OutlinedButton(onPressed: () => ref.read(authProvider.notifier).logout(), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFFF453A), side: const BorderSide(color: Color(0xFFFF453A), width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))), child: Text('Log Out', style: AppTypography.button.copyWith(fontSize: 16, color: const Color(0xFFFF453A))))); }
  Widget _buildAppBarAction({required IconData icon, required VoidCallback onTap}) { return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.backgroundSecondary, shape: BoxShape.circle, border: Border.all(color: AppColors.backgroundTertiary)), child: Icon(icon, color: AppColors.textPrimary, size: 22))); }
}

class _GrowthGaugePainter extends CustomPainter {
  final double progress;
  _GrowthGaugePainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final bgPaint = Paint()..color = Colors.white.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round;
    final progressPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi * 0.8, math.pi * 1.4, false, bgPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi * 0.8, math.pi * 1.4 * progress, false, progressPaint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
