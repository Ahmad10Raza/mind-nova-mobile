import 'package:flutter/material.dart';
import '../../design/colors/app_colors.dart';

class NovaAvatar extends StatelessWidget {
  final double size;

  const NovaAvatar({Key? key, this.size = 48.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundTertiary,
        border: Border.all(color: AppColors.novaPurpleLight, width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          color: AppColors.novaPurpleLight,
          size: size * 0.5,
        ),
      ),
    );
  }
}

class EmotionalSpirit extends StatelessWidget {
  final String doodleAssetPath;
  final double size;

  const EmotionalSpirit({
    Key? key,
    required this.doodleAssetPath,
    this.size = 120.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // In actual implementation, this will load the Image asset.
    // For the UI kit, we use a placeholder if asset is missing.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundSecondary,
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.textMuted,
          size: size * 0.4,
        ),
      ),
    );
  }
}
