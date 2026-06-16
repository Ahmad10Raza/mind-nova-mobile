import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';

import '../constants/sleep_colors.dart';
import 'widgets/night_sky_background.dart';
import '../providers/sleep_log_provider.dart';
import '../providers/ritual_provider.dart';
import '../models/audio_category.dart';

class NightRoutineScreen extends ConsumerStatefulWidget {
  const NightRoutineScreen({super.key});

  @override
  ConsumerState<NightRoutineScreen> createState() => _NightRoutineScreenState();
}

class _NightRoutineScreenState extends ConsumerState<NightRoutineScreen> with TickerProviderStateMixin {
  int _currentStepIndex = 0;
  bool _isInitialized = false;

  // Audio players
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _breathingPlayer = AudioPlayer();

  // Breathing animation states
  late AnimationController _breathController;
  Timer? _routineTimer;
  int _timeRemaining = 120; 

  double _loggedDuration = 8.0;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), 
    );
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      await _breathingPlayer.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('Audio initialization error: $e');
    }
  }

  void _nextStep(List<PlaylistItem> ritual) {
    if (_currentStepIndex < ritual.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      _handleStepLogic(ritual[_currentStepIndex]);
    } else {
      _startLoggingSequence();
    }
  }

  void _handleStepLogic(PlaylistItem item) {
    _routineTimer?.cancel();
    _breathController.stop();

    if (item.interstitialType == 'breathing_timer') {
      _startBreathingSequence();
    } else {
      // For audio steps, we can just let them play or show a transition
    }
  }

  void _startBreathingSequence() {
    setState(() {
      _timeRemaining = 120;
    });
    try {
      _ambientPlayer.pause();
      _breathingPlayer.play(AssetSource('audio/breathing_timer.mp3'));
    } catch (_) {}

    _breathController.repeat(reverse: true);

    _routineTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining <= 1) {
        timer.cancel();
      } else {
        setState(() {
          _timeRemaining--;
        });
      }
    });
  }

  void _startLoggingSequence() {
    setState(() {
      _currentStepIndex = 999; // Final step marker
    });
    _breathController.stop();
    try {
      _breathingPlayer.stop();
      _ambientPlayer.resume();
    } catch (_) {}
  }

  void _finishRoutine() {
    _routineTimer?.cancel();
    _ambientPlayer.stop();
    _breathingPlayer.stop();
    context.pop();
  }

  void _saveLogAndFinish() {
    ref.read(sleepLogProvider.notifier).addLog(durationHours: _loggedDuration, quality: 4.0);
    _finishRoutine();
  }

  @override
  void dispose() {
    _routineTimer?.cancel();
    _breathController.dispose();
    _ambientPlayer.dispose();
    _breathingPlayer.dispose();
    super.dispose();
  }

  String get _breathingPhaseText {
    if (_breathController.status == AnimationStatus.forward) {
      return 'Breathe In...';
    } else {
      return 'Breathe Out...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ritual = ref.watch(ritualProvider);
    
    if (!_isInitialized && ritual.isNotEmpty) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleStepLogic(ritual[_currentStepIndex]);
      });
    }

    return Scaffold(
      backgroundColor: SleepColors.deepNavy,
      body: NightSkyBackground(
        animationValue: 0.0,
        showMoon: false,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: _finishRoutine,
                ),
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                child: _buildStepContent(ritual),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(List<PlaylistItem> ritual) {
    if (_currentStepIndex == 999) {
       return _buildLoggingView();
    }

    if (ritual.isEmpty || _currentStepIndex >= ritual.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final item = ritual[_currentStepIndex];

    switch (item.interstitialType) {
      case 'breathing_timer':
        return _buildBreathingView(ritual);
      case 'journal_prompt':
        return _buildJournalView(ritual);
      default:
        return _buildGenericStepView(item, ritual);
    }
  }

  Widget _buildBreathingView(List<PlaylistItem> ritual) {
    return Center(
      key: const ValueKey('breathing'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Moon Breathing',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text('Focus on your breath', style: GoogleFonts.inter(color: Colors.white70)),
          const SizedBox(height: 60),
          _buildBreathingOrb(),
          const SizedBox(height: 60),
          Text(
            '${(_timeRemaining ~/ 60)}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
            style: GoogleFonts.outfit(fontSize: 28, color: SleepColors.lavenderGlow),
          ),
          const SizedBox(height: 48),
          TextButton(
            onPressed: () => _nextStep(ritual),
            child: Text('Next Activity', style: GoogleFonts.inter(color: Colors.white30)),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingOrb() {
    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, child) {
        final scale = 1.0 + (_breathController.value * 0.4);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SleepColors.moonGold.withValues(alpha: 0.5 + _breathController.value * 0.3),
              boxShadow: [
                BoxShadow(
                  color: SleepColors.moonGold.withValues(alpha: 0.3),
                  blurRadius: 40 * _breathController.value,
                  spreadRadius: 10 * _breathController.value,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _breathingPhaseText,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: SleepColors.deepNavy),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJournalView(List<PlaylistItem> ritual) {
    return Center(
      key: const ValueKey('journal'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_note_rounded, color: SleepColors.moonGold, size: 60),
            const SizedBox(height: 24),
            Text('Evening Reflection', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Text('What is one thing you are proud of today?', textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => _nextStep(ritual),
              style: ElevatedButton.styleFrom(
                backgroundColor: SleepColors.darkPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('I\'ve Reflected'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericStepView(PlaylistItem item, List<PlaylistItem> ritual) {
    return Center(
      key: ValueKey(item.id),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Colors.white24, size: 64),
          const SizedBox(height: 32),
          Text(item.title, style: GoogleFonts.outfit(fontSize: 22, color: Colors.white)),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => _nextStep(ritual),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggingView() {
    return Center(
      key: const ValueKey('logging'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: SleepColors.glassCard,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               const Icon(Icons.bedtime_rounded, color: SleepColors.moonGold, size: 40),
               const SizedBox(height: 20),
              Text('Sleep Target', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 24),
              Text('${_loggedDuration.toStringAsFixed(1)} hours', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: SleepColors.lavenderGlow)),
              SliderTheme(
                data: SliderThemeData(activeTrackColor: SleepColors.moonGold, inactiveTrackColor: Colors.white12, thumbColor: SleepColors.lavenderGlow),
                child: Slider(
                  value: _loggedDuration,
                  min: 4.0, max: 12.0, divisions: 16,
                  onChanged: (v) => setState(() => _loggedDuration = v),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveLogAndFinish,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: SleepColors.darkPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save & Finish', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
