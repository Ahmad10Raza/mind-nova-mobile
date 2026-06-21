import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../providers/community_providers.dart';
import '../../models/community_room_model.dart';
import '../../models/community_insight_model.dart';

// ── Category data for the "By Intention" row ──
class _IntentionCategory {
  final String label;
  final IconData icon;
  final Color color;
  const _IntentionCategory(this.label, this.icon, this.color);
}

const _categories = [
  _IntentionCategory('Anxiety', Icons.air_rounded, AppColors.calmTeal),
  _IntentionCategory('Sleep', Icons.bedtime_rounded, AppColors.novaPurple),
  _IntentionCategory('Burnout', Icons.local_fire_department_rounded, AppColors.warmSupport),
  _IntentionCategory('Focus', Icons.center_focus_strong_rounded, AppColors.calmTeal),
  _IntentionCategory('Grief', Icons.favorite_rounded, AppColors.novaPurpleLight),
];

const _novaQuotes = [
  "You don't need to speak. Listening is enough. Your presence itself is a contribution to the circle's energy.",
  "Healing doesn't happen alone. Every soul present tonight adds to the collective calm.",
  "There's no right way to feel here. Just being present is an act of courage.",
];

// Host & Member Avatar mock URLs from HTML
const _hostImageUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuARqK7PKVZkl54AV4hNCjImxNst-W6_0RelFfzTElCEBG6FyEKoU7j8mBW32UOyaQzWgNrMhgcyN0JbqnmCXvBdDJ4tIn3IIsbBsN7CXU6S8nkezNBPOgV5nv-LR8hjrIeYZh3t4anMB5_beaPYEqfihOT0UwWnnpG9gM9QbLvX2bYzHW_M34yYfBlpROY_A8EF-psfPG7h2WbIKmmdRHyoj6Xg0z7xmx2RdJslvXdMMGpKEwVynmKum80ORDLJFFBwJKitT2XF5YST';
const _memberImages = [
  'https://lh3.googleusercontent.com/aida-public/AB6AXuBZWUAbzDTzj5wVCfYLcZNsQeA0UzTlJtIp5-yILeGaU_EqY4ud6Ybmeb7HiHPVKlFaiBFOePISNFSLoOw38mQlq7zAzUtJm0pfg803UD96c5A1jfTmidM1Ll81i5SyDQIQ0LbdFjA6AIWtSHLnmt-TtO4Q3cFToBQK5gf_1Z4VqbvsVlD7qWAisz3F3HhWpec5J04MwANA3pKPildaNWibtHhfVBksFsACIca38wCtHnBh0YU19vrsFEqw4X0C6mUZHxOHtAsQliQT',
  'https://lh3.googleusercontent.com/aida-public/AB6AXuCMX-IV9XuqTIlEmuL1CznyibJgYvOcf-ru3yiErPXZREfcJmXTVl91W7pQLb-vH9bmDfSSOzGIpjmN0hRK_um7Q5dH6MqDgCfMhbT4DP8HOuBP6-G81cd7J_NzQha3-rI4qrHqVh6FuAuuV_RYONM0XZPgb9RmXtE9DNEQ35VtzaF-HoBvT6_DijRaAxEcF6IalJlzL8HjTlLBzpoMvFBqh8z-LxqQmBWKwdmE6B48tJDEpGjm3A70_Fd1afunt3ffLEWt2u-SrJ1B',
  'https://lh3.googleusercontent.com/aida-public/AB6AXuDb1SITiTnC2gbt0MTijSyvjAh1Svf6WodYVnC6bzmEKzAjaAx2dJ3BrvgQ_3_rj9GMlzgPGrOtFAs1Vj8VL0F6xPSTvXqdY_VVFAM6fb9thyl-QvkcEzGwEkN2kZOEN7Vgd_nr8of2RB7apRpGVgccHFIUGpq7KJlgyXHRh_0XQxdyfiobuPNOeuVFGyGAbBIAwlfIPRJ-anSbE0HrhEXuQBiKEfUIGOtIKFv7pMaAZJ8f2Y2nZqEWhmnhXOVcG_jr1JMMZ48QxLBT',
];

class LiveCirclesScreen extends ConsumerStatefulWidget {
  const LiveCirclesScreen({super.key});

  @override
  ConsumerState<LiveCirclesScreen> createState() => _LiveCirclesScreenState();
}

class _LiveCirclesScreenState extends ConsumerState<LiveCirclesScreen> with SingleTickerProviderStateMixin {
  String _novaQuote = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _novaQuote = _novaQuotes[Random().nextInt(_novaQuotes.length)];
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _timeUntil(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'Started';
    if (diff.inDays > 0) return 'In ${diff.inDays}d ${diff.inHours % 24}h';
    if (diff.inHours > 0) return 'In ${diff.inHours}h ${diff.inMinutes % 60}m';
    if (diff.inMinutes > 0) return 'In ${diff.inMinutes}m';
    return 'Starting now';
  }

  Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'burnout': return AppColors.warmSupport;
      case 'sleep': return AppColors.recoveryBlue;
      case 'anxiety': return AppColors.calmTeal;
      case 'stress': return AppColors.novaPurpleLight;
      case 'students': return AppColors.novaPurple;
      default: return AppColors.novaPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveAsync = ref.watch(liveCirclesProvider);
    final upcomingAsync = ref.watch(upcomingCirclesProvider);
    final insightsAsync = ref.watch(communityInsightsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F131F), // Dark deep background from HTML
      body: Stack(
        children: [
          // ── Cosmic gradient & particles ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.8),
                  radius: 1.2,
                  colors: [Color.fromRGBO(208, 188, 255, 0.15), Color.fromRGBO(15, 19, 31, 0)],
                ),
              ),
            ),
          ),
          Positioned(top: -100, right: -100, child: Container(width: 400, height: 300, decoration: BoxDecoration(color: AppColors.novaPurple.withValues(alpha: 0.1), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120), child: const SizedBox()))),
          Positioned(bottom: 100, left: -50, child: Container(width: 300, height: 250, decoration: BoxDecoration(color: AppColors.calmTeal.withValues(alpha: 0.05), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: const SizedBox()))),

          // Particle overlay (simulate CSS particles)
          const Positioned.fill(child: _ParticleBackground()),

          // ── Main content ──
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => context.pop()),
                title: Row(children: [
                  Icon(Icons.spa_rounded, color: AppColors.novaPurpleLight, size: 22),
                  const SizedBox(width: 8),
                  Text('Healing Together', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.novaPurpleLight)),
                ]),
                actions: [
                  IconButton(icon: const Icon(Icons.search_rounded, color: Colors.white54), onPressed: () {}),
                  IconButton(icon: Icon(Icons.account_circle_rounded, color: AppColors.novaPurpleLight, size: 28), onPressed: () {}),
                ],
                flexibleSpace: ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(color: const Color(0xFF0F131F).withValues(alpha: 0.4)))),
              ),

              // ── Hero Section ──
              SliverToBoxAdapter(child: _buildHero(insightsAsync, liveAsync)),

              // ── Featured Live Session ──
              SliverToBoxAdapter(child: liveAsync.when(
                data: (rooms) {
                  final liveRooms = rooms.where((r) => r.isLive).toList();
                  return liveRooms.isNotEmpty ? _buildFeaturedLive(liveRooms.first) : const SizedBox.shrink();
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox.shrink(),
              )),

              // ── Categories ──
              SliverToBoxAdapter(child: _buildCategories()),

              // ── Other Active Circles ──
              SliverToBoxAdapter(child: liveAsync.when(
                data: (rooms) {
                  final liveRooms = rooms.where((r) => r.isLive).toList();
                  return liveRooms.length > 1 ? _buildActiveCircles(liveRooms.sublist(1)) : const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              )),

              // ── Nova Voice ──
              SliverToBoxAdapter(child: _buildNovaVoice()),

              // ── Upcoming Circles ──
              SliverToBoxAdapter(child: upcomingAsync.when(
                data: (rooms) {
                  final upRooms = rooms.where((r) => !r.isLive && r.startsAt.isAfter(DateTime.now().subtract(const Duration(hours: 1)))).toList();
                  return upRooms.isNotEmpty ? _buildUpcoming(upRooms) : const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              )),

              // ── Safety / Stats ──
              SliverToBoxAdapter(child: _buildSafetyStats(insightsAsync)),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HERO
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildHero(AsyncValue<CommunityInsight> insightsAsync, AsyncValue<List<CommunityRoom>> liveAsync) {
    final healingNow = insightsAsync.value?.activeMembers ?? 1204; // Mock default if 0 for visual
    final rooms = liveAsync.value ?? [];
    final activeCircles = rooms.where((r) => r.isLive).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(children: [
        Text('Healing Happens Together', style: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('Join a live circle. Listen, share, or\nsimply be present.', style: GoogleFonts.manrope(fontSize: 14, color: Colors.white.withValues(alpha: 0.7), height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        // Constellation visual exactly like HTML
        SizedBox(
          height: 180,
          width: double.infinity,
          child: Stack(alignment: Alignment.center, children: [
            // Center blur
            Container(width: 96, height: 96, decoration: BoxDecoration(color: AppColors.novaPurple.withValues(alpha: 0.2), shape: BoxShape.circle)),
            // SVG replacement (CustomPainter)
            const Positioned.fill(child: CustomPaint(painter: _ConstellationPainter())),
            // Nodes
            Positioned(top: 45, left: MediaQuery.of(context).size.width * 0.5 - 20, child: _pulseNode(AppColors.calmTeal, 12, true)),
            Positioned(top: 95, left: MediaQuery.of(context).size.width * 0.2, child: _pulseNode(AppColors.novaPurpleLight, 8, false, opacity: 0.6)),
            Positioned(top: 115, right: MediaQuery.of(context).size.width * 0.2, child: _pulseNode(AppColors.novaPurpleLight, 8, false, opacity: 0.4)),
            Positioned(top: 155, right: MediaQuery.of(context).size.width * 0.35, child: _pulseNode(AppColors.calmTeal, 8, false, opacity: 0.5)),

            // Stats at bottom
            Positioned(bottom: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _statColumn((healingNow > 0 ? healingNow : 1204).toString(), 'Healing Now', AppColors.novaPurpleLight),
              const SizedBox(width: 60),
              _statColumn((activeCircles > 0 ? activeCircles : 12).toString(), 'Active Circles', AppColors.calmTeal),
            ])),
          ]),
        ),
      ]),
    );
  }

  Widget _pulseNode(Color color, double size, bool animate, {double opacity = 1.0}) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = animate ? 1.0 + (_pulseController.value * 0.5) : 1.0;
        final op = animate ? 1.0 - (_pulseController.value * 0.8) : opacity;
        return Stack(
          alignment: Alignment.center,
          children: [
            if (animate) Container(width: size * scale * 2, height: size * scale * 2, decoration: BoxDecoration(color: color.withValues(alpha: op), shape: BoxShape.circle)),
            Container(width: size, height: size, decoration: BoxDecoration(color: color.withValues(alpha: opacity), shape: BoxShape.circle)),
          ],
        );
      },
    );
  }

  Widget _statColumn(String value, String label, Color color) {
    return Column(children: [
      Text(value, style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
      const SizedBox(height: 2),
      Text(label.toUpperCase(), style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Colors.white.withValues(alpha: 0.7))),
    ]);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // FEATURED LIVE SESSION
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildFeaturedLive(CommunityRoom room) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // LIVE badge absolute positioned in design
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(room.title, style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.groups_rounded, size: 18, color: Colors.white.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  Text('${room.participantCount} souls present', style: GoogleFonts.manrope(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
                ]),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.calmTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.calmTeal.withValues(alpha: 0.2))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) => Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.calmTeal.withValues(alpha: 0.4 + (_pulseController.value * 0.6)), shape: BoxShape.circle)),
                ),
                const SizedBox(width: 6),
                Text('LIVE', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.calmTeal)),
              ]),
            ),
          ]),
          const SizedBox(height: 24),
          // Host info
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.novaPurpleLight.withValues(alpha: 0.3))),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: room.hostImageUrl != null
                    ? Image.network(room.hostImageUrl!, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: AppColors.novaPurple))
                    : Container(color: AppColors.novaPurple, child: const Icon(Icons.person, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(room.hostName, style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              Text(room.hostType == 'THERAPIST' ? 'Facilitator Online' : 'Host Online', style: GoogleFonts.manrope(fontSize: 13, color: AppColors.calmTeal)),
            ]),
          ]),
          const SizedBox(height: 24),
          // Action buttons
          Row(children: [
            Expanded(child: _actionBtn('Join Circle', Icons.hearing_rounded, AppColors.novaPurpleLight, const Color(0xFF0F131F), () {
              context.push('/community/live_circles/${room.id}');
            })),
            const SizedBox(width: 12),
            Expanded(child: _actionBtn('Listen Quietly', Icons.volume_off_rounded, Colors.white.withValues(alpha: 0.05), Colors.white, () {
              context.push('/community/live_circles/${room.id}');
            }, bordered: true)),
          ]),
        ]),
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color bg, Color fg, VoidCallback onTap, {bool bordered = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: bordered ? Border.all(color: Colors.white.withValues(alpha: 0.1)) : null,
          boxShadow: bordered ? null : [BoxShadow(color: AppColors.novaPurpleLight.withValues(alpha: 0.2), blurRadius: 12)],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: fg)),
        ]),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // CATEGORIES
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('By Intention', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('View All', style: GoogleFonts.manrope(fontSize: 14, color: AppColors.novaPurpleLight)),
          ]),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final cat = _categories[i];
              return Column(children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                  child: Icon(cat.icon, size: 32, color: cat.color),
                ),
                const SizedBox(height: 8),
                Text(cat.label, style: GoogleFonts.manrope(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
              ]);
            },
          ),
        ),
      ]),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // OTHER ACTIVE CIRCLES
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildActiveCircles(List<CommunityRoom> rooms) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Other Active Circles', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 16),
        ...rooms.map((room) {
          final accent = _colorForCategory(room.category);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => context.push('/community/live_circles/${room.id}'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border(left: BorderSide(color: accent.withValues(alpha: 0.4), width: 4)),
                ),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(room.category.toUpperCase(), style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: accent)),
                    const SizedBox(height: 4),
                    Text(room.title, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text('Host: ${room.hostName}', style: GoogleFonts.manrope(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
                      Container(width: 4, height: 4, margin: const EdgeInsets.symmetric(horizontal: 8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), shape: BoxShape.circle)),
                      Text('${room.participantCount} listening', style: GoogleFonts.manrope(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
                    ]),
                  ])),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                    child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.novaPurpleLight),
                  ),
                ]),
              ),
            ),
          );
        }),
      ]),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // NOVA VOICE
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildNovaVoice() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.novaPurple.withValues(alpha: 0.1), AppColors.calmTeal.withValues(alpha: 0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.novaPurple.withValues(alpha: 0.2)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.novaPurple.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.novaPurpleLight, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Nova Voice', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.novaPurpleLight)),
            const SizedBox(height: 6),
            Text('"$_novaQuote"', style: GoogleFonts.manrope(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.white, height: 1.5)),
          ])),
        ]),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // UPCOMING CIRCLES
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildUpcoming(List<CommunityRoom> rooms) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Upcoming Circles', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 16),
        ...rooms.map((room) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E213A).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(room.title, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(_timeUntil(room.startsAt), style: GoogleFonts.manrope(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
              ])),
              GestureDetector(
                onTap: () async {
                  final service = ref.read(communityServiceProvider);
                  try {
                    final result = await service.setReminder(room.id);
                    if (mounted) {
                      final status = result['status'] ?? 'added';
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(status == 'added' ? 'Reminder set!' : 'Reminder removed'),
                        backgroundColor: AppColors.backgroundSecondary,
                      ));
                    }
                  } catch (_) {}
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.calmTeal.withValues(alpha: 0.2))),
                  child: Text('Remind Me', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.calmTeal)),
                ),
              ),
            ]),
          ),
        )),
      ]),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // SAFETY & STATS
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildSafetyStats(AsyncValue<CommunityInsight> insightsAsync) {
    final members = insightsAsync.value?.activeMembers ?? 327; // Use 327 if 0 to match UI mock
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.verified_user_rounded, size: 16, color: AppColors.calmTeal.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Text('ACTIVE MODERATION & VERIFIED FACILITATORS', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Colors.white.withValues(alpha: 0.6))),
        ]),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.calmTeal.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
            boxShadow: [BoxShadow(color: AppColors.calmTeal.withValues(alpha: 0.15), blurRadius: 30)],
          ),
          child: Column(children: [
            Text('${members > 0 ? members : 327} members', style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.calmTeal)),
            const SizedBox(height: 4),
            Text('healing together tonight', style: GoogleFonts.manrope(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
            const SizedBox(height: 16),
            // Avatar pile
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i=0; i<_memberImages.length; i++)
                  Align(
                    widthFactor: 0.7,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0F131F), width: 2)),
                      child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(_memberImages[i], fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: AppColors.novaPurpleLight))),
                    ),
                  ),
                Align(
                  widthFactor: 0.7,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0F131F), width: 2), color: AppColors.novaPurpleLight.withValues(alpha: 0.2)),
                    child: Center(child: Text('+324', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.novaPurpleLight))),
                  ),
                ),
              ],
            )
          ]),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => context.push('/crisis'),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.crisis_alert_rounded, size: 18, color: AppColors.error),
            const SizedBox(width: 8),
            Text('Crisis Support Available 24/7', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error)),
          ]),
        ),
      ]),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER & PARTICLES
// ────────────────────────────────────────────────────────────────────────────
class _ParticleBackground extends StatefulWidget {
  const _ParticleBackground();
  @override
  State<_ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<_ParticleBackground> with SingleTickerProviderStateMixin {
  late final List<Map<String, dynamic>> _particles;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(40, (i) => {
      'x': rng.nextDouble(),
      'y': rng.nextDouble(),
      'size': rng.nextDouble() * 2 + 1,
      'speed': rng.nextDouble() * 0.5 + 0.5,
      'offset': rng.nextDouble() * pi * 2,
    });
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _ParticlePainter(_particles, _controller.value),
        size: Size.infinite,
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Map<String, dynamic>> particles;
  final double time;
  _ParticlePainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (var p in particles) {
      final double drift = sin(time * pi * 2 * p['speed'] + p['offset']) * 20;
      final double y = (p['y'] * size.height) - drift;
      // opacity varies with time
      paint.color = Colors.white.withValues(alpha: 0.1 + (sin(time * pi * 4 + p['offset']) + 1) * 0.15);
      canvas.drawCircle(Offset(p['x'] * size.width, y), p['size'], paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ConstellationPainter extends CustomPainter {
  const _ConstellationPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = AppColors.novaPurpleLight.withValues(alpha: 0.2)..strokeWidth = 1..style = PaintingStyle.stroke;
    final paint2 = Paint()..color = AppColors.novaPurpleLight.withValues(alpha: 0.1)..strokeWidth = 1..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.25)
      ..lineTo(size.width * 0.8, size.height * 0.6)
      ..lineTo(size.width * 0.6, size.height * 0.8)
      ..close();
    
    final path2 = Path()
      ..moveTo(size.width * 0.5, size.height * 0.25)
      ..lineTo(size.width * 0.6, size.height * 0.8);

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
