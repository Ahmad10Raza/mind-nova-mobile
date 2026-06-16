import 'package:flutter/material.dart';

/// Centralized color palette and gradient definitions for the Tools Tab.
class ToolsTheme {
  ToolsTheme._();

  // ─── Tool Category Colors ──────────────────────────────────
  static const Color dailyGreen = Color(0xFF66BB6A);
  static const Color aiPurple = Color(0xFF7C4DFF);
  static const Color assessAmber = Color(0xFFFF9800);
  static const Color mindfulBlue = Color(0xFF29B6F6);
  static const Color crisisRed = Color(0xFFEF5350);
  static const Color sleepNavy = Color(0xFF283593);
  static const Color communityTeal = Color(0xFF26A69A);

  // ─── Section Background Tints ──────────────────────────────
  static const Color dailyBgTint = Color(0xFFF0FFF4);    // Soft mint
  static const Color aiBgTint = Color(0xFFF3E5F5);       // Light purple
  static const Color assessBgTint = Color(0xFFFFF8E1);   // Warm cream
  static const Color mindfulBgTint = Color(0xFFE3F2FD);  // Pale blue
  static const Color crisisBgTint = Color(0xFFFCE4EC);   // Muted rose
  static const Color sleepBgTint = Color(0xFFE8EAF6);    // Lavender frost
  static const Color communityBgTint = Color(0xFFE0F2F1); // Mint frost

  // ─── Card Gradients ────────────────────────────────────────

  // Daily Wellness
  static const moodGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
  );
  static const gratitudeGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFF8BBD0), Color(0xFFF48FB1)],
  );
  static const journalGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFA5D6A7), Color(0xFF66BB6A)],
  );
  static const affirmationGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFFE082), Color(0xFFFFD54F)],
  );
  static const reflectionGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFB39DDB), Color(0xFF9575CD)],
  );
  static const habitGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF80CBC4), Color(0xFF4DB6AC)],
  );

  // AI Tools
  static const aiChatGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF5E4B8B), Color(0xFF9147FF)],
  );
  static const aiPredictionGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF7C4DFF), Color(0xFF651FFF)],
  );
  static const riskGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFE040FB), Color(0xFFD500F9)],
  );
  static const weeklyInsightGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );
  static const cmhiGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
  );
  static const recsGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFCE93D8), Color(0xFFBA68C8)],
  );

  // Assessments
  static const depressionGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF5C6BC0), Color(0xFF3F51B5)],
  );
  static const anxietyGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFF8A65), Color(0xFFFF7043)],
  );
  static const stressGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFFB74D), Color(0xFFFFA726)],
  );
  static const ptsdGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF78909C), Color(0xFF607D8B)],
  );
  static const panicGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFEF5350), Color(0xFFE53935)],
  );
  static const burnoutGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF8D6E63), Color(0xFF795548)],
  );
  static const resumeGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
  );

  // Mindfulness
  static const breathingGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF26A69A), Color(0xFF00897B)],
  );
  static const groundingGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF8D6E63), Color(0xFF6D4C41)],
  );
  static const meditationGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFFB74D), Color(0xFFFFA726)],
  );
  static const sleepModeGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF1A237E), Color(0xFF0D1B2A)],
  );
  static const musicGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF7E57C2), Color(0xFF5E35B1)],
  );
  static const focusGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
  );

  // Crisis
  static const emergencyGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFEF5350), Color(0xFFC62828)],
  );
  static const crisisPlanGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFF8A80), Color(0xFFFF5252)],
  );
  static const safeContactsGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFFAB91), Color(0xFFFF8A65)],
  );
  static const sosGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
  );
  static const therapistGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF4DD0E1), Color(0xFF26C6DA)],
  );

  // Sleep & Recovery
  static const sleepTrackerGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF1A237E), Color(0xFF283593)],
  );
  static const recoveryGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF26A69A), Color(0xFF00897B)],
  );
  static const nervousGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF7986CB), Color(0xFF5C6BC0)],
  );
  static const energyGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFFCA28), Color(0xFFFFB300)],
  );
  static const burnoutRecoveryGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFA1887F), Color(0xFF8D6E63)],
  );

  // Community
  static const communityGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF26A69A), Color(0xFF009688)],
  );
  static const sessionsGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF5C6BC0), Color(0xFF3F51B5)],
  );
  static const supportGroupGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
  );
  static const challengesGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
  );

  // MindNova Intelligence Hub
  static const intelligenceGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF5E4B8B), Color(0xFF9147FF)],
  );
}
