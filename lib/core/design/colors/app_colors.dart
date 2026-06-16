import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background
  static const Color backgroundPrimary = Color(0xFF0F1020);
  static const Color backgroundSecondary = Color(0xFF151729);
  static const Color backgroundTertiary = Color(0xFF1B1D33);

  // Primary
  static const Color novaPurple = Color(0xFF8B5CF6);
  static const Color novaPurpleLight = Color(0xFFA78BFA);
  static const Color novaPurpleDark = Color(0xFF7C3AED);

  // Recovery
  static const Color calmTeal = Color(0xFF2DD4BF);
  static const Color recoveryBlue = Color(0xFF60A5FA);

  // Support
  static const Color warmSupport = Color(0xFFFBBF24);
  static const Color successSoft = Color(0xFF34D399);

  // Emotional
  static const Color emotionalSafe = Color(0xFFE0E7FF);
  static const Color emotionalWarning = Color(0xFFFDE68A);
  static const Color emotionalDangerMuted = Color(0xFFFCA5A5);

  // Neutral
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);

  // Text
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFFD1D5DB);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFF6B7280);

  // ==========================================
  // COMPATIBILITY ALIASES
  // Used by app_theme.dart and core component library.
  // ==========================================

  static const Color primaryPurple = novaPurple;
  static const Color primaryPurpleLight = novaPurpleLight;
  static const Color surfacePrimary = backgroundPrimary;
  static const Color surfaceSecondary = backgroundSecondary;
  static const Color surfaceElevated = backgroundTertiary;
  static const Color dangerMuted = emotionalDangerMuted;

  // Added aliases for Explore widgets compatibility
  static const Color primary = novaPurple;
  static const Color secondary = calmTeal;
  static const Color tertiary = recoveryBlue;
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color surfaceHighest = Color(0xFF374151); // Gray 700
  static const Color surfaceContainerLow = Color(0xFF1E213A); // Slightly lighter than backgroundSecondary
  static const Color onPrimary = textPrimary;
}
