import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../scoring/models/scoring_model.dart';

import '../../../../core/utils/number_formatter.dart';

class CMHIOrb extends StatefulWidget {
  final double score;
  final RiskCategory risk;
  final double size;

  const CMHIOrb({
    super.key,
    required this.score,
    required this.risk,
    this.size = 200,
  });

  @override
  State<CMHIOrb> createState() => _CMHIOrbState();
}

class _CMHIOrbState extends State<CMHIOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _getDuration(widget.risk),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(CMHIOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.risk != widget.risk) {
      _controller.duration = _getDuration(widget.risk);
      _controller.repeat(reverse: true);
    }
  }

  Duration _getDuration(RiskCategory risk) {
    switch (risk) {
      case RiskCategory.minimal: return const Duration(milliseconds: 3000);
      case RiskCategory.mild: return const Duration(milliseconds: 2500);
      case RiskCategory.moderate: return const Duration(milliseconds: 2000);
      case RiskCategory.high: return const Duration(milliseconds: 1500);
      case RiskCategory.severe: return const Duration(milliseconds: 1000);
      case RiskCategory.emergency: return const Duration(milliseconds: 800);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // Explicitly clamp to prevent negative or NaN scales during rapid rebuild
          final breathScale = (1.0 + (_controller.value.clamp(0.0, 1.0) * 0.04)).clamp(0.1, 2.0);
          
          return GestureDetector(
            onTap: () => context.push('/cmhi-info'),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Vital to prevent 99k overflow inside SliverToBoxAdapter
              children: [
                // Orb + Ring
                SizedBox(
                  width: widget.size + 40,
                  height: widget.size + 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress ring
                      _buildProgressRing(),
                      // Glow behind orb
                      _buildOrbGlow(),
                      // Main orb with scale breathing
                      Transform.scale(
                        scale: breathScale,
                        child: CustomPaint(
                          size: Size(widget.size, widget.size),
                          painter: _OrbSurfacePainter(
                            color: widget.risk.color,
                            animValue: _controller.value.clamp(0.0, 1.0),
                          ),
                          child: SizedBox(
                            width: widget.size,
                            height: widget.size,
                            child: _buildOrbContent(),
                          ),
                        ),
                      ),
                      // Floating orbitals
                      ..._buildOrbitals(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Risk label + trend
                _buildRiskBadge(),
                const SizedBox(height: 8),
                Text(
                  'Tap to Learn More',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressRing() {
    return SizedBox(
      width: widget.size + 30,
      height: widget.size + 30,
      child: CustomPaint(
        painter: _RingPainter(
          progress: (widget.score / 100).clamp(0.0, 1.0),
          color: widget.risk.color,
          strokeWidth: 4,
        ),
      ),
    );
  }

  Widget _buildOrbGlow() {
    return Container(
      width: widget.size * 1.3,
      height: widget.size * 1.3,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.risk.color.withValues(
              alpha: (0.15 + (_controller.value.clamp(0.0, 1.0) * 0.1)).clamp(0.0, 1.0),
            ),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildOrbContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Extra safety
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            NumberFormatter.formatMetric(widget.score),
            style: GoogleFonts.outfit(
              fontSize: widget.size * 0.22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 8.0, // Fixed positive constant
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          Text(
            'CMHI',
            style: GoogleFonts.inter(
              fontSize: widget.size * 0.065,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.75),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrbitals() {
    final angle = _controller.value * 2 * math.pi;
    final r = widget.size / 2 + 18;
    return [
      Positioned(
        left: (widget.size + 40) / 2 + r * math.cos(angle) - 3,
        top: (widget.size + 40) / 2 + r * math.sin(angle) - 3,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        left: (widget.size + 40) / 2 + r * 1.05 * math.cos(angle + math.pi) - 2,
        top: (widget.size + 40) / 2 + r * 1.05 * math.sin(angle + math.pi) - 2,
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        left: (widget.size + 40) / 2 + r * 0.95 * math.cos(angle + math.pi / 2) - 2.5,
        top: (widget.size + 40) / 2 + r * 0.95 * math.sin(angle + math.pi / 2) - 2.5,
        child: Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: widget.risk.color.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
      ),
    ];
  }

  Widget _buildRiskBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.risk.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: widget.risk.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.risk.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.risk.label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: widget.risk.color,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            widget.score >= 60 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 16,
            color: widget.risk.color,
          ),
        ],
      ),
    );
  }
}

// ─── Orb Surface Painter ────────────────────────────────────
class _OrbSurfacePainter extends CustomPainter {
  final Color color;
  final double animValue;

  _OrbSurfacePainter({required this.color, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Main gradient surface
    final orbPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          color,
          Color.lerp(color, Colors.black, 0.3)!,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, orbPaint);

    // Glass highlight — top-left arc
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final highlightPath = Path()
      ..addArc(
        Rect.fromCircle(
          center: center + Offset(-radius * 0.2, -radius * 0.2),
          radius: radius * 0.55,
        ),
        3 * math.pi / 4,
        math.pi / 2.5,
      );
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbSurfacePainter old) => old.animValue != animValue;
}

// ─── Ring Painter ───────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, trackPaint);

    // Progress arc
    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [color, color.withValues(alpha: 0.4)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress.clamp(0, 1), false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
