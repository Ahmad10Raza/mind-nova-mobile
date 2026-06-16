import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../models/challenge_model.dart';
import '../../providers/challenge_provider.dart';
import '../widgets/challenge_task_card.dart';
import '../widgets/challenge_progress_bar.dart';

class ActiveChallengeScreen extends ConsumerStatefulWidget {
  const ActiveChallengeScreen({super.key});

  @override
  ConsumerState<ActiveChallengeScreen> createState() =>
      _ActiveChallengeScreenState();
}

class _ActiveChallengeScreenState extends ConsumerState<ActiveChallengeScreen>
    with TickerProviderStateMixin {
  final Map<String, bool> _checkedTasks = {};
  bool _showCelebration = false;
  int _completedDayNumber = 1;
  late AnimationController _celebrationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  int get _checkedCount => _checkedTasks.values.where((v) => v).length;

  String _identityMessage(String category) {
    switch (category) {
      case 'MENTAL_HEALTH':
        return 'You are becoming more calm 🧘';
      case 'FOCUS':
        return 'You are sharpening your focus 🎯';
      case 'RECOVERY':
        return 'You are healing your body 🌙';
      case 'DISCIPLINE':
        return 'You are building discipline ⚡';
      default:
        return 'You are growing stronger 💪';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeAsync = ref.watch(activeChallengeProvider);
    final actionState = ref.watch(challengeActionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F131F),
      body: activeAsync.when(
        data: (active) {
          if (active == null) return _buildNoActive();
          return _buildActiveContent(active, actionState);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF9147FF)),
        ),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
              const SizedBox(height: 12),
              Text('Something went wrong',
                  style: GoogleFonts.inter(color: Colors.white60)),
              TextButton(
                onPressed: () => ref.invalidate(activeChallengeProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoActive() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'No active challenge',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a challenge to begin your journey',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/challenges'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCABEFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: Text(
              'Browse Challenges',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveContent(UserChallenge active, ChallengeActionState actionState) {
    final todayDay = active.todayDay;
    final tasks = todayDay?.tasks ?? [];
    final totalTasks = tasks.length;
    final percentage = totalTasks > 0 ? _checkedCount / totalTasks : 0.0;
    final canComplete = percentage >= 0.5;

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── App Bar ──────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: const Color(0xFF0F131F),
              leading: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      color: Colors.white.withOpacity(0.6)),
                  color: const Color(0xFF1B1F2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (value) => _handleMenuAction(value, active),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'pause',
                      child: Row(
                        children: [
                          const Icon(Icons.pause_circle_outline,
                              color: Colors.amber, size: 20),
                          const SizedBox(width: 10),
                          Text('Pause Challenge',
                              style: GoogleFonts.inter(
                                  color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'abandon',
                      child: Row(
                        children: [
                          const Icon(Icons.exit_to_app,
                              color: Colors.redAccent, size: 20),
                          const SizedBox(width: 10),
                          Text('End Challenge',
                              style: GoogleFonts.inter(
                                  color: Colors.redAccent, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              title: Text(
                active.challenge.title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),

            // ─── Progress Ring ─────────────────────────────
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: _buildProgressRing(active),
                ),
              ),
            ),

            // ─── Day Progress Bar ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ChallengeProgressBar(
                  currentDay: active.currentDay,
                  totalDays: active.challenge.durationDays,
                  activeColor: const Color(0xFFCABEFF),
                ),
              ),
            ),

            // ─── Motivation Quote ──────────────────────────
            if (todayDay != null)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1F2C).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFCABEFF).withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todayDay.title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        todayDay.motivation,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.white.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ─── Adaptive Hint ─────────────────────────────
            if (active.adaptationLevel == -1)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Text('💙', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Take it easy — just complete what you can today.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.blue.shade200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ─── Today's Tasks ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  children: [
                    Text(
                      "Today's Tasks",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: canComplete
                            ? const Color(0xFFCABEFF).withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_checkedCount / $totalTasks',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: canComplete
                              ? const Color(0xFF44E2CD)
                              : Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = tasks[index];
                    return ChallengeTaskCard(
                      task: task,
                      isChecked: _checkedTasks[task.id] ?? false,
                      onChanged: (val) {
                        setState(() => _checkedTasks[task.id] = val);
                      },
                    );
                  },
                  childCount: tasks.length,
                ),
              ),
            ),

            // ─── Metrics Footer ────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1F2C).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricItem('${(active.completionRate * 100).toInt()}%',
                        'Completion'),
                    _metricItem('${active.streakDays}', 'Streak'),
                    _metricItem(
                        '${(active.engagementScore * 100).toInt()}%', 'Engagement'),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),

        // ─── Complete Day CTA ────────────────────────────
        Positioned(
          left: 24,
          right: 24,
          bottom: 32,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = canComplete
                  ? 1.0 + (_pulseController.value * 0.02)
                  : 1.0;
              return Transform.scale(scale: scale, child: child);
            },
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (canComplete && !actionState.isLoading)
                    ? () => _completeDay(active)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canComplete
                      ? const Color(0xFFCABEFF)
                      : const Color(0xFF1B1F2C),
                  disabledBackgroundColor: const Color(0xFF1B1F2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: canComplete ? 8 : 0,
                  shadowColor: const Color(0xFFCABEFF).withOpacity(0.4),
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
                        canComplete
                            ? (percentage >= 1.0
                                ? '✨ Complete Day ${active.currentDay}'
                                : '⚡ Complete Day (${(percentage * 100).toInt()}%)')
                            : 'Complete at least 50% to continue',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: canComplete
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                        ),
                      ),
              ),
            ),
          ),
        ),

        // ─── Celebration Overlay ─────────────────────────
        if (_showCelebration) _buildCelebration(active),
      ],
    );
  }

  Widget _buildProgressRing(UserChallenge active) {
    final progress = active.challenge.durationDays > 0
        ? (active.currentDay - 1) / active.challenge.durationDays
        : 0.0;

    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _ProgressRingPainter(
                    progress: value,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    progressColor: const Color(0xFFCABEFF),
                  ),
                );
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Day',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              Text(
                '${active.currentDay}',
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                'of ${active.challenge.durationDays}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF44E2CD),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildCelebration(UserChallenge active) {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, _) {
        final opacity = _celebrationController.value < 0.8
            ? 1.0
            : 1.0 - ((_celebrationController.value - 0.8) / 0.2);

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Container(
            color: Colors.black.withOpacity(0.85),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Confetti-style particles
                  SizedBox(
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: List.generate(12, (i) {
                        final angle = (i / 12) * 2 * pi;
                        final radius = 40.0 * _celebrationController.value;
                        return Positioned(
                          left: 50 + cos(angle) * radius,
                          top: 50 + sin(angle) * radius,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: [
                                const Color(0xFFCABEFF),
                                const Color(0xFF44E2CD),
                                Colors.amber,
                                const Color(0xFF4FC3F7),
                              ][i % 4],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const Text('🎉', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 20),
                  Text(
                    'Day $_completedDayNumber Complete!',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _identityMessage(active.challenge.category),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF44E2CD),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _completeDay(UserChallenge active) async {
    final todayDay = active.todayDay;
    final totalTasks = todayDay?.tasks.length ?? 0;

    final result = await ref.read(challengeActionProvider.notifier).completeDay(
          userChallengeId: active.id,
          dayNumber: active.currentDay,
          tasksCompleted: _checkedCount,
          totalTasks: totalTasks,
        );

    if (result != null && mounted) {
      if (result.status == 'COMPLETED') {
        _showGrandFinaleDialog(active);
      } else {
        setState(() {
          _showCelebration = true;
          _completedDayNumber = active.currentDay;
          _checkedTasks.clear();
        });
        _celebrationController.forward(from: 0);

        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          setState(() => _showCelebration = false);
          ref.invalidate(activeChallengeProvider);
        }
      }
    }
  }

  void _handleMenuAction(String action, UserChallenge active) {
    if (action == 'pause') {
      ref.read(challengeActionProvider.notifier).abandonChallenge(
            userChallengeId: active.id,
            pause: true,
          );
      context.pop();
    } else if (action == 'abandon') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1B1F2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'End Challenge?',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            "You can always restart later. Your progress won't be lost.",
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Keep Going',
                style: GoogleFonts.inter(
                  color: const Color(0xFFCABEFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(challengeActionProvider.notifier).abandonChallenge(
                      userChallengeId: active.id,
                      pause: false,
                      reason: 'User chose to end',
                    );
                context.pop();
              },
              child: Text(
                'End Challenge',
                style: GoogleFonts.inter(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showGrandFinaleDialog(UserChallenge active) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xFF0F131F),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F131F),
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.elasticOut,
                      builder: (context, val, child) {
                        return Transform.scale(
                          scale: val,
                          child: const Text('🏆', style: TextStyle(fontSize: 120)),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Challenge\nCompleted!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'You successfully finished the ${active.challenge.title} challenge.\n\n${_identityMessage(active.challenge.category)}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 64),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          ref.invalidate(activeChallengeProvider); // Re-invalidate just in case
                          context.go('/challenges'); // Go to challenges tab
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCABEFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFFCABEFF).withOpacity(0.5),
                        ),
                        child: Text(
                          'Browse Other Challenges',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return FadeTransition(opacity: anim, child: child);
      },
    );
  }
}

// ─── Progress Ring Painter ───────────────────────────────────────
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _ProgressRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 10.0;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
