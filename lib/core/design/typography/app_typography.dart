import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  // ==========================================
  // STRICT WEIGHTS (Max 2 for premium feel)
  // ==========================================
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight semiBold = FontWeight.w600;

  // ==========================================
  // HIERARCHY
  // ==========================================

  // Hero sections only
  static TextStyle get headingXL => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: semiBold,
        letterSpacing: -0.5,
        height: 1.2,
      );

  // Screen titles
  static TextStyle get headingL => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: semiBold,
        letterSpacing: -0.3,
        height: 1.3,
      );

  // Card titles
  static TextStyle get headingM => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: semiBold,
        letterSpacing: -0.2,
        height: 1.4,
      );

  // Standard body text
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: regular,
        letterSpacing: 0,
        height: 1.5,
      );

  // Small labels
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: regular,
        letterSpacing: 0.2,
        height: 1.4,
      );
      
  // Button text
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: semiBold,
        letterSpacing: 0.1,
        height: 1.0,
      );

  // ==========================================
  // COMPATIBILITY ALIASES
  // Used by both v2 screens and core components.
  // ==========================================

  /// Hero sections (v2 screens)
  static TextStyle get heroXL => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: semiBold,
        letterSpacing: -0.6,
        height: 1.15,
      );

  static TextStyle get headingLarge => headingL;
  static TextStyle get headingMedium => headingM;
  static TextStyle get headingSmall => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: semiBold,
        letterSpacing: -0.1,
        height: 1.4,
      );
  static TextStyle get bodySmall => caption;
  static TextStyle get bodyMedium => body;
  static TextStyle get labelLarge => GoogleFonts.inter(fontSize: 14, fontWeight: semiBold, letterSpacing: 0.1, height: 1.4);
  static TextStyle get labelMedium => GoogleFonts.inter(fontSize: 12, fontWeight: semiBold, letterSpacing: 0.5, height: 1.4);
  static TextStyle get labelSmall => GoogleFonts.inter(fontSize: 11, fontWeight: semiBold, letterSpacing: 0.5, height: 1.4);
  static TextStyle get displayMedium => GoogleFonts.inter(fontSize: 45, fontWeight: semiBold, letterSpacing: -1.0, height: 1.15);
  static TextStyle get displaySmall => GoogleFonts.inter(fontSize: 36, fontWeight: semiBold, letterSpacing: -0.8, height: 1.2);
}
