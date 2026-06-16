import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../models/challenge_model.dart';
import '../../providers/challenge_provider.dart';

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final String challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  ConsumerState<ChallengeDetailScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  String _selectedTime = 'MORNING';
  bool _reminderEnabled = true;

  static const _bg = Color(0xFF0F131F);
  static const _surface = Color(0xFF1B1F2C);
  static const _primary = Color(0xFFCABEFF);
  static const _secondary = Color(0xFF44E2CD);
  static const _onSurface = Color(0xFFDFE2F3);
  static const _onSurfaceVariant = Color(0xFFC9C4D8);

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final challengeAsync = ref.watch(challengeDetailProvider(widget.challengeId));
    final actionState = ref.watch(challengeActionProvider);
    final activeAsync = ref.watch(activeChallengeProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: challengeAsync.when(
        data: (challenge) => _buildContent(challenge, actionState, activeAsync),
        loading: () => const Center(
          child: CircularProgressIndicator(color: _primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFFFB4AB), size: 40),
              const SizedBox(height: 12),
              Text(
                'Failed to load challenge',
                style: GoogleFonts.inter(color: _onSurfaceVariant),
              ),
              TextButton(
                onPressed: () =>
                    ref.invalidate(challengeDetailProvider(widget.challengeId)),
                child: const Text('Retry', style: TextStyle(color: _primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    Challenge challenge,
    ChallengeActionState actionState,
    AsyncValue<UserChallenge?> activeAsync,
  ) {
    final colors = challenge.coverGradient.map(_hexToColor).toList();
    final hasActive = activeAsync.value != null;
    final isThisActive = activeAsync.value?.challengeId == challenge.id;

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Hero Header ────────────────────────────────────
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: colors.first,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.first,
                        colors.length > 1 ? colors.last.withOpacity(0.8) : colors.first.withOpacity(0.5),
                        _bg,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Text(challenge.icon, style: const TextStyle(fontSize: 56)),
                        const SizedBox(height: 16),
                        Text(
                          challenge.title,
                          style: GoogleFonts.manrope(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _infoBadge('${challenge.durationDays} days'),
                            const SizedBox(width: 8),
                            _infoBadge(_difficultyLabel(challenge.difficultyLevel)),
                            const SizedBox(width: 8),
                            _infoBadge('${challenge.participantCount} joined'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Description ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  challenge.description,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.6,
                    color: _onSurfaceVariant,
                  ),
                ),
              ),
            ),

            // ─── Day-by-Day Timeline ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Day-by-Day Journey',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _onSurface,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final day = challenge.days[index];
                  final isLast = index == challenge.days.length - 1;
                  return _buildTimelineItem(day, isLast, colors.first);
                },
                childCount: challenge.days.length,
              ),
            ),

            // ─── Time Preference (only if not already active) ───
            if (!isThisActive) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'When do you prefer?',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _timePill('🌅', 'Morning', 'MORNING'),
                          const SizedBox(width: 12),
                          _timePill('☀️', 'Afternoon', 'AFTERNOON'),
                          const SizedBox(width: 12),
                          _timePill('🌙', 'Evening', 'EVENING'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Reminder toggle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.notifications_active_rounded,
                                color: _onSurfaceVariant, size: 20),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Daily reminders',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: _onSurface,
                                ),
                              ),
                            ),
                            Switch(
                              value: _reminderEnabled,
                              onChanged: (v) => setState(() => _reminderEnabled = v),
                              activeColor: _primary,
                              inactiveTrackColor: Colors.white.withOpacity(0.1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),

        // ─── Floating CTA Button ──────────────────────────────
        Positioned(
          left: 24,
          right: 24,
          bottom: 40,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [const Color(0xFF6A0DAD), _secondary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: actionState.isLoading
                  ? null
                  : () async {
                      if (isThisActive) {
                        context.push('/challenges/active');
                      } else if (hasActive) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'You already have an active challenge. Complete or pause it first.',
                              style: GoogleFonts.inter(),
                            ),
                            backgroundColor: const Color(0xFFFFB4AB),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        final result = await ref
                            .read(challengeActionProvider.notifier)
                            .startChallenge(
                              challengeId: challenge.id,
                              preferredTime: _selectedTime,
                              reminderEnabled: _reminderEnabled,
                            );
                        if (result != null && mounted) {
                          context.push('/challenges/active');
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: actionState.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isThisActive ? 'Continue Challenge →' : 'Start Challenge',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(ChallengeDay day, bool isLast, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline dot + line
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.15),
                    border: Border.all(color: color.withOpacity(0.5), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${day.dayNumber}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Day content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.title,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${day.tasks.length} tasks • ${day.tasks.fold<int>(0, (s, t) => s + t.duration)} min',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timePill(String emoji, String label, String value) {
    final isSelected = _selectedTime == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTime = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? _primary.withOpacity(0.15)
                : _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? _primary.withOpacity(0.5)
                  : Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? _primary : _onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  String _difficultyLabel(int level) {
    switch (level) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Intermediate';
      case 3:
        return 'Advanced';
      default:
        return 'Beginner';
    }
  }
}
