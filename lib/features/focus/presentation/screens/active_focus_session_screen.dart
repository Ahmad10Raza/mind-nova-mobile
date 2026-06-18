import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/focus_provider.dart';
import '../../models/focus_model.dart';
import '../widgets/zen_timer_ring.dart';
import 'package:mind_nova_mobile/core/constants/app_colors.dart';

class ActiveFocusSessionScreen extends ConsumerStatefulWidget {
  const ActiveFocusSessionScreen({super.key});

  @override
  ConsumerState<ActiveFocusSessionScreen> createState() => _ActiveFocusSessionScreenState();
}

class _ActiveFocusSessionScreenState extends ConsumerState<ActiveFocusSessionScreen> {
  @override
  Widget build(BuildContext context) {
    final focusState = ref.watch(focusProvider);
    
    ref.listen(focusProvider, (prev, next) {
      if (prev != null && prev.isRunning && !next.isRunning && next.remainingSeconds == 0) {
        Future.microtask(() {
          if (context.mounted) {
            context.go('/focus/completion', extra: prev.activeSession);
          }
        });
      }
    });

    // Auto-exit if session ends abruptly
    if (focusState.activeSession == null && !focusState.isLoading) {
      Future.microtask(() => context.go('/focus'));
    }

    final remaining = focusState.remainingSeconds;
    final total = (focusState.activeSession?.durationMinutes ?? 1) * 60;
    final progress = total > 0 ? remaining / total : 0.0;
    
    final minutes = (remaining / 60).floor();
    final seconds = remaining % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _showExitWarning();
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: BreathingPulse()),
              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(focusState),
                    const Spacer(),
                    Hero(
                      tag: 'focus_orb',
                      child: ZenTimerRing(
                        progress: progress,
                        timeString: timeString,
                      ),
                    ),
                    const Spacer(),
                    _buildIntentCard(focusState),
                    const Spacer(),
                    _buildActions(focusState),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(FocusState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.activeSession?.mode.displayName.toUpperCase() ?? 'FOCUS',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  letterSpacing: 2,
                  color: Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.shield_moon_rounded, color: Color(0xFF818CF8), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Zen Shield Active',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: const Color(0xFF818CF8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${state.deviceInterrupted}',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntentCard(FocusState state) {
    if (state.activeSession?.goal == null || state.activeSession!.goal!.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: Colors.white24, size: 20),
          const SizedBox(height: 12),
          Text(
            state.activeSession!.goal!,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(FocusState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: state.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            label: state.isPaused ? 'RESUME' : 'PAUSE',
            onTap: () {
              HapticFeedback.mediumImpact();
              if (state.isPaused) {
                ref.read(focusProvider.notifier).resumeSession();
              } else {
                ref.read(focusProvider.notifier).pauseSession();
              }
            },
          ),
          _buildActionButton(
            icon: Icons.sos_rounded,
            label: 'RESCUE',
            color: Colors.orange.withOpacity(0.2),
            iconColor: Colors.orange,
            onTap: () {
              HapticFeedback.heavyImpact();
              _showRescueMode();
            },
          ),
          _buildActionButton(
            icon: Icons.stop_rounded,
            label: 'QUIT',
            onTap: _showExitWarning,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    Color? iconColor,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color ?? Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: iconColor ?? Colors.white70, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            letterSpacing: 1,
            color: Colors.white38,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showRescueMode() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RescueModeSheet(),
    );
  }

  void _showExitWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Break your flow?', style: GoogleFonts.outfit(color: Colors.white)),
        content: Text(
          'You\'re doing great. Stay just a bit longer to protect your streak.',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('STAY', style: GoogleFonts.outfit(color: AppColors.primaryPurpleLight)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(focusProvider.notifier).endSession();
              context.go('/focus');
            },
            child: Text('QUIT SESSION', style: GoogleFonts.outfit(color: Colors.white38)),
          ),
        ],
      ),
    );
  }
}

class BreathingPulse extends StatefulWidget {
  const BreathingPulse({super.key});

  @override
  State<BreathingPulse> createState() => _BreathingPulseState();
}

class _BreathingPulseState extends State<BreathingPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
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
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                const Color(0xFF6366F1).withOpacity(0.08 * _controller.value),
                Colors.transparent,
              ],
              radius: 0.5 + (_controller.value * 0.4),
            ),
          ),
        );
      },
    );
  }
}

class RescueModeSheet extends ConsumerStatefulWidget {
  const RescueModeSheet({super.key});

  @override
  ConsumerState<RescueModeSheet> createState() => _RescueModeSheetState();
}

class _RescueModeSheetState extends ConsumerState<RescueModeSheet> {
  int _step = 1;

  @override
  Widget build(BuildContext context) {
    // Scaffold/Material needed for TextField, but bottom sheet provides Material.
    // Wrap in Scaffold with transparent background to handle keyboard properly.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 32),
                Expanded(
                  child: _step == 1 ? _buildStep1() : _step == 2 ? _buildStep2() : _buildStep3(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        const Icon(Icons.anchor_rounded, color: Colors.orange, size: 48),
        const SizedBox(height: 24),
        Text(
          'WHAT IS WEIGHING ON YOU?',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          'Admit the big, scary task. Naming it takes away its power.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: Colors.white60),
        ),
        const SizedBox(height: 32),
        TextField(
          decoration: InputDecoration(
            hintText: 'e.g. Finishing this report...',
            hintStyle: TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const Spacer(),
        _buildNextButton('CONTINUE', () => setState(() => _step = 2)),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        const Icon(Icons.bolt_rounded, color: Colors.blue, size: 48),
        const SizedBox(height: 24),
        Text(
          'THE TINIEST STEP',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          'What can you do in 60 seconds? Just one tiny thing.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: Colors.white60),
        ),
        const SizedBox(height: 32),
        TextField(
          decoration: InputDecoration(
            hintText: 'e.g. Open the document...',
            hintStyle: TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const Spacer(),
        _buildNextButton('SET SPRINT', () => setState(() => _step = 3)),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        const Icon(Icons.rocket_launch_rounded, color: Color(0xFFA855F7), size: 48),
        const SizedBox(height: 24),
        Text(
          '3-MINUTE ACTIVATION',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          'Focus ONLY on that tiny step for 3 minutes. That\'s it.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: Colors.white60),
        ),
        const Spacer(),
        _buildNextButton('START SPRINT', () {
          Navigator.pop(context);
          ref.read(focusProvider.notifier).startRescueSprint();
        }),
      ],
    );
  }

  Widget _buildNextButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: Text(label),
      ),
    );
  }
}
