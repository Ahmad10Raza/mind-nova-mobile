import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/grounding_model.dart';
import '../providers/grounding_provider.dart';

class PanicResetScreen extends ConsumerStatefulWidget {
  const PanicResetScreen({super.key});

  @override
  ConsumerState<PanicResetScreen> createState() => _PanicResetScreenState();
}

class _PanicResetScreenState extends ConsumerState<PanicResetScreen>
    with TickerProviderStateMixin {
  static const _duration = 60;
  int _secondsLeft = _duration;
  int _messageIndex = 0;
  bool _completed = false;
  Timer? _countdownTimer;

  final _reassurances = [
    "You are safe.",
    "This feeling will pass.",
    "Stay with me for a moment.",
    "Breathe slowly. In and out.",
    "Look around the room.",
    "Name one thing you can see.",
    "Relax your shoulders.",
    "Unclench your jaw gently.",
    "You are okay. You are here.",
    "This moment will pass.",
  ];

  late AnimationController _pulseController;
  late AnimationController _ringController;
  late Animation<double> _pulseAnim;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(activeGroundingSessionProvider.notifier).start(GroundingExerciseType.panicReset);
    });

    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _ringController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _ringAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
          _messageIndex = ((_duration - _secondsLeft) ~/ (_duration / _reassurances.length))
              .clamp(0, _reassurances.length - 1);
        } else {
          timer.cancel();
          _completed = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  Future<void> _finishSession() async {
    _countdownTimer?.cancel();
    await ref.read(activeGroundingSessionProvider.notifier).complete(completedFull: _completed);
    if (mounted) context.pop();
  }

  void _showCrisisModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A0A3B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("You are not alone 💙", style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Here are some immediate ways to get support:", style: GoogleFonts.inter(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 24),
            _buildCrisisOption(ctx, Icons.mic_rounded, "Talk to Nova AI", "Chat with your AI companion", const Color(0xFF7C3AED), () => context.push('/chat')),
            const SizedBox(height: 12),
            _buildCrisisOption(ctx, Icons.phone_rounded, "Call Crisis Line", "iCall: 9152987821", const Color(0xFF0D9488), () {}),
            const SizedBox(height: 12),
            _buildCrisisOption(ctx, Icons.contacts_rounded, "Trusted Contact", "Reach someone who cares", const Color(0xFF0369A1), () {}),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildCrisisOption(BuildContext ctx, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () { Navigator.pop(ctx); onTap(); },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_duration - _secondsLeft) / _duration;

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
                    onTap: _finishSession,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  Text("Panic Reset", style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text("$_secondsLeft s", style: GoogleFonts.outfit(color: const Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
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
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)),
                  minHeight: 4,
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pulsing orb
                    AnimatedBuilder(
                      animation: _ringAnim,
                      builder: (_, child) => Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring
                          Container(
                            width: 200 * _ringAnim.value,
                            height: 200 * _ringAnim.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF7C3AED).withOpacity(0.06),
                            ),
                          ),
                          ScaleTransition(
                            scale: _pulseAnim,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [Color(0xFF9D4EDD), Color(0xFF4F46E5)],
                                ),
                                boxShadow: [
                                  BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.5), blurRadius: 40, spreadRadius: 10),
                                ],
                              ),
                              child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 48),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        _reassurances[_messageIndex],
                        key: ValueKey(_messageIndex),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  if (_completed) ...[
                    Text("You made it through 60 seconds. 💙", style: GoogleFonts.inter(color: Colors.white60, fontSize: 14), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
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
                        child: Text("I feel calmer", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _showCrisisModal,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF87171),
                        side: const BorderSide(color: Color(0xFFF87171), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text("I still need help", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
