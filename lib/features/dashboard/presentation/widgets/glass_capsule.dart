import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassCapsule extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color glowColor;
  final VoidCallback onTap;
  final int animationDelayMs;

  const GlassCapsule({
    super.key,
    required this.icon,
    required this.label,
    required this.glowColor,
    required this.onTap,
    this.animationDelayMs = 0,
  });

  @override
  State<GlassCapsule> createState() => _GlassCapsuleState();
}

class _GlassCapsuleState extends State<GlassCapsule> with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Stagger the floating animations so they don't all move in sync
    Future.delayed(Duration(milliseconds: widget.animationDelayMs), () {
      if (mounted) {
        _floatController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        // Subtle floating offset (-2 to +2 pixels)
        final offsetY = sin(_floatController.value * pi) * 4.0;

        return Transform.translate(
          offset: Offset(0, offsetY),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9999),
                color: Colors.white.withValues(alpha: 0.03), // Ultra soft background
                border: Border.all(color: widget.glowColor.withValues(alpha: 0.08)), // Very soft border
                boxShadow: [
                  BoxShadow(
                    color: widget.glowColor.withValues(alpha: 0.05), // Ambient outer glow
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), // Increased blur for softer glass
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.glowColor.withValues(alpha: 0.9),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.label,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2.0,
                          color: widget.glowColor.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
