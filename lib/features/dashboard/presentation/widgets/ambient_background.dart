import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';

enum EmotionalState {
  night, // Navy, Violet, Soft Teal
  morning, // Dawn Orange, Soft Sky, Warm White
  calm, // Deep Seafoam, Soft Blue, Silver
  stressed, // Warm Amber, Soft Coral, Dark Violet
}

class AmbientBackground extends StatefulWidget {
  final EmotionalState currentState;

  const AmbientBackground({
    super.key,
    this.currentState = EmotionalState.night,
  });

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground> with TickerProviderStateMixin {
  late final AnimationController _fogController;
  late final AnimationController _starsController;
  late final AnimationController _particlesController;
  late final AnimationController _foregroundController;

  final List<_Star> _stars = [];
  final List<_Particle> _midParticles = [];
  final List<_Particle> _foregroundParticles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // 1. Fog: Ultra slow
    _fogController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat(reverse: true);

    // 2. Stars: Almost static (very slow blink)
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // 3. Particles: Medium drift
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // 4. Foreground: Slightly faster
    _foregroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _generateEnvironment();
  }

  void _generateEnvironment() {
    // Stars
    for (int i = 0; i < 60; i++) {
      _stars.add(_Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 1.5 + 0.5,
        blinkOffset: _random.nextDouble() * 2 * pi,
      ));
    }

    // Mid particles
    for (int i = 0; i < 15; i++) {
      _midParticles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 8 + 4,
        speed: _random.nextDouble() * 0.02 + 0.01,
        wobbleSpeed: _random.nextDouble() * 1 + 0.5,
        wobbleAmplitude: _random.nextDouble() * 0.03,
      ));
    }

    // Foreground particles (larger, faster, blurred)
    for (int i = 0; i < 8; i++) {
      _foregroundParticles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 20 + 10,
        speed: _random.nextDouble() * 0.04 + 0.03,
        wobbleSpeed: _random.nextDouble() * 1.5 + 0.5,
        wobbleAmplitude: _random.nextDouble() * 0.05,
      ));
    }
  }

  @override
  void dispose() {
    _fogController.dispose();
    _starsController.dispose();
    _particlesController.dispose();
    _foregroundController.dispose();
    super.dispose();
  }

  // Define strictly 3 colors per state: Dominant, Support Glow, Accent
  (Color, Color, Color) _getPalette(EmotionalState state) {
    switch (state) {
      case EmotionalState.night:
        return (const Color(0xFF060E20), AppColors.novaPurpleLight, AppColors.calmTeal);
      case EmotionalState.morning:
        return (const Color(0xFF1B1D33), const Color(0xFFFFB74D), const Color(0xFF81D4FA));
      case EmotionalState.calm:
        return (const Color(0xFF003731), const Color(0xFF44E2CD), AppColors.novaPurpleLight);
      case EmotionalState.stressed:
        return (const Color(0xFF2A1C24), const Color(0xFFFCA5A5), const Color(0xFFFBBF24));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _getPalette(widget.currentState);
    final dominant = palette.$1;
    final support = palette.$2;
    final accent = palette.$3;

    return AnimatedContainer(
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOutCubic,
      color: dominant,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // LAYER 1: Almost static stars
          AnimatedBuilder(
            animation: _starsController,
            builder: (context, child) {
              return CustomPaint(
                painter: _StarPainter(stars: _stars, time: _starsController.value),
              );
            },
          ),

          // LAYER 2: Ultra slow volumetric fog
          AnimatedBuilder(
            animation: _fogController,
            builder: (context, child) {
              final v = _fogController.value;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: -100 + (v * 50),
                    left: -50,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            support.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -150 - (v * 30),
                    right: -100,
                    child: Container(
                      width: 500,
                      height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            accent.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // LAYER 3: Medium drift particles
          AnimatedBuilder(
            animation: _particlesController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ParticlePainter(
                  particles: _midParticles,
                  time: _particlesController.value,
                  color: support,
                  blurSigma: 2.0,
                ),
              );
            },
          ),

          // LAYER 4: Slightly faster foreground blur
          AnimatedBuilder(
            animation: _foregroundController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ParticlePainter(
                  particles: _foregroundParticles,
                  time: _foregroundController.value,
                  color: accent,
                  blurSigma: 8.0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Star {
  final double x, y, size, blinkOffset;
  _Star({required this.x, required this.y, required this.size, required this.blinkOffset});
}

class _Particle {
  final double x, y, size, speed, wobbleSpeed, wobbleAmplitude;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.wobbleSpeed,
    required this.wobbleAmplitude,
  });
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double time;

  _StarPainter({required this.stars, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (final s in stars) {
      // Extremely slow blink
      final opacity = (sin(time * pi * 2 * 2 + s.blinkOffset) + 1) / 2;
      paint.color = Colors.white.withValues(alpha: 0.05 + opacity * 0.4);
      canvas.drawCircle(Offset(s.x * size.width, s.y * size.height), s.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => true;
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;
  final Color color;
  final double blurSigma;

  _ParticlePainter({
    required this.particles,
    required this.time,
    required this.color,
    required this.blurSigma,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    for (final p in particles) {
      double currentY = (p.y - time * p.speed) % 1.0;
      if (currentY < 0) currentY += 1.0;

      final currentX = p.x + sin(time * pi * 2 * p.wobbleSpeed) * p.wobbleAmplitude;

      double opacity = 0.3;
      if (currentY < 0.2) opacity = 0.3 * (currentY / 0.2);
      if (currentY > 0.8) opacity = 0.3 * ((1.0 - currentY) / 0.2);

      paint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(currentX * size.width, currentY * size.height), p.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
