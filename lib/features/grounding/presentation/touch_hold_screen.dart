import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/grounding_model.dart';
import '../providers/grounding_provider.dart';

class TouchHoldScreen extends ConsumerStatefulWidget {
  const TouchHoldScreen({super.key});

  @override
  ConsumerState<TouchHoldScreen> createState() => _TouchHoldScreenState();
}

class _TouchHoldScreenState extends ConsumerState<TouchHoldScreen>
    with TickerProviderStateMixin {
  bool _isHolding = false;
  int _holdSeconds = 0;
  int _messageIndex = 0;
  Timer? _holdTimer;

  late AnimationController _pulseController;
  late AnimationController _ringController;
  late Animation<double> _pulseAnim;
  late Animation<double> _ringAnim;

  final _messages = [
    "Feel your feet on the floor",
    "Relax your jaw",
    "Notice your breathing",
    "You are here right now",
    "You are safe",
    "Unclench your hands",
    "Let your shoulders drop",
    "Breathe slowly",
    "This moment is yours",
    "You are grounded",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeGroundingSessionProvider.notifier).start(GroundingExerciseType.touchHold);
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _ringAnim = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  void _startHolding() {
    setState(() => _isHolding = true);
    _pulseController.repeat(reverse: true);
    _holdTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _holdSeconds++;
        if (_holdSeconds % 4 == 0) {
          _messageIndex = (_messageIndex + 1) % _messages.length;
          // Ripple ring animation
          _ringController.forward(from: 0);
        }
      });
    });
  }

  void _stopHolding() {
    _holdTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    setState(() => _isHolding = false);
  }

  Future<void> _finishSession() async {
    _holdTimer?.cancel();
    await ref.read(activeGroundingSessionProvider.notifier).complete(
      completedFull: _holdSeconds >= 30,
    );
    if (mounted) context.pop();
  }

  String get _formattedTime {
    final m = _holdSeconds ~/ 60;
    final s = _holdSeconds % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _finishSession,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  Text(
                    "Touch & Hold",
                    style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F4C75).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formattedTime,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF38BDF8),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Affirmation message
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 700),
                      child: Text(
                        _isHolding ? _messages[_messageIndex] : "Press and hold the circle",
                        key: ValueKey(_isHolding ? _messageIndex : -1),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isHolding ? "Keep holding..." : "Stay as long as you need",
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                  ),
                  const SizedBox(height: 60),

                  // Glowing orb
                  AnimatedBuilder(
                    animation: Listenable.merge([_pulseAnim, _ringAnim]),
                    builder: (_, __) {
                      return SizedBox(
                        width: 280,
                        height: 280,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ripple ring
                            if (_isHolding)
                              Container(
                                width: 200 * _ringAnim.value,
                                height: 200 * _ringAnim.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF1B6CA8).withOpacity(
                                    (1 - _ringAnim.value * 0.7).clamp(0.0, 1.0),
                                  ),
                                ),
                              ),
                            // Main orb
                            GestureDetector(
                              onLongPressStart: (_) => _startHolding(),
                              onLongPressEnd: (_) => _stopHolding(),
                              onTapDown: (_) => _startHolding(),
                              onTapUp: (_) => _stopHolding(),
                              onTapCancel: _stopHolding,
                              child: Transform.scale(
                                scale: _isHolding ? _pulseAnim.value : 1.0,
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: _isHolding
                                          ? [const Color(0xFF38BDF8), const Color(0xFF0F4C75)]
                                          : [const Color(0xFF1E3A5F), const Color(0xFF0A0F1E)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0D9488).withOpacity(
                                          _isHolding ? 0.6 : 0.2,
                                        ),
                                        blurRadius: _isHolding ? 60 : 20,
                                        spreadRadius: _isHolding ? 20 : 4,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isHolding ? Icons.favorite_rounded : Icons.touch_app_rounded,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      if (_isHolding) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          _formattedTime,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom finish button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _finishSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C75),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    _holdSeconds >= 30 ? "I feel grounded ✓" : "End Session",
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
