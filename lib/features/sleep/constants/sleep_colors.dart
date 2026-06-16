import 'package:flutter/material.dart';

/// MindNova Sleep Mode — Night Design System
/// Inspired by Calm, Headspace, Apple Sleep Focus
class SleepColors {
  SleepColors._();

  // ─── Core Night Palette ────────────────────────────────────
  static const Color deepNavy = Color(0xFF0A0E27);
  static const Color indigo = Color(0xFF1A1B4B);
  static const Color darkPurple = Color(0xFF2D1B69);
  static const Color softBlue = Color(0xFF3B5998);
  static const Color moonlightWhite = Color(0xFFE8EAF6);
  static const Color lavenderGlow = Color(0xFFB39DDB);
  static const Color starWhite = Color(0xFFF5F5F5);
  static const Color midnightBlack = Color(0xFF050816);

  // ─── Surface & Card Colors ────────────────────────────────
  static const Color cardSurface = Color(0xFF151938);
  static const Color cardBorder = Color(0xFF2A2F5E);
  static const Color glassWhite = Color(0x1AFFFFFF); // 10% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white

  // ─── Text Colors ──────────────────────────────────────────
  static const Color textPrimary = Color(0xFFE8EAF6);
  static const Color textSecondary = Color(0xFF9FA8DA);
  static const Color textMuted = Color(0xFF5C6BC0);

  // ─── Accent Colors ────────────────────────────────────────
  static const Color moonGold = Color(0xFFFFD54F);
  static const Color calmTeal = Color(0xFF4DB6AC);
  static const Color sleepyPink = Color(0xFFCE93D8);
  static const Color emergencyRed = Color(0xFFEF5350);
  static const Color successGreen = Color(0xFF66BB6A);

  // ─── Gradients ────────────────────────────────────────────
  static const LinearGradient nightSkyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [midnightBlack, deepNavy, indigo],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient moonlightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkPurple, indigo, deepNavy],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D1137), Color(0xFF1A1B4B), Color(0xFF0A0E27)],
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3E1A1A), Color(0xFF1A0E0E)],
  );

  static const LinearGradient breathingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A237E), Color(0xFF0D1B2A), Color(0xFF0A0E27)],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
  );

  // ─── Glassmorphism Constants ──────────────────────────────
  static const double glassBlurSigma = 20.0;
  static const double glassOpacity = 0.08;
  static const double glassBorderWidth = 1.0;
  static const double cardRadius = 24.0;

  // ─── Box Decoration Helpers ───────────────────────────────
  static BoxDecoration get glassCard => BoxDecoration(
        color: Colors.white.withValues(alpha: glassOpacity),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(
          color: glassBorder,
          width: glassBorderWidth,
        ),
      );

  static BoxDecoration glassCardWithGlow(Color glowColor) => BoxDecoration(
        color: Colors.white.withValues(alpha: glassOpacity),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(
          color: glassBorder,
          width: glassBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      );
}
