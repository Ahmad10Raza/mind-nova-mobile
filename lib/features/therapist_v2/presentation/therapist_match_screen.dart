import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../therapist/models/therapist_model.dart';
import '../../therapist/providers/therapist_provider.dart';

// Colors & Constants
const _backgroundDeep = Color(0xFF0F131F);
const _primaryColor = Color(0xFFE6DEFF);
const _secondaryColor = Color(0xFF40E0CB);
const _glassBorder = Color.fromRGBO(53, 57, 70, 0.3);

class TherapistMatchScreen extends ConsumerStatefulWidget {
  const TherapistMatchScreen({super.key});

  @override
  ConsumerState<TherapistMatchScreen> createState() => _TherapistMatchScreenState();
}

class _TherapistMatchScreenState extends ConsumerState<TherapistMatchScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _isAnalyzing = false;
  TherapistProfile? _matchedTherapist;

  // Answers
  String? _focusAnswer;
  String? _styleAnswer;
  String? _modeAnswer;

  late final AnimationController _glowController;

  final List<Map<String, dynamic>> _questions = [
    {
      'title': 'What is your main goal right now?',
      'subtitle': 'Select the area you want to focus on.',
      'options': ['Anxiety management', 'Relationship advice', 'Career stress', 'Personal growth'],
    },
    {
      'title': 'What approach resonates with you?',
      'subtitle': 'How would you like your therapist to work with you?',
      'options': ['Cognitive Behavioral', 'Mindfulness-based', 'Solution-focused', 'Open exploration'],
    },
    {
      'title': 'How do you prefer to connect?',
      'subtitle': 'Select your primary communication method.',
      'options': ['Video calls', 'Voice only', 'Text / Chat'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _questions.length - 1) {
      setState(() => _currentStep++);
    } else {
      _runMatchingAlgorithm();
    }
  }

  void _runMatchingAlgorithm() async {
    setState(() => _isAnalyzing = true);
    
    // Simulate AI thinking delay
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Fetch therapists from provider
    final therapistsAsyncValue = ref.read(featuredTherapistsProvider);
    
    therapistsAsyncValue.whenData((therapists) {
      if (therapists.isNotEmpty) {
        // Mock logic: Just pick a random one or the first one for now,
        // but ideally this would weigh their tags against the answers.
        // Let's pretend Dr. Sarah Jenkins is always the best match if available, or just shuffle.
        final random = Random();
        setState(() {
          _matchedTherapist = therapists[random.nextInt(therapists.length)];
          _isAnalyzing = false;
          _currentStep++; // Move to result step
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundDeep,
      body: Stack(
        children: [
          // Background Glows
          Positioned(top: -100, right: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120), child: const SizedBox()))),
          Positioned(bottom: -50, left: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: const SizedBox()))),
          
          // Cosmic Particles
          const Positioned.fill(child: _ParticleBackground()),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _isAnalyzing
                        ? _buildAnalyzingState()
                        : _currentStep >= _questions.length
                            ? _buildResultState()
                            : _buildQuestionState(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: _primaryColor),
            onPressed: () {
              if (_currentStep > 0 && !_isAnalyzing && _currentStep < _questions.length) {
                setState(() => _currentStep--);
              } else {
                context.pop();
              }
            },
          ),
          Expanded(
            child: Text(
              _currentStep < _questions.length ? 'Step ${_currentStep + 1} of ${_questions.length}' : 'Match Found',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFFC9C4D0)),
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildQuestionState() {
    final question = _questions[_currentStep];
    final options = question['options'] as List<String>;
    
    String? currentAnswer;
    if (_currentStep == 0) currentAnswer = _focusAnswer;
    if (_currentStep == 1) currentAnswer = _styleAnswer;
    if (_currentStep == 2) currentAnswer = _modeAnswer;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: _secondaryColor),
              const SizedBox(width: 8),
              Text('Nova AI Matchmaker', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _secondaryColor)),
            ],
          ),
          const SizedBox(height: 16),
          Text(question['title'], style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2, color: _primaryColor)),
          const SizedBox(height: 12),
          Text(question['subtitle'], style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFC9C4D0))),
          const SizedBox(height: 48),
          
          ...options.map((option) {
            final isSelected = currentAnswer == option;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (_currentStep == 0) _focusAnswer = option;
                    if (_currentStep == 1) _styleAnswer = option;
                    if (_currentStep == 2) _modeAnswer = option;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor.withValues(alpha: 0.1) : const Color(0xFF1B1F2C).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? _primaryColor : _glassBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(option, style: GoogleFonts.inter(fontSize: 16, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? _primaryColor : Colors.white))),
                      if (isSelected) const Icon(Icons.check_circle, color: _primaryColor),
                    ],
                  ),
                ),
              ),
            );
          }),
          
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: currentAnswer == null ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                disabledBackgroundColor: const Color(0xFF353946).withValues(alpha: 0.5),
                foregroundColor: const Color(0xFF32285E),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(_currentStep == _questions.length - 1 ? 'Find My Match' : 'Continue', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: _primaryColor.withValues(alpha: 0.2 * _glowController.value), blurRadius: 40, spreadRadius: 20),
                    BoxShadow(color: _secondaryColor.withValues(alpha: 0.1 * _glowController.value), blurRadius: 60, spreadRadius: 40),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, size: 64, color: _primaryColor),
              );
            },
          ),
          const SizedBox(height: 48),
          Text('Nova is analyzing your aura...', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: _primaryColor)),
          const SizedBox(height: 16),
          Text('Finding the perfect guide for your journey.', style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFC9C4D0))),
        ],
      ),
    );
  }

  Widget _buildResultState() {
    if (_matchedTherapist == null) {
      return Center(child: Text('No match found. Please try again.', style: TextStyle(color: Colors.white)));
    }

    final t = _matchedTherapist!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('We found your match!', style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2, color: _primaryColor)),
          const SizedBox(height: 12),
          Text('Based on your focus on $_focusAnswer, this guide is perfectly aligned with your needs.', style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFC9C4D0), height: 1.5)),
          const SizedBox(height: 48),
          
          // Match Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: _secondaryColor.withValues(alpha: 0.3)),
              boxShadow: [BoxShadow(color: _secondaryColor.withValues(alpha: 0.05), blurRadius: 40, spreadRadius: 10)],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text('98% Compatibility', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _secondaryColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(t.imageUrl ?? '', width: 120, height: 120, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 120, height: 120, color: Colors.grey)),
                ),
                const SizedBox(height: 16),
                Text(t.name, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(t.title, style: GoogleFonts.inter(fontSize: 14, color: _secondaryColor)),
                const SizedBox(height: 24),
                Text('Specializes in ${_styleAnswer ?? 'your needs'} and uses techniques perfectly suited for your journey.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC9C4D0), height: 1.5)),
              ],
            ),
          ),
          
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/therapist/profile', extra: t),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: const Color(0xFF32285E),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('View Profile & Book', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER & PARTICLES (Reused)
// ────────────────────────────────────────────────────────────────────────────
class _ParticleBackground extends StatefulWidget {
  const _ParticleBackground();
  @override
  State<_ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<_ParticleBackground> with SingleTickerProviderStateMixin {
  late final List<Map<String, dynamic>> _particles;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(20, (i) => {
      'x': rng.nextDouble(),
      'y': rng.nextDouble(),
      'size': rng.nextDouble() * 3 + 1,
      'speed': rng.nextDouble() * 0.5 + 0.2,
      'offset': rng.nextDouble() * pi * 2,
    });
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
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
      builder: (context, _) => CustomPaint(
        painter: _ParticlePainter(_particles, _controller.value),
        size: Size.infinite,
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Map<String, dynamic>> particles;
  final double time;
  _ParticlePainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _primaryColor;
    for (var p in particles) {
      final double driftX = sin(time * pi * 2 + p['offset']) * 20;
      final double y = (p['y'] * size.height) - (time * 80 * p['speed']);
      paint.color = _primaryColor.withValues(alpha: 0.2);
      canvas.drawCircle(Offset((p['x'] * size.width) + driftX, y % size.height), p['size'], paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
