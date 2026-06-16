import 'package:flutter/material.dart';
import '../../design/colors/app_colors.dart';

class MindNovaIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? color;
  final double? size;

  const MindNovaIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: color ?? AppColors.textPrimary,
      iconSize: size ?? 24.0,
      splashRadius: 24.0,
    );
  }
}
