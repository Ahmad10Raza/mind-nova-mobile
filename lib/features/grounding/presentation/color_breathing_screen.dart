import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/grounding_model.dart';
import '../providers/grounding_provider.dart';

class _BreathPhase {
  final String label;
  final String instruction;
  final int durationSecs;
  final Color color;
  final Color bgColor;

  const _BreathPhase(this.label, this.instruction, this.durationSecs, this.color, this.bgColor);
}

final _phases = [
  _BreathPhase("INHALE", "Breathe in. Draw in calm blue.", 4, Color(0xFF38BDF8), Color(0xFF0C1A2E)),
  _BreathPhase("HOLD", "Hold gently. Embrace soft purple.", 4, Color(0xFF818CF8), Color(0xFF1A0A3B)),
  _BreathPhase("EXHALE", "Let it go. Release the red.", 6, Color(0xFFF87171), Color(0xFF1F0A0A)),
  _BreathPhase("RESTORE", "Rest. Peaceful green fills you.", 3, Color(0xFF34D399), Color(0xFF042414)),
];

class ColorBreathingScreen extends ConsumerStatefulWidget {
  const ColorBreathingScreen({super.key});

  @override
  ConsumerState<ColorBreathingScreen> createState() => _ColorBreathingScreenState();
}

class _ColorBreathingScreenState extends ConsumerState<ColorBreathingScreen>
    with TickerProviderStateMixin {
  int _phaseIndex = 0;
  int _phaseSecs = 0;
  int _cycleCount = 0;
  Timer? _timer;

  late AnimationController _circleController;
  late AnimationController _bgController;
  late Animation<double> _circleAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeGroundingSessionProvider.notifier).start(GroundingExerciseType.colorBreathing);
    });

    _circleController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _bgController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _circleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );

    _startPhase();
  }

  void _startPhase() {
    final phase = _phases[_phaseIndex];
    _phaseSecs = phase.durationSecs;
    _bgController.forward(from: 0);

    if (_phaseIndex == 0 || _phaseIndex == 2) {
      _circleController.forward(from: _phaseIndex == 0 ? 0 : 1);
    } else if (_phaseIndex == 1) {
      // Hold: keep inflated
    } else {
      _circleController.reverse();
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_phaseSecs > 0) {
          _phaseSecs--;
        } else {
          t.cancel();
          _phaseIndex = (_phaseIndex + 1) % _phases.length;
          if (_phaseIndex == 0) _cycleCount++;
          _startPhase();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _circleController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _finishSession() async {
    _timer?.cancel();
    await ref.read(activeGroundingSessionProvider.notifier).complete(completedFull: _cycleCount >= 3);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final phase = _phases[_phaseIndex];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      color: phase.bgColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _finishSession,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  Text("Color Breathing", style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                    child: Text("Cycle ${_cycleCount + 1}", style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _circleAnim,
                      builder: (_, __) {
                        final size = 100.0 + (140 * _circleAnim.value);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: phase.color.withOpacity(0.15),
                            border: Border.all(color: phase.color.withOpacity(0.6), width: 3),
                            boxShadow: [
                              BoxShadow(color: phase.color.withOpacity(0.4), blurRadius: 60, spreadRadius: 20),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        key: ValueKey(_phaseIndex),
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: phase.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: phase.color.withOpacity(0.3)),
                            ),
                            child: Text(
                              phase.label,
                              style: GoogleFonts.inter(color: phase.color, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            phase.instruction,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500, height: 1.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "${_phaseSecs}s",
                            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _finishSession,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white60,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text("End Session", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
