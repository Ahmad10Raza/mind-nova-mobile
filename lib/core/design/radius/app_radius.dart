import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 24.0;
  static const double radiusXL = 32.0;
  static const double radiusFull = 100.0;

  static BorderRadius get xs => BorderRadius.circular(radiusXS);
  static BorderRadius get sm => BorderRadius.circular(radiusSM);
  static BorderRadius get md => BorderRadius.circular(radiusMD);
  static BorderRadius get lg => BorderRadius.circular(radiusLG);
  static BorderRadius get xl => BorderRadius.circular(radiusXL);
  static BorderRadius get full => BorderRadius.circular(radiusFull);

  // ==========================================
  // COMPATIBILITY ALIASES
  // ==========================================

  static BorderRadius get pill => full;
  static BorderRadius get medium => md;
  static BorderRadius get large => lg;
  static const double r24 = radiusLG;
}
