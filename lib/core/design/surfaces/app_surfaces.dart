import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

class AppSurfaces {
  AppSurfaces._();

  static const Color primary = AppColors.backgroundPrimary;
  static const Color secondary = AppColors.backgroundSecondary;
  static const Color elevated = AppColors.backgroundTertiary;
  static const Color accent = AppColors.novaPurple;
  
  // Glassmorphism soft surface
  static Color get glassSoft => AppColors.backgroundSecondary.withOpacity(0.6);
}
