import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/grounding_model.dart';
import '../providers/grounding_provider.dart';

class _BodyPart {
  final String name;
  final String instruction;
  final IconData icon;
  const _BodyPart(this.name, this.instruction, this.icon);
}

final _bodyParts = [
  _BodyPart("Forehead", "Smooth out your forehead. Let any tension melt away.", Icons.face_rounded),
  _BodyPart("Jaw", "Unclench your jaw. Let your mouth hang slightly open.", Icons.sentiment_neutral_rounded),
  _BodyPart("Neck", "Roll your neck gently. Release any tightness.", Icons.accessibility_rounded),
  _BodyPart("Shoulders", "Drop your shoulders away from your ears. Breathe.", Icons.accessibility_new_rounded),
  _BodyPart("Hands", "Uncurl your fingers. Feel the air on your palms.", Icons.back_hand_rounded),
  _BodyPart("Chest", "Take a slow breath in. Feel your chest expand.", Icons.favorite_border_rounded),
  _BodyPart("Legs", "Notice your legs. Let them feel heavy and relaxed.", Icons.airline_seat_legroom_reduced_rounded),
  _BodyPart("Feet", "Feel the floor beneath your feet. You are here.", Icons.nordic_walking_rounded),
];

class BodyScanScreen extends ConsumerStatefulWidget {
  const BodyScanScreen({super.key});

  @override
  ConsumerState<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends ConsumerState<BodyScanScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _completed = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeGroundingSessionProvider.notifier).start(GroundingExerciseType.bodyScan);
    });
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < _bodyParts.length - 1) {
      setState(() => _currentIndex++);
    } else {
      setState(() => _completed = true);
    }
  }

  Future<void> _finish() async {
    await ref.read(activeGroundingSessionProvider.notifier).complete(completedFull: _completed);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final part = _bodyParts[_currentIndex];
    final progress = (_currentIndex + 1) / _bodyParts.length;

    if (_completed) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0F1E),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("🌿", style: const TextStyle(fontSize: 72)),
                const SizedBox(height: 24),
                Text(
                  "Your body scan is complete",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "You released tension from head to feet.\nNotice how you feel right now.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _finish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text("Done", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _finish,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  Text("Body Scan", style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("${_currentIndex + 1}/${_bodyParts.length}", style: GoogleFonts.inter(color: const Color(0xFF5EEAD4), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF0D9488)),
                  minHeight: 4,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Body Part Indicator
                  AnimatedBuilder(
                    animation: _glowAnim,
                    builder: (_, __) => Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0D9488).withOpacity(0.15),
                        border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.4), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0D9488).withOpacity(_glowAnim.value),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(part.icon, color: const Color(0xFF5EEAD4), size: 52),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      part.name,
                      key: ValueKey(_currentIndex),
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF5EEAD4),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        part.instruction,
                        key: ValueKey("inst_$_currentIndex"),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Visual body part list
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _bodyParts.length,
                      itemBuilder: (_, i) => Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= _currentIndex
                              ? const Color(0xFF0D9488)
                              : Colors.white.withOpacity(0.08),
                          border: Border.all(
                            color: i == _currentIndex
                                ? const Color(0xFF5EEAD4)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _bodyParts[i].icon,
                          color: i <= _currentIndex ? Colors.white : Colors.white24,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    _currentIndex < _bodyParts.length - 1 ? "Next Area" : "Complete",
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
