import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

class AppShadows {
  AppShadows._();

  // Core Shadows
  static List<BoxShadow> get shadowSubtle => [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowSoft => [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get shadowFloating => [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ];

  // Glows (Emotional Emphasis)
  static List<BoxShadow> get glowPurple => [
        BoxShadow(
          color: AppColors.novaPurple.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get glowTeal => [
        BoxShadow(
          color: AppColors.calmTeal.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get glowRecovery => [
        BoxShadow(
          color: AppColors.recoveryBlue.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];
}
