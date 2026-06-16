import 'dart:ui';
import 'package:flutter/material.dart';

class LuminousOrb extends StatelessWidget {
  final Widget child;
  final double size;
  final Color glowColor;
  final bool animatePulse;

  const LuminousOrb({
    super.key,
    required this.child,
    required this.size,
    required this.glowColor,
    this.animatePulse = false,
  });

  @override
  Widget build(BuildContext context) {
    // Basic implementation for now, you can add pulsing animation via a parent wrapper if needed
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF131B2E).withOpacity(0.3), // Fallback color
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: -5, // Inset effect emulation
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.4, -0.4),
                radius: 1.0,
                colors: [
                  glowColor.withOpacity(0.2),
                  glowColor.withOpacity(0.05),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
