import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  // Durations
  static const Duration microFast = Duration(milliseconds: 150);
  static const Duration microNormal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration breathing = Duration(milliseconds: 4000);
  static const Duration floating = Duration(milliseconds: 6000);

  // Curves
  static const Curve calmEase = Curves.easeInOutCubic;
  static const Curve softSpring = Curves.easeOutBack;
  static const Curve emotionalFade = Curves.easeIn;
}
