import 'package:flutter/material.dart';
import '../../design/colors/app_colors.dart';
import '../animations/mind_nova_animations.dart';

class BreathingLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const BreathingLoader({
    Key? key,
    this.size = 48.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BreathingScale(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (color ?? AppColors.novaPurple).withOpacity(0.2),
          border: Border.all(
            color: color ?? AppColors.novaPurpleLight,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class MindNovaSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const MindNovaSkeleton({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BreathingScale(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
        ),
      ),
    );
  }
}
