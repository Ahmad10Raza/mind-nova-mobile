import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../models/challenge_model.dart';
import '../../providers/challenge_provider.dart';
import '../widgets/challenge_card.dart';
import '../widgets/challenge_progress_bar.dart';

class ChallengeHomeScreen extends ConsumerStatefulWidget {
  const ChallengeHomeScreen({super.key});

  @override
  ConsumerState<ChallengeHomeScreen> createState() => _ChallengeHomeScreenState();
}

class _ChallengeHomeScreenState extends ConsumerState<ChallengeHomeScreen> {
  String _selectedCategory = 'ALL';

  static const _bg = Color(0xFF0F131F);
  static const _surface = Color(0xFF1B1F2C);
  static const _primary = Color(0xFFCABEFF);
  static const _onSurface = Color(0xFFDFE2F3);
  static const _onSurfaceVariant = Color(0xFFC9C4D8);

  final _categories = [
    {'label': 'All', 'value': 'ALL'},
    {'label': 'Mental Health', 'value': 'MENTAL_HEALTH'},
    {'label': 'Focus', 'value': 'FOCUS'},
    {'label': 'Recovery', 'value': 'RECOVERY'},
    {'label': 'Discipline', 'value': 'DISCIPLINE'},
  ];

  @override
  Widget build(BuildContext context) {
    final challengesAsync = ref.watch(challengeListProvider);
    final activeAsync = ref.watch(activeChallengeProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── App Bar ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: _bg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _onSurfaceVariant, size: 20),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              title: Text(
                'Challenges',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _onSurface,
                ),
              ),
              background: Stack(
                children: [
                  Container(color: _bg),
                  // Subtle glow
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _primary.withOpacity(0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Active Challenge Banner ──────────────────────
          activeAsync.when(
            data: (active) {
              if (active == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
              return SliverToBoxAdapter(
                child: _buildActiveBanner(active),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (e, st) {
              print('Active challenge error: $e');
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),

          // ─── Category Filter ──────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(cat['label']!),
                      backgroundColor: Colors.transparent,
                      selectedColor: _primary.withOpacity(0.15),
                      labelStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? _primary : _onSurfaceVariant,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      side: BorderSide(
                        color: isSelected ? _primary.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                      ),
                      showCheckmark: false,
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat['value']!);
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Challenges Grid ──────────────────────────────
          challengesAsync.when(
            data: (challenges) {
              final filtered = _selectedCategory == 'ALL'
                  ? challenges
                  : challenges.where((c) => c.category == _selectedCategory).toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flag_outlined, size: 64, color: _onSurfaceVariant.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'No challenges found',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final challenge = filtered[index];
                      return ChallengeCard(
                        challenge: challenge,
                        onTap: () => context.push('/challenges/${challenge.id}'),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: _primary)),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFFFB4AB), size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load challenges',
                      style: GoogleFonts.inter(color: _onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(challengeListProvider),
                      child: const Text('Retry', style: TextStyle(color: _primary)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildActiveBanner(UserChallenge active) {
    return GestureDetector(
      onTap: () => context.push('/challenges/active'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: _primary, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'ACTIVE NOW',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              active.challenge.title,
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Day ${active.currentDay} of ${active.challenge.durationDays}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ChallengeProgressBar(
              currentDay: active.currentDay,
              totalDays: active.challenge.durationDays,
              activeColor: _primary,
            ),
            if (active.dropOff != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_rounded, color: Color(0xFFFFD700), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        active.dropOff!.message,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFFFDE68A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
