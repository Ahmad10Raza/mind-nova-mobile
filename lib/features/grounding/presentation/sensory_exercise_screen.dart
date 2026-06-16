import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/grounding_model.dart';
import '../providers/grounding_provider.dart';

class _SensoryStep {
  final int count;
  final String sense;
  final String instruction;
  final IconData icon;
  final Color color;
  const _SensoryStep(this.count, this.sense, this.instruction, this.icon, this.color);
}

final _steps = [
  _SensoryStep(5, "SEE", "Look around. Name 5 things you can see right now.", Icons.visibility_rounded, Color(0xFF0D9488)),
  _SensoryStep(4, "TOUCH", "Move your fingers. Name 4 things you can physically touch.", Icons.touch_app_rounded, Color(0xFF7C3AED)),
  _SensoryStep(3, "HEAR", "Be still. Name 3 sounds you can hear right now.", Icons.hearing_rounded, Color(0xFF0369A1)),
  _SensoryStep(2, "SMELL", "Breathe in gently. Name 2 things you can smell.", Icons.air_rounded, Color(0xFF059669)),
  _SensoryStep(1, "TASTE", "Focus. Name 1 thing you can taste.", Icons.restaurant_menu_rounded, Color(0xFFB45309)),
];

class SensoryExerciseScreen extends ConsumerStatefulWidget {
  const SensoryExerciseScreen({super.key});

  @override
  ConsumerState<SensoryExerciseScreen> createState() => _SensoryExerciseScreenState();
}

class _SensoryExerciseScreenState extends ConsumerState<SensoryExerciseScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _completed = false;
  double _calmBefore = 5;
  double _calmAfter = 5;

  late AnimationController _numberController;
  late AnimationController _pulseController;
  late Animation<double> _numberAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(activeGroundingSessionProvider.notifier).start(GroundingExerciseType.sensory54321);
    });

    _numberController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

    _numberAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _numberController, curve: Curves.elasticOut),
    );
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _numberController.forward();
  }

  @override
  void dispose() {
    _numberController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
      _numberController.reset();
      _numberController.forward();
    } else {
      setState(() => _completed = true);
    }
  }

  Future<void> _finishSession() async {
    await ref.read(activeGroundingSessionProvider.notifier).complete(
      calmBefore: _calmBefore.round(),
      calmAfter: _calmAfter.round(),
      wouldRepeat: true,
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: SafeArea(
        child: _completed ? _buildCompletionScreen() : _buildExerciseScreen(),
      ),
    );
  }

  Widget _buildExerciseScreen() {
    final step = _steps[_currentStep];
    final progress = (_currentStep + 1) / _steps.length;

    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () { ref.read(activeGroundingSessionProvider.notifier).abandon(); context.pop(); },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                ),
              ),
              Text("5-4-3-2-1 Grounding", style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.w600)),
              Text("${_currentStep + 1}/5", style: GoogleFonts.inter(color: step.color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(step.color),
              minHeight: 4,
            ),
          ),
        ),

        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Large animated number
              ScaleTransition(
                scale: _pulseAnim,
                child: ScaleTransition(
                  scale: _numberAnim,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: step.color.withOpacity(0.15),
                      border: Border.all(color: step.color.withOpacity(0.4), width: 2),
                      boxShadow: [
                        BoxShadow(color: step.color.withOpacity(0.3), blurRadius: 40, spreadRadius: 8),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${step.count}",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(step.icon, color: step.color, size: 24),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: step.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: step.color.withOpacity(0.3)),
                ),
                child: Text(
                  step.sense,
                  style: GoogleFonts.inter(
                    color: step.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  step.instruction,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Next button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: step.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                _currentStep < _steps.length - 1 ? "Next" : "Complete",
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionScreen() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("🌿", style: TextStyle(fontSize: 72)),
          const SizedBox(height: 24),
          Text(
            "You completed the grounding exercise",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Take a breath. How do you feel?",
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 15),
          ),
          const SizedBox(height: 48),
          Text("Anxiety before:", style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Slider(
            value: _calmBefore,
            min: 1,
            max: 10,
            divisions: 9,
            label: _calmBefore.round().toString(),
            activeColor: const Color(0xFF7C3AED),
            inactiveColor: Colors.white12,
            onChanged: (v) => setState(() => _calmBefore = v),
          ),
          const SizedBox(height: 16),
          Text("Calm now (1–10):", style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Slider(
            value: _calmAfter,
            min: 1,
            max: 10,
            divisions: 9,
            label: _calmAfter.round().toString(),
            activeColor: const Color(0xFF0D9488),
            inactiveColor: Colors.white12,
            onChanged: (v) => setState(() => _calmAfter = v),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _finishSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text("Save & Finish", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
