import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/community_providers.dart';
import '../models/community_post_model.dart';
import '../models/community_insight_model.dart';
import '../models/community_room_model.dart';
import 'widgets/create_post_sheet.dart';

class CommunityHomeScreenV2 extends ConsumerWidget {
  const CommunityHomeScreenV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F131F),
      body: Stack(
        children: [
          // ─── Atmospheric Background Layers ───
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFFA078FF).withOpacity(0.12),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFFA078FF).withOpacity(0.12), blurRadius: 100)],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF03C6B2).withOpacity(0.08),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFF03C6B2).withOpacity(0.08), blurRadius: 100)],
              ),
            ),
          ),
          
          // ─── Main Content ───
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom App Bar (Fixed layout and removing back button)
              SliverAppBar(
                expandedHeight: 80.0,
                floating: true,
                pinned: true,
                automaticallyImplyLeading: false, 
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFCBC3D7)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                backgroundColor: const Color(0xFF0F131F).withOpacity(0.85),
                elevation: 0,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ColorFilter.mode(const Color(0xFF0F131F).withOpacity(0.1), BlendMode.srcOver),
                    child: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      title: Text(
                        'MindNova',
                        style: GoogleFonts.sora(
                          color: const Color(0xFFD0BCFF),
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 24),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF262A36),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Icon(Icons.person_outline_rounded, size: 20, color: Color(0xFFCBC3D7)),
                  ),
                ],
              ),
              
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),
                    // 1. Hero Constellation
                    const _ConstellationHero(),
                    const SizedBox(height: 40),
                    
                    // 2. Community Pulse
                    _buildSectionHeader(Icons.favorite_rounded, const Color(0xFF44E2CD), 'Community Pulse'),
                    const SizedBox(height: 16),
                    _buildCommunityPulse(ref),
                    const SizedBox(height: 40),
                    

                    
                    // 5. Feed Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.edit_note_rounded, color: Color(0xFFFFAFD3), size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Community Voices',
                              style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFFDFE2F3)),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => showCreatePostSheet(context),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: Text('Write Post', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFAFD3),
                            foregroundColor: const Color(0xFF0F131F),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildFeedTabs(ref),
                    const SizedBox(height: 16),
                    _buildReflectionsFeed(context, ref),
                    
                    const SizedBox(height: 40),
                    
                    _buildCommunityImpact(ref),
                    const SizedBox(height: 40),
                    
                    // 7. Safety Footer
                    _buildSafetyFooter(),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER COMPONENTS
  // ==========================================

  Widget _buildFeedTabs(WidgetRef ref) {
    final currentTab = ref.watch(communityFeedTabProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(communityFeedTabProvider.notifier).setTab('FOR_YOU'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: currentTab == 'FOR_YOU' ? Colors.white.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Latest',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: currentTab == 'FOR_YOU' ? FontWeight.w700 : FontWeight.w500,
                    color: currentTab == 'FOR_YOU' ? Colors.white : const Color(0xFFCBC3D7),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(communityFeedTabProvider.notifier).setTab('TRENDING'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: currentTab == 'TRENDING' ? Colors.white.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Trending',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: currentTab == 'TRENDING' ? FontWeight.w700 : FontWeight.w500,
                    color: currentTab == 'TRENDING' ? Colors.white : const Color(0xFFCBC3D7),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, Color color, String title, {String? actionText, VoidCallback? onActionTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.sora(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFDFE2F3),
              ),
            ),
          ],
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCommunityPulse(WidgetRef ref) {
    final insightsAsync = ref.watch(communityInsightsProvider);

    return insightsAsync.when(
      data: (insights) {
        final total = insights.totalPostsToday > 0 ? insights.totalPostsToday : 1; 
        final breakdown = insights.emotionBreakdown;

        final hopefulCount = (breakdown['HAPPY'] ?? 0) + (breakdown['EXCITED'] ?? 0);
        final supportedCount = (breakdown['CALM'] ?? 0) + (breakdown['GRATEFUL'] ?? 0);
        final growingCount = (breakdown['NEUTRAL'] ?? 0) + (breakdown['STRESSED'] ?? 0);
        final strugglingCount = (breakdown['SAD'] ?? 0) + (breakdown['ANXIOUS'] ?? 0) + (breakdown['LONELY'] ?? 0);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2, // wider cards for trends
          children: [
            _buildPulseTrendCard('Hopeful', Icons.flare_rounded, const Color(0xFF44E2CD), hopefulCount / total, '+12% this week'),
            _buildPulseTrendCard('Supported', Icons.diversity_1_rounded, const Color(0xFFD0BCFF), supportedCount / total, 'Strong momentum'),
            _buildPulseTrendCard('Growing', Icons.psychology_rounded, const Color(0xFFFFAFD3), growingCount / total, 'Steady pace'),
            _buildPulseTrendCard('Struggling', Icons.water_drop_rounded, const Color(0xFF958EA0), strugglingCount / total, 'Needs support'),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))),
      error: (err, stack) => Text('Failed to load pulse', style: TextStyle(color: Colors.white.withOpacity(0.5))),
    );
  }

  Widget _buildPulseTrendCard(String title, IconData icon, Color color, double percentage, String trend) {
    final visualPercentage = percentage < 0.1 ? 0.1 : percentage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFDFE2F3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trend,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFCBC3D7).withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF262A36),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: visualPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)],
                      ),
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



  Widget _buildReflectionsFeed(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(communityFeedProvider);

    return feedAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return _buildEmptyState(
            message: "Every healing journey begins with a single step.",
            actionText: "Share first reflection",
            icon: Icons.edit_note_rounded,
            onActionTap: () => showCreatePostSheet(context),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length, 
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final post = posts[index];
            final hoursAgo = DateTime.now().difference(post.createdAt).inHours;
            final timeString = hoursAgo == 0 ? 'Just now' : '${hoursAgo}h ago';

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFF262A36),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFFCBC3D7)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.isAnonymous ? 'Anonymous' : (post.aliasName ?? 'Member'),
                                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFDFE2F3)),
                              ),
                              Text(
                                'in ${post.emotion} Space • $timeString',
                                style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFFCBC3D7).withOpacity(0.6)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          post.type.toUpperCase(),
                          style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFFCBC3D7)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    post.content,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: const Color(0xFFDFE2F3),
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        // New PRD Reactions: Support, Relate, Inspired, Hope
                        _buildReactionButton(ref, post.id, '💜', post.reactionCounts['SUPPORT'] ?? 0, 'SUPPORT', 'Support'),
                        _buildReactionButton(ref, post.id, '🫂', post.reactionCounts['RELATE'] ?? 0, 'RELATE', 'Relate'),
                        _buildReactionButton(ref, post.id, '🌱', post.reactionCounts['INSPIRED'] ?? 0, 'INSPIRED', 'Inspired'),
                        _buildReactionButton(ref, post.id, '✨', post.reactionCounts['HOPE'] ?? 0, 'HOPE', 'Hope'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFFAFD3))),
      error: (e, s) => Text('Error loading feed', style: TextStyle(color: Colors.white.withOpacity(0.5))),
    );
  }

  Widget _buildReactionButton(WidgetRef ref, String postId, String emoji, int count, String type, String label) {
    return GestureDetector(
      onTap: () {
        ref.read(postReactionProvider.notifier).toggleReaction(postId, type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFCBC3D7)),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Text(
                count.toString(),
                style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFFCBC3D7).withOpacity(0.5)),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityImpact(WidgetRef ref) {
    final insightsAsync = ref.watch(communityInsightsProvider);

    final String supportInteractions = insightsAsync.maybeWhen(
      data: (insights) => insights.totalInteractionsToday.toString(),
      orElse: () => '...',
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Impact Today',
            style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFDFE2F3)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Support Interactions', style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFFCBC3D7))),
              Text(supportInteractions, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFFFAFD3))),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildEmptyState({required String message, String? actionText, required IconData icon, VoidCallback? onActionTap}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.manrope(fontSize: 16, color: const Color(0xFFCBC3D7), fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            if (actionText != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onActionTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    actionText,
                    style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.shield_rounded, color: Color(0xFF262A36), size: 48),
          const SizedBox(height: 16),
          Text(
            'Safety Center',
            style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFFDFE2F3)),
          ),
          const SizedBox(height: 8),
          Text(
            'All spaces are moderated.\nCrisis escalation support is always available.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFFCBC3D7), height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Community Guidelines',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF44E2CD),
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xFF44E2CD),
                ),
              ),
              const SizedBox(width: 32),
              Row(
                children: [
                  const Icon(Icons.sos_rounded, color: Color(0xFFFFB4AB), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Crisis Support',
                    style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFFFB4AB)),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

// ==========================================
// CUSTOM CONSTELLATION HERO
// ==========================================
class _ConstellationHero extends ConsumerStatefulWidget {
  const _ConstellationHero();

  @override
  ConsumerState<_ConstellationHero> createState() => _ConstellationHeroState();
}

class _ConstellationHeroState extends ConsumerState<_ConstellationHero> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insightsAsync = ref.watch(communityInsightsProvider);
    final circlesAsync = ref.watch(liveCirclesProvider);

    final String activeMembers = insightsAsync.maybeWhen(
      data: (insights) => insights.activeMembers > 0 ? '${(insights.activeMembers / 1000).toStringAsFixed(1)}k' : '1.2k',
      orElse: () => '...',
    );

    final String reflectionsToday = insightsAsync.maybeWhen(
      data: (insights) => insights.totalPostsToday.toString(),
      orElse: () => '...',
    );
    
    final String supportInteractions = insightsAsync.maybeWhen(
      data: (insights) => insights.totalInteractionsToday.toString(),
      orElse: () => '...',
    );

    final String liveCirclesCount = circlesAsync.maybeWhen(
      data: (rooms) => rooms.where((r) => r.status == 'LIVE').length.toString(),
      orElse: () => '...',
    );

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: const Color(0xFFA078FF).withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 10)),
        ],
      ),
      child: Stack(
        children: [
          // The Animated Constellation Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ConstellationPainter(_controller.value),
                );
              },
            ),
          ),
          
          // Foreground Content
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0BCFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD0BCFF).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diversity_3_rounded, size: 16, color: Color(0xFFD0BCFF)),
                      const SizedBox(width: 8),
                      Text(
                        'Sanctuary',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: const Color(0xFFD0BCFF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'You are not alone.',
                  style: GoogleFonts.sora(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFDFE2F3),
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Thousands of people are healing, reflecting, and growing together.',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFCBC3D7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Real-time emotional metrics grid
                Row(
                  children: [
                    _buildMetric(activeMembers, 'Members active', const Color(0xFF44E2CD)),
                    const SizedBox(width: 24),
                    _buildMetric(liveCirclesCount, 'Live circles happening', const Color(0xFFD0BCFF)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildMetric(reflectionsToday, 'Reflections today', const Color(0xFFFFAFD3)),
                    const SizedBox(width: 24),
                    _buildMetric(supportInteractions, 'Support interactions', const Color(0xFFDFE2F3)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String value, String label, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: color, blurRadius: 6)],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: GoogleFonts.sora(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFCBC3D7).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  final double pulse;
  _ConstellationPainter(this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFFD0BCFF).withOpacity(0.1 + (pulse * 0.1))
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final paintStar1 = Paint()..color = const Color(0xFFD0BCFF).withOpacity(0.6 + (pulse * 0.4));
    final paintStar2 = Paint()..color = const Color(0xFF44E2CD).withOpacity(0.6 + ((1 - pulse) * 0.4));

    // Hardcoded constellation points for effect, positioned on the right side
    final p1 = Offset(size.width * 0.6, size.height * 0.2);
    final p2 = Offset(size.width * 0.8, size.height * 0.3);
    final p3 = Offset(size.width * 0.7, size.height * 0.6);
    final p4 = Offset(size.width * 0.9, size.height * 0.7);
    final p5 = Offset(size.width * 0.85, size.height * 0.9);
    final p6 = Offset(size.width * 0.5, size.height * 0.8);

    // Draw lines
    canvas.drawLine(p1, p2, paintLine);
    canvas.drawLine(p2, p3, paintLine);
    canvas.drawLine(p3, p1, paintLine);
    canvas.drawLine(p2, p4, paintLine);
    canvas.drawLine(p4, p5, paintLine);
    canvas.drawLine(p3, p6, paintLine);
    canvas.drawLine(p5, p6, paintLine);

    // Draw stars
    canvas.drawCircle(p1, 3, paintStar1);
    canvas.drawCircle(p2, 4, paintStar2);
    canvas.drawCircle(p3, 2.5, paintStar1);
    canvas.drawCircle(p4, 3.5, paintStar2);
    canvas.drawCircle(p5, 2, paintStar1);
    canvas.drawCircle(p6, 3, paintStar2);
    
    // Draw subtle glows
    canvas.drawCircle(p2, 12, Paint()..color = const Color(0xFF44E2CD).withOpacity(0.1 * pulse));
    canvas.drawCircle(p1, 10, Paint()..color = const Color(0xFFD0BCFF).withOpacity(0.1 * (1 - pulse)));
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) => true;
}
