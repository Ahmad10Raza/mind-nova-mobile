import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized design tokens for the MindNova cinematic dashboard.
class DashboardTheme {
  DashboardTheme._();

  // ─── Brand Colors ─────────────────────────────────────────
  static const Color primaryPurple = Color(0xFF5E4B8B);
  static const Color accentViolet = Color(0xFF9147FF);
  static const Color deepNavy = Color(0xFF1A1A2E);
  static const Color softLavender = Color(0xFFE8DEF8);
  static const Color mintFresh = Color(0xFFB2DFDB);
  static const Color warmPeach = Color(0xFFFFCCBC);
  static const Color softGold = Color(0xFFFFF8E1);

  // ─── Semantic Wellness Colors ─────────────────────────────
  static const Color moodGreen = Color(0xFF4CAF50);
  static const Color sleepBlue = Color(0xFF5C6BC0);
  static const Color stressAmber = Color(0xFFFF9800);
  static const Color recoveryTeal = Color(0xFF26A69A);
  static const Color anxietyPink = Color(0xFFE91E63);
  static const Color energyYellow = Color(0xFFFFCA28);
  static const Color crisisRed = Color(0xFFFF1744);

  // ─── Neutral Scale ────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF48484A);
  static const Color textTertiary = Color(0xFF8E8E93);
  static const Color surfaceWhite = Color(0xFFFBFBFE);
  static const Color cardWhite = Color(0xFFFFFFFF);

  // ─── Radii ────────────────────────────────────────────────
  static const double radiusS = 12;
  static const double radiusM = 20;
  static const double radiusL = 28;
  static const double radiusXL = 32;

  // ─── Shadows ──────────────────────────────────────────────
  static List<BoxShadow> softShadow(Color tint) => [
    BoxShadow(
      color: tint.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowShadow(Color tint) => [
    BoxShadow(
      color: tint.withValues(alpha: 0.25),
      blurRadius: 24.clamp(0.0, 100.0).toDouble(), // Defensive clamp
      offset: const Offset(0, 10),
    ),
  ];

  // ─── Gradient Presets ─────────────────────────────────────
  static const LinearGradient heroGradientMorning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepNavy, Color(0xFF16213E), recoveryTeal],
  );

  static const LinearGradient heroGradientAfternoon = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepNavy, primaryPurple, accentViolet],
  );

  static const LinearGradient heroGradientEvening = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepNavy, Color(0xFF2A1B3D), stressAmber],
  );

  static const LinearGradient heroGradientNight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D0D1A), deepNavy, Color(0xFF16213E)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, accentViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient insightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
  );

  // ─── Time-Aware Helpers ───────────────────────────────────
  static LinearGradient get currentHeroGradient {
    final hour = DateTime.now().hour;
    if (hour < 12) return heroGradientMorning;
    if (hour < 17) return heroGradientAfternoon;
    if (hour < 20) return heroGradientEvening;
    return heroGradientNight;
  }

  static bool get isNightMode => DateTime.now().hour >= 20 || DateTime.now().hour < 6;

  static Color get currentTextColor => isNightMode ? Colors.white : textPrimary;
  static Color get currentSubtextColor => isNightMode ? Colors.white70 : textTertiary;

  // ─── Typography ───────────────────────────────────────────
  static TextStyle heading1 = GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static TextStyle heading2 = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle heading3 = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle bodyRegular = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textTertiary,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: textTertiary,
  );

  // ─── Card Decorations ─────────────────────────────────────
  static BoxDecoration solidCard({Color? tint}) => BoxDecoration(
    color: cardWhite,
    borderRadius: BorderRadius.circular(radiusL),
    boxShadow: softShadow(tint ?? Colors.black),
  );

  static BoxDecoration gradientCard(LinearGradient gradient) => BoxDecoration(
    gradient: gradient,
    borderRadius: BorderRadius.circular(radiusL),
  );

  static BoxDecoration glassCard({Color? tint}) => BoxDecoration(
    color: cardWhite.withValues(alpha: 0.7),
    borderRadius: BorderRadius.circular(radiusL),
    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
    boxShadow: softShadow(tint ?? Colors.black),
  );
}
