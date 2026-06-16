import 'package:flutter/material.dart';
import '../../design/colors/app_colors.dart';
import '../../design/shadows/app_shadows.dart';

class MindNovaFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;

  const MindNovaFloatingButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppShadows.shadowFloating,
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? AppColors.novaPurple,
        elevation: 0, // Elevation handled by custom shadow
        child: Icon(icon, color: iconColor ?? Colors.white),
      ),
    );
  }
}
