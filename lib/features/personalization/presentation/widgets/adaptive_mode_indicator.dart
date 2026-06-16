import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

import '../../data/emotional_profile.dart';

/// Visual indicator of the current adaptive UI mode.
class AdaptiveModeIndicator extends StatelessWidget {
  final AdaptiveUIMode mode;

  const AdaptiveModeIndicator({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final config = _configFor(mode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.08),
        borderRadius: AppRadius.full,
        border: Border.all(color: config.color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, color: config.color, size: 14),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: AppTypography.caption.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  _ModeConfig _configFor(AdaptiveUIMode mode) {
    switch (mode) {
      case AdaptiveUIMode.calm:
        return _ModeConfig('Calm Mode', Icons.spa_rounded, AppColors.calmTeal);
      case AdaptiveUIMode.recovery:
        return _ModeConfig('Recovery Mode', Icons.shield_rounded, AppColors.recoveryBlue);
      case AdaptiveUIMode.focused:
        return _ModeConfig('Focus Mode', Icons.center_focus_strong_rounded, AppColors.novaPurple);
      case AdaptiveUIMode.standard:
        return _ModeConfig('Standard', Icons.circle_rounded, AppColors.textMuted);
    }
  }
}

class _ModeConfig {
  final String label;
  final IconData icon;
  final Color color;
  const _ModeConfig(this.label, this.icon, this.color);
}
