import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ZenTimerRing extends StatelessWidget {
  final double progress;
  final String timeString;

  const ZenTimerRing({
    super.key,
    required this.progress,
    required this.timeString,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(300, 300),
            painter: RingPainter(progress: progress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeString,
                style: GoogleFonts.outfit(
                  fontSize: 72,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
              Text(
                'PROTECTED TIME',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  letterSpacing: 3,
                  color: Colors.white30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  final double progress;

  RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 4, trackPaint);

    if (progress <= 0) return;

    // Progress
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFF6366F1)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 2);
    canvas.translate(-center.dx, -center.dy);
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      0,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
    canvas.restore();
    
    // Glowing head
    final headAngle = -math.pi / 2 + (2 * math.pi * progress);
    final headPos = Offset(
      center.dx + (radius - 4) * math.cos(headAngle),
      center.dy + (radius - 4) * math.sin(headAngle),
    );
    
    canvas.drawCircle(headPos, 8, Paint()..color = const Color(0xFFA855F7).withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    canvas.drawCircle(headPos, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) => oldDelegate.progress != progress;
}
