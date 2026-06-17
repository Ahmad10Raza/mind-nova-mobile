import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/breathing_model.dart';
import '../providers/breathing_provider.dart';

class BreathingExerciseScreen extends ConsumerStatefulWidget {
  final BreathingTechnique technique;
  const BreathingExerciseScreen({super.key, required this.technique});

  @override
  ConsumerState<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends ConsumerState<BreathingExerciseScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _breathingPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _breathingPlayer.setReleaseMode(ReleaseMode.loop);
    _breathingPlayer.play(AssetSource('audio/breathing_timer.mp3')).catchError((e) {
      debugPrint("Audio play error: $e");
    });

    Future.microtask(() {
      ref.read(breathingProvider.notifier).startSession(widget.technique);
      _updateAnimation();
    });
  }

  void _updateAnimation() {
    final state = ref.read(breathingProvider);
    if (!state.isActive) return;

    switch (state.currentPhase) {
      case BreathingPhase.inhale:
        _controller.duration = Duration(seconds: state.technique!.inhale);
        _controller.forward();
        break;
      case BreathingPhase.holdIn:
        _controller.stop();
        break;
      case BreathingPhase.exhale:
        _controller.duration = Duration(seconds: state.technique!.exhale);
        _controller.reverse();
        break;
      case BreathingPhase.holdOut:
        _controller.stop();
        break;
    }
  }

  void _handleSessionComplete() {
    _breathingPlayer.stop();
    _controller.stop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C), // AppColors.surfaceHighest equivalent
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Session Complete 🎉', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Great job taking a moment for yourself. Your internal resonance is stabilizing.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6), // AppColors.novaPurple equivalent
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context); // close dialog
              context.pop(); // go back to previous screen
            },
            child: const Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _breathingPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(breathingProvider);
    // Listen for phase changes or completion
    ref.listen(breathingProvider, (previous, next) {
      if (previous?.currentPhase != next.currentPhase) {
        _updateAnimation();
      }
      
      // Check for completion
      if (previous?.isActive == true && next.isActive == false) {
        _handleSessionComplete();
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _getPhaseColors(state.currentPhase),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              const Spacer(),
              _buildBreathingOrb(state),
              const SizedBox(height: 64),
              _buildPhaseText(state),
              const SizedBox(height: 12),
              _buildTimer(state),
              const Spacer(),
              _buildFooter(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () {
              _breathingPlayer.stop();
              ref.read(breathingProvider.notifier).stopSession();
              context.pop();
            },
          ),
          Text(
            widget.technique.name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48), // Spacer for centering
        ],
      ),
    );
  }

  Widget _buildBreathingOrb(BreathingState state) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 50,
                  spreadRadius: 20,
                ),
              ],
              gradient: const RadialGradient(
                colors: [Colors.white, Colors.white70, Colors.transparent],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhaseText(BreathingState state) {
    String text = '';
    switch (state.currentPhase) {
      case BreathingPhase.inhale: text = 'Breathe In'; break;
      case BreathingPhase.holdIn: text = 'Hold'; break;
      case BreathingPhase.exhale: text = 'Breathe Out'; break;
      case BreathingPhase.holdOut: text = 'Hold'; break;
    }
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildTimer(BreathingState state) {
    return Text(
      '${state.secondsRemaining}s',
      style: TextStyle(
        color: Colors.white.withOpacity(0.6),
        fontSize: 24,
      ),
    );
  }

  Widget _buildFooter(BreathingState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48.0),
      child: Text(
        'Cycles completed: ${state.totalCycles}',
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Color> _getPhaseColors(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)]; // Deep Blue to Light Blue
      case BreathingPhase.holdIn:
        return [const Color(0xFF4C1D95), const Color(0xFF8B5CF6)]; // Purple
      case BreathingPhase.exhale:
        return [const Color(0xFF065F46), const Color(0xFF10B981)]; // Deep Teal to Green
      case BreathingPhase.holdOut:
        return [const Color(0xFF78350F), const Color(0xFFF59E0B)]; // Amber
    }
  }
}
