import 'package:flutter/material.dart';
import '../../design/spacing/app_spacing.dart';
import '../../design/typography/app_typography.dart';
import '../../design/colors/app_colors.dart';
import '../buttons/mind_nova_buttons.dart';

class MindNovaEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String doodleAssetPath;
  final String? buttonText;
  final VoidCallback? onActionPressed;

  const MindNovaEmptyState({
    Key? key,
    required this.title,
    required this.message,
    required this.doodleAssetPath,
    this.buttonText,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.image_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.v32,
          Text(
            title,
            style: AppTypography.headingLarge,
            textAlign: TextAlign.center,
          ),
          AppSpacing.v12,
          Text(
            message,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          AppSpacing.v32,
          if (buttonText != null && onActionPressed != null)
            MindNovaGhostButton(
              text: buttonText!,
              onPressed: onActionPressed,
            ),
        ],
      ),
    );
  }
}

class MindNovaRecoveryEmptyState extends StatelessWidget {
  final VoidCallback onBreathePressed;

  const MindNovaRecoveryEmptyState({Key? key, required this.onBreathePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MindNovaEmptyState(
      title: "It's okay to pause",
      message: "If things feel overwhelming, you can always take a step back and breathe with us.",
      doodleAssetPath: 'assets/doodles/recovery_cloud.png',
      buttonText: 'Start Breathing Session',
      onActionPressed: onBreathePressed,
    );
  }
}

class MindNovaTherapyEmptyState extends StatelessWidget {
  final VoidCallback onHelpPressed;

  const MindNovaTherapyEmptyState({Key? key, required this.onHelpPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MindNovaEmptyState(
      title: "You're not alone",
      message: "Professional support is always available when you're ready to talk.",
      doodleAssetPath: 'assets/doodles/therapy_tea.png',
      buttonText: 'Find Support',
      onActionPressed: onHelpPressed,
    );
  }
}
