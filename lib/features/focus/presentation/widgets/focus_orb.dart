import 'dart:math' as math;
import 'package:flutter/material.dart';

class FocusOrb extends StatefulWidget {
  const FocusOrb({super.key});

  @override
  State<FocusOrb> createState() => _FocusOrbState();
}

class _FocusOrbState extends State<FocusOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
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
      builder: (context, child) {
        return Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF818CF8).withOpacity(0.8),
                const Color(0xFF6366F1).withOpacity(0.4),
                Colors.transparent,
              ],
              stops: const [0.2, 0.6, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF818CF8).withOpacity(0.2),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: CustomPaint(
            painter: OrbPainter(_controller.value),
          ),
        );
      },
    );
  }
}

class OrbPainter extends CustomPainter {
  final double animationValue;

  OrbPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.8;

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF818CF8), Color(0xFFC084FC)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i <= 360; i++) {
      final angle = i * math.pi / 180;
      // Liquid wave effect
      final wave1 = math.sin(animationValue * 2 * math.pi + i * 0.02) * 8;
      final wave2 = math.cos(animationValue * 1 * math.pi + i * 0.05) * 4;
      
      final currentRadius = radius + wave1 + wave2;
      
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    // Draw blurred shadow behind
    canvas.drawPath(path, paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
    
    // Draw main liquid body
    canvas.drawPath(path, paint..maskFilter = null);
    
    // Add high-frequency glowing dots/stars
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.6);
    for (int i = 0; i < 8; i++) {
      final phase = i * math.pi / 4;
      final dotAngle = (animationValue * 1.5 * math.pi + phase) % (2 * math.pi);
      final dist = radius * 0.8;
      final dx = center.dx + dist * math.cos(dotAngle);
      final dy = center.dy + dist * math.sin(dotAngle);
      canvas.drawCircle(Offset(dx, dy), 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(OrbPainter oldDelegate) => true;
}
