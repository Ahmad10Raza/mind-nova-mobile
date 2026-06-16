import 'package:flutter/material.dart';
import '../design/colors/app_colors.dart';
import '../design/typography/app_typography.dart';
import '../design/radius/app_radius.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryPurple,
      scaffoldBackgroundColor: AppColors.surfacePrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPurple,
        primary: AppColors.primaryPurple,
        error: AppColors.dangerMuted,
        surface: AppColors.surfacePrimary,
        brightness: Brightness.dark, // MindNova defaults to its dark/calm aesthetic
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.headingXL,
        headlineLarge: AppTypography.headingL,
        headlineMedium: AppTypography.headingM,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.caption,
        labelLarge: AppTypography.button,
      ),
      // Buttons and cards will now use their specific MindNova components,
      // but we set safe global defaults here.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pill,
          ),
          textStyle: AppTypography.button,
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.medium,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.large,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.r24),
          ),
        ),
      ),
    );
  }
}
