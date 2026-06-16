import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient nova = LinearGradient(
    colors: [AppColors.novaPurple, AppColors.novaPurpleLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient recovery = LinearGradient(
    colors: [AppColors.recoveryBlue, AppColors.calmTeal],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient sleep = LinearGradient(
    colors: [Color(0xFF1B1D33), Color(0xFF2A2D5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient calm = LinearGradient(
    colors: [AppColors.calmTeal, AppColors.successSoft],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient focus = LinearGradient(
    colors: [AppColors.novaPurpleDark, AppColors.backgroundSecondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient therapy = LinearGradient(
    colors: [AppColors.emotionalSafe, AppColors.backgroundSecondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient community = LinearGradient(
    colors: [AppColors.warmSupport, AppColors.emotionalWarning],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient journey = LinearGradient(
    colors: [AppColors.calmTeal, AppColors.novaPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
