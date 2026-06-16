import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

class AppBorders {
  AppBorders._();

  static BorderSide get subtle => BorderSide(
        color: AppColors.neutral400.withOpacity(0.1),
        width: 1.0,
      );

  static BorderSide get active => const BorderSide(
        color: AppColors.novaPurple,
        width: 2.0,
      );

  static BorderSide get focus => const BorderSide(
        color: AppColors.calmTeal,
        width: 2.0,
      );
      
  static BorderSide get error => const BorderSide(
        color: AppColors.emotionalDangerMuted,
        width: 1.0,
      );
}
