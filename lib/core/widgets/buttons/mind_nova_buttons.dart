import 'package:flutter/material.dart';
import '../../design/colors/app_colors.dart';
import '../../design/typography/app_typography.dart';
import '../../design/radius/app_radius.dart';
import '../../design/spacing/app_spacing.dart';

// ==========================================
// BASE BUTTON CONFIGURATION
// ==========================================
abstract class _MindNovaBaseButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const _MindNovaBaseButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);

  Color get backgroundColor;
  Color get foregroundColor;
  BorderSide? get borderSide => null;

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: AppColors.surfaceSecondary,
      disabledForegroundColor: AppColors.textDisabled,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.pill,
        side: borderSide ?? BorderSide.none,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s24,
        vertical: AppSpacing.s16,
      ),
      textStyle: AppTypography.button,
    );

    if (isLoading) {
      return ElevatedButton(
        onPressed: null,
        style: style,
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
          ),
        ),
      );
    }

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon, size: 20),
        label: Text(text),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Text(text),
    );
  }
}

// ==========================================
// VARIANTS
// ==========================================

class MindNovaPrimaryButton extends _MindNovaBaseButton {
  const MindNovaPrimaryButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) : super(key: key, text: text, onPressed: onPressed, isLoading: isLoading, icon: icon);

  @override
  Color get backgroundColor => AppColors.primaryPurple;

  @override
  Color get foregroundColor => AppColors.textPrimary;
}

class MindNovaSecondaryButton extends _MindNovaBaseButton {
  const MindNovaSecondaryButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) : super(key: key, text: text, onPressed: onPressed, isLoading: isLoading, icon: icon);

  @override
  Color get backgroundColor => AppColors.surfaceElevated;

  @override
  Color get foregroundColor => AppColors.textPrimary;
  
  @override
  BorderSide get borderSide => const BorderSide(color: AppColors.primaryPurple, width: 1);
}

class MindNovaGhostButton extends _MindNovaBaseButton {
  const MindNovaGhostButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) : super(key: key, text: text, onPressed: onPressed, isLoading: isLoading, icon: icon);

  @override
  Color get backgroundColor => Colors.transparent;

  @override
  Color get foregroundColor => AppColors.primaryPurpleLight;
}

class MindNovaCalmButton extends _MindNovaBaseButton {
  const MindNovaCalmButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) : super(key: key, text: text, onPressed: onPressed, isLoading: isLoading, icon: icon);

  @override
  Color get backgroundColor => AppColors.calmTeal.withOpacity(0.15);

  @override
  Color get foregroundColor => AppColors.calmTeal;
}

class MindNovaDangerButton extends _MindNovaBaseButton {
  const MindNovaDangerButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) : super(key: key, text: text, onPressed: onPressed, isLoading: isLoading, icon: icon);

  @override
  Color get backgroundColor => AppColors.dangerMuted.withOpacity(0.15);

  @override
  Color get foregroundColor => AppColors.dangerMuted;
}
