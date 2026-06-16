import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constants/sleep_colors.dart';
import 'widgets/night_sky_background.dart';
import 'widgets/moon_breathing_widget.dart';

/// Night-themed breathing exercise screen with animated moon orb.
class SleepBreathingScreen extends StatefulWidget {
  const SleepBreathingScreen({super.key});

  @override
  State<SleepBreathingScreen> createState() => _SleepBreathingScreenState();
}

class _SleepBreathingScreenState extends State<SleepBreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _breathController;
  final AudioPlayer _breathingPlayer = AudioPlayer();

  int _selectedTechniqueIndex = 0;
  bool _isActive = false;
  int _completedCycles = 0;
  String _currentPhase = 'Breathe In';
  int _phaseSeconds = 4;
  Timer? _phaseTimer;

  final List<Map<String, dynamic>> _techniques = [
    {'name': '4-7-8 Breathing', 'inhale': 4, 'hold': 7, 'exhale': 8, 'holdOut': 0, 'icon': Icons.nights_stay_rounded},
    {'name': 'Box Breathing', 'inhale': 4, 'hold': 4, 'exhale': 4, 'holdOut': 4, 'icon': Icons.crop_square_rounded},
    {'name': 'Deep Belly', 'inhale': 5, 'hold': 2, 'exhale': 7, 'holdOut': 0, 'icon': Icons.self_improvement_rounded},
    {'name': 'Calm Heartbeat', 'inhale': 3, 'hold': 0, 'exhale': 6, 'holdOut': 0, 'icon': Icons.favorite_rounded},
    {'name': 'Muscle Relaxation', 'inhale': 5, 'hold': 5, 'exhale': 10, 'holdOut': 0, 'icon': Icons.spa_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _breathingPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _breathController.dispose();
    _phaseTimer?.cancel();
    _breathingPlayer.dispose();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _completedCycles = 0;
    });
    _breathingPlayer.play(AssetSource('audio/breathing_timer.mp3'));
    _runPhase('inhale');
  }

  void _stopBreathing() {
    _phaseTimer?.cancel();
    _breathController.stop();
    _breathingPlayer.stop();
    setState(() {
      _isActive = false;
      _currentPhase = 'Breathe In';
    });
  }

  void _runPhase(String phase) {
    final tech = _techniques[_selectedTechniqueIndex];
    int duration;
    String displayText;

    switch (phase) {
      case 'inhale':
        duration = tech['inhale'];
        displayText = 'Breathe In';
        _breathController.duration = Duration(seconds: duration);
        _breathController.forward(from: 0);
        break;
      case 'hold':
        duration = tech['hold'];
        displayText = 'Hold';
        if (duration == 0) { _runPhase('exhale'); return; }
        break;
      case 'exhale':
        duration = tech['exhale'];
        displayText = 'Breathe Out';
        _breathController.duration = Duration(seconds: duration);
        _breathController.reverse(from: 1);
        break;
      case 'holdOut':
        duration = tech['holdOut'];
        displayText = 'Hold';
        if (duration == 0) {
          setState(() => _completedCycles++);
          _runPhase('inhale');
          return;
        }
        break;
      default:
        return;
    }

    setState(() {
      _currentPhase = displayText;
      _phaseSeconds = duration;
    });

    // Haptic on phase change
    HapticFeedback.lightImpact();

    // Countdown timer
    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_phaseSeconds <= 1) {
        timer.cancel();
        // Transition to next phase
        switch (phase) {
          case 'inhale': _runPhase('hold'); break;
          case 'hold': _runPhase('exhale'); break;
          case 'exhale': _runPhase('holdOut'); break;
          case 'holdOut':
            setState(() => _completedCycles++);
            _runPhase('inhale');
            break;
        }
      } else {
        setState(() => _phaseSeconds--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SleepColors.midnightBlack,
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          return NightSkyBackground(
            animationValue: _bgController.value,
            showMoon: false, // The breathing widget IS the moon
            child: SafeArea(
              child: Column(
                children: [
                  // ─── App Bar ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: SleepColors.textSecondary),
                          onPressed: () {
                            _stopBreathing();
                            Navigator.pop(context);
                          },
                        ),
                        const Spacer(),
                        Text(
                          _techniques[_selectedTechniqueIndex]['name'],
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: SleepColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // ─── Technique Selector ─────────────────────
                  if (!_isActive)
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _techniques.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final isSelected = i == _selectedTechniqueIndex;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedTechniqueIndex = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? SleepColors.lavenderGlow.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: isSelected
                                      ? SleepColors.lavenderGlow.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _techniques[i]['icon'],
                                    size: 16,
                                    color: isSelected ? SleepColors.lavenderGlow : SleepColors.textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _techniques[i]['name'],
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? SleepColors.textPrimary : SleepColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const Spacer(),

                  // ─── Moon Breathing Orb ─────────────────────
                  AnimatedBuilder(
                    animation: _breathController,
                    builder: (context, _) {
                      return MoonBreathingWidget(
                        breathProgress: _breathController.value,
                        phaseText: _isActive ? _currentPhase : 'Tap to Begin',
                        secondsRemaining: _isActive ? _phaseSeconds : 0,
                      );
                    },
                  ),

                  const Spacer(),

                  // ─── Control Button ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _isActive ? _stopBreathing : _startBreathing,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            decoration: BoxDecoration(
                              gradient: _isActive ? null : SleepColors.ctaGradient,
                              color: _isActive ? Colors.white.withOpacity(0.1) : null,
                              borderRadius: BorderRadius.circular(100),
                              border: _isActive
                                  ? Border.all(color: Colors.white.withOpacity(0.2))
                                  : null,
                            ),
                            child: Text(
                              _isActive ? 'Stop' : 'Begin Breathing',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (_isActive) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Cycles: $_completedCycles',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: SleepColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
