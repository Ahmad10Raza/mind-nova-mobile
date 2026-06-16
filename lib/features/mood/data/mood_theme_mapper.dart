import 'package:flutter/material.dart';

/// Client-side mirror of the backend mood registry.
/// This provides immediate UI theming before the API responds,
/// ensuring instant visual feedback on mood selection.
class MoodThemeMapper {
  static const Map<String, MoodTheme> registry = {
    'Overjoyed': MoodTheme(
      emoji: '🤩', category: 'positive',
      gradient: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
      subtitle: 'You are radiating incredible positive energy today.',
      ctaLabel: 'Capture This Moment', cardStyle: 'BRIGHT_GLASS',
    ),
    'Happy': MoodTheme(
      emoji: '😊', category: 'positive',
      gradient: [Color(0xFFFEF3C7), Color(0xFFFBBF24)],
      subtitle: 'You seem to be having a bright and uplifting day.',
      ctaLabel: 'Save This Moment', cardStyle: 'BRIGHT_GLASS',
    ),
    'Calm': MoodTheme(
      emoji: '😌', category: 'positive',
      gradient: [Color(0xFFD1FAE5), Color(0xFF10B981)],
      subtitle: 'Your mind seems steady, grounded, and at peace.',
      ctaLabel: 'Rest in the Calm', cardStyle: 'SOFT_GLASS',
    ),
    'Grateful': MoodTheme(
      emoji: '🙏', category: 'positive',
      gradient: [Color(0xFFFBCFE8), Color(0xFFEC4899)],
      subtitle: 'You are vibrating with appreciation today.',
      ctaLabel: 'Log Gratitude', cardStyle: 'BRIGHT_GLASS',
    ),
    'Neutral': MoodTheme(
      emoji: '😐', category: 'neutral',
      gradient: [Color(0xFFE5E7EB), Color(0xFF9CA3AF)],
      subtitle: 'You are floating in the middle right now.',
      ctaLabel: 'Check In', cardStyle: 'MUTED_GLASS',
    ),
    'Tired': MoodTheme(
      emoji: '🥱', category: 'neutral',
      gradient: [Color(0xFFDBEAFE), Color(0xFF60A5FA)],
      subtitle: 'Your energy levels feel a bit lower than usual.',
      ctaLabel: 'Prioritize Rest', cardStyle: 'MUTED_GLASS',
    ),
    'Distracted': MoodTheme(
      emoji: '😵‍💫', category: 'neutral',
      gradient: [Color(0xFFE0E7FF), Color(0xFF818CF8)],
      subtitle: 'Your focus seems scattered and hard to gather today.',
      ctaLabel: 'Regain Focus', cardStyle: 'MUTED_GLASS',
    ),
    'Numb': MoodTheme(
      emoji: '😶', category: 'neutral',
      gradient: [Color(0xFFF3F4F6), Color(0xFF6B7280)],
      subtitle: 'You might be feeling disconnected from your emotions.',
      ctaLabel: 'Gentle Grounding', cardStyle: 'MUTED_GLASS',
    ),
    'Sad': MoodTheme(
      emoji: '😔', category: 'negative',
      gradient: [Color(0xFF93C5FD), Color(0xFF2563EB)],
      subtitle: 'You may be carrying a lot emotionally today.',
      ctaLabel: 'Try Breathing', cardStyle: 'BLURRED_DARK_GLASS',
    ),
    'Lonely': MoodTheme(
      emoji: '🥺', category: 'negative',
      gradient: [Color(0xFFC4B5FD), Color(0xFF7C3AED)],
      subtitle: 'You are feeling isolated right now.',
      ctaLabel: 'Seek Connection', cardStyle: 'BLURRED_DARK_GLASS',
    ),
    'Angry': MoodTheme(
      emoji: '😡', category: 'negative',
      gradient: [Color(0xFFFCA5A5), Color(0xFFDC2626)],
      subtitle: 'There is a lot of heated energy trapped inside you.',
      ctaLabel: 'Release Tension', cardStyle: 'BLURRED_DARK_GLASS',
    ),
    'Stressed': MoodTheme(
      emoji: '😫', category: 'negative',
      gradient: [Color(0xFFFDBA74), Color(0xFFEA580C)],
      subtitle: 'The weight of everything is pressing down on you.',
      ctaLabel: 'Reduce Load', cardStyle: 'BLURRED_DARK_GLASS',
    ),
    'Burned Out': MoodTheme(
      emoji: '😩', category: 'negative',
      gradient: [Color(0xFFF97316), Color(0xFF78350F)],
      subtitle: 'Your energy appears depleted and stretched extremely thin.',
      ctaLabel: 'Recovery Mode', cardStyle: 'FADING_ORANGE_GLASS',
    ),
    'Anxious': MoodTheme(
      emoji: '😟', category: 'negative',
      gradient: [Color(0xFFA78BFA), Color(0xFF4C1D95)],
      subtitle: 'Your mind may be moving faster than your body can keep up.',
      ctaLabel: 'Ground Yourself', cardStyle: 'PURPLE_GLOW_GLASS',
    ),
    'Depressed': MoodTheme(
      emoji: '😞', category: 'critical',
      gradient: [Color(0xFF4B5563), Color(0xFF111827)],
      subtitle: 'You may be feeling disconnected, exhausted, or emotionally heavy.',
      ctaLabel: 'Get Support', cardStyle: 'DARK_MUTED_GLASS',
    ),
    'Panic': MoodTheme(
      emoji: '😨', category: 'critical',
      gradient: [Color(0xFFEF4444), Color(0xFF7F1D1D)],
      subtitle: 'Your nervous system is overwhelmed right now.',
      ctaLabel: 'Emergency Grounding', cardStyle: 'HIGH_CONTRAST_CRISIS',
    ),
    'Unsafe': MoodTheme(
      emoji: '💔', category: 'critical',
      gradient: [Color(0xFFDC2626), Color(0xFF450A0A)],
      subtitle: 'Your safety is our absolute priority.',
      ctaLabel: 'Call For Help', cardStyle: 'HIGH_CONTRAST_CRISIS',
    ),
    'Hopeless': MoodTheme(
      emoji: '🥀', category: 'critical',
      gradient: [Color(0xFF374151), Color(0xFF000000)],
      subtitle: 'The darkness feels heavy right now. Please hold on.',
      ctaLabel: 'Find Light', cardStyle: 'HIGH_CONTRAST_CRISIS',
    ),
  };

  static MoodTheme getTheme(String mood) {
    return registry[mood] ?? registry['Neutral']!;
  }

  /// Returns card decoration based on cardStyle string
  static BoxDecoration getCardDecoration(String cardStyle, Color primaryColor) {
    switch (cardStyle) {
      case 'BRIGHT_GLASS':
        return BoxDecoration(
          color: primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
        );
      case 'SOFT_GLASS':
        return BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
        );
      case 'MUTED_GLASS':
        return BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        );
      case 'BLURRED_DARK_GLASS':
        return BoxDecoration(
          color: primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.1), blurRadius: 20)],
        );
      case 'PURPLE_GLOW_GLASS':
        return BoxDecoration(
          color: primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.15), blurRadius: 30, spreadRadius: 2)],
        );
      case 'FADING_ORANGE_GLASS':
        return BoxDecoration(
          color: primaryColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
        );
      case 'DARK_MUTED_GLASS':
        return BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        );
      case 'HIGH_CONTRAST_CRISIS':
        return BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
        );
      default:
        return BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        );
    }
  }
}

class MoodTheme {
  final String emoji;
  final String category;
  final List<Color> gradient;
  final String subtitle;
  final String ctaLabel;
  final String cardStyle;

  const MoodTheme({
    required this.emoji,
    required this.category,
    required this.gradient,
    required this.subtitle,
    required this.ctaLabel,
    required this.cardStyle,
  });
}
