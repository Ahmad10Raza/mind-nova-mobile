import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../scoring/models/scoring_model.dart';
import '../../../../core/theme/dashboard_theme.dart';

/// Organic blob shapes painted as subtle background elements.
/// Creates gentle colored blurs that add depth and warmth.
class BlobPainter extends CustomPainter {
  final double animationValue;
  final RiskCategory? riskLevel;

  BlobPainter({
    required this.animationValue,
    required this.riskLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Color primaryAccent;
    Color secondaryAccent;

    // State-aware palettes (Layer 13 Color System constraints)
    // "State Colors: Used ONLY as small accents, NEVER as full UI background changes."
    // We enforce this by using extremely low opacities.
    if (riskLevel == RiskCategory.high || riskLevel == RiskCategory.severe || riskLevel == RiskCategory.emergency) {
      primaryAccent = DashboardTheme.crisisRed; // Warm amber/orange
      secondaryAccent = const Color(0xFFFF9800);
    } else if (riskLevel == RiskCategory.minimal || riskLevel == RiskCategory.mild) {
      primaryAccent = DashboardTheme.moodGreen; // Soft teal/blue
      secondaryAccent = DashboardTheme.recoveryTeal;
    } else {
      primaryAccent = DashboardTheme.primaryPurple; // Default stable
      secondaryAccent = const Color(0xFF5C6BC0); // Neutral blue
    }

    // Blob 1 — top right area
    _drawBlob(
      canvas,
      center: Offset(size.width * 0.85, size.height * 0.08),
      radius: size.width * 0.35,
      color: primaryAccent.withValues(alpha: 0.04),
      offset: animationValue,
    );

    // Blob 2 — middle left
    _drawBlob(
      canvas,
      center: Offset(size.width * 0.1, size.height * 0.35),
      radius: size.width * 0.28,
      color: secondaryAccent.withValues(alpha: 0.03),
      offset: animationValue * 0.7,
    );

    // Blob 3 — lower right
    _drawBlob(
      canvas,
      center: Offset(size.width * 0.9, size.height * 0.65),
      radius: size.width * 0.3,
      color: primaryAccent.withValues(alpha: 0.025),
      offset: animationValue * 1.3,
    );

    // Blob 4 — bottom left
    _drawBlob(
      canvas,
      center: Offset(size.width * 0.15, size.height * 0.85),
      radius: size.width * 0.25,
      color: secondaryAccent.withValues(alpha: 0.03),
      offset: animationValue * 0.5,
    );
  }

  void _drawBlob(Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double offset,
  }) {
    final dx = math.sin(offset * math.pi * 2) * 10;
    final dy = math.cos(offset * math.pi * 2 * 0.6) * 8;

    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.6);

    canvas.drawCircle(center + Offset(dx, dy), radius, paint);
  }

  @override
  bool shouldRepaint(covariant BlobPainter old) {
    return old.animationValue != animationValue;
  }
}
