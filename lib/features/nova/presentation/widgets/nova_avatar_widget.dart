import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/shadows/app_shadows.dart';
import '../../../../core/design/motion/app_motion.dart';
import '../../../../core/widgets/animations/mind_nova_animations.dart';

/// Nova's breathing avatar with emotional glow.
/// The avatar softly pulses when idle, and the glow color
/// adapts to the emotional context.
class NovaAvatarWidget extends StatelessWidget {
  final double size;
  final bool isActive;
  final Color? glowColor;

  const NovaAvatarWidget({
    super.key,
    this.size = 64,
    this.isActive = true,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final glow = glowColor ?? AppColors.novaPurpleLight;

    return BreathingScale(
      active: isActive,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.novaPurple,
              AppColors.novaPurpleLight,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: glow.withOpacity(0.35),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/nova_ai.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: size * 0.45,
            ),
          ),
        ),
      ),
    );
  }
}
