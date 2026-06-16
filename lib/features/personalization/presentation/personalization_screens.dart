import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/colors/app_colors.dart';
import '../../../core/design/typography/app_typography.dart';
import '../../../core/design/spacing/app_spacing.dart';
import '../../../core/design/surfaces/app_surfaces.dart';
import '../../../core/design/radius/app_radius.dart';

import '../data/emotional_profile.dart';
import '../engine/personalization_providers.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/adaptive_mode_indicator.dart';

/// Personalization insight screen — shows the user how MindNova
/// adapts to their emotional state. Transparent, not creepy.
class PersonalizationInsightScreen extends ConsumerWidget {
  const PersonalizationInsightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(emotionalProfileProvider);
    final recommendations = ref.watch(emotionalRecommendationsProvider);
    final uiMode = ref.watch(adaptiveUIModeProvider);
    final novaTone = ref.watch(novaToneProvider);
    final pacingAdvice = ref.watch(journeyPacingProvider);

    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      appBar: AppBar(
        backgroundColor: AppSurfaces.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textSecondary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('How MindNova adapts', style: AppTypography.headingMedium.copyWith(fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        physics: const BouncingScrollPhysics(),
        children: [
          // Transparency header
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.novaPurple.withOpacity(0.06),
              borderRadius: AppRadius.md,
            ),
            child: Column(
              children: [
                const Icon(Icons.visibility_rounded, color: AppColors.novaPurple, size: 24),
                AppSpacing.v12,
                Text(
                  'MindNova adapts gently to support you.\nHere\'s how — always transparent.',
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          AppSpacing.v32,

          // Current mode
          Text('Current experience mode', style: AppTypography.headingMedium),
          AppSpacing.v12,
          AdaptiveModeIndicator(mode: uiMode),
          AppSpacing.v8,
          Text(
            _modeExplanation(uiMode),
            style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontStyle: FontStyle.italic),
          ),
          AppSpacing.v32,

          // Your emotional state
          Text('What we understand', style: AppTypography.headingMedium),
          AppSpacing.v4,
          Text(
            'Soft observations, not labels',
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
          AppSpacing.v16,
          _statRow('Stress level', '${profile.stressLevel}/5', _stressColor(profile.stressLevel)),
          AppSpacing.v8,
          _statRow('Energy level', '${profile.energyLevel}/5', _energyColor(profile.energyLevel)),
          AppSpacing.v8,
          _statRow('Sleep quality', profile.sleepQuality.name, _sleepColor(profile.sleepQuality)),
          AppSpacing.v8,
          _statRow('Recovery state', profile.recoveryState.name, _recoveryColor(profile.recoveryState)),
          AppSpacing.v8,
          _statRow('Nova tone', novaTone.name, AppColors.novaPurple),
          AppSpacing.v32,

          // Journey pacing
          Text('Healing pace', style: AppTypography.headingMedium),
          AppSpacing.v12,
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.calmTeal.withOpacity(0.06),
              borderRadius: AppRadius.md,
            ),
            child: Row(
              children: [
                Icon(Icons.speed_rounded, color: AppColors.calmTeal, size: 18),
                AppSpacing.h12,
                Expanded(
                  child: Text(
                    pacingAdvice,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.v32,

          // Recommendations
          Text('Suggestions for you', style: AppTypography.headingMedium),
          AppSpacing.v4,
          Text(
            'Based on emotional patterns, not engagement',
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
          AppSpacing.v16,
          ...recommendations.map((rec) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s12),
              child: RecommendationCard(recommendation: rec),
            );
          }),
          AppSpacing.v24,

          // Privacy note
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: AppRadius.sm,
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, color: AppColors.calmTeal, size: 16),
                AppSpacing.h8,
                Expanded(
                  child: Text(
                    'Your emotional data stays on your device. You can control what MindNova remembers.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: AppRadius.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: AppRadius.full,
            ),
            child: Text(
              value,
              style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  String _modeExplanation(AdaptiveUIMode mode) {
    switch (mode) {
      case AdaptiveUIMode.calm:
        return 'Reduced motion and visual density to support emotional calmness.';
      case AdaptiveUIMode.recovery:
        return 'Minimal stimulation. Focused on rest and nervous system healing.';
      case AdaptiveUIMode.focused:
        return 'Clean layout for clear thinking. You seem ready for deeper work.';
      case AdaptiveUIMode.standard:
        return 'Full experience. Balanced emotional support.';
    }
  }

  Color _stressColor(int level) =>
      level >= 4 ? AppColors.warmSupport : level >= 3 ? AppColors.emotionalWarning : AppColors.calmTeal;

  Color _energyColor(int level) =>
      level <= 2 ? AppColors.warmSupport : level >= 4 ? AppColors.calmTeal : AppColors.textSecondary;

  Color _sleepColor(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.poor: return AppColors.warmSupport;
      case SleepQuality.moderate: return AppColors.textSecondary;
      case SleepQuality.good: return AppColors.calmTeal;
    }
  }

  Color _recoveryColor(RecoveryState state) {
    switch (state) {
      case RecoveryState.stable: return AppColors.calmTeal;
      case RecoveryState.recovering: return AppColors.novaPurple;
      case RecoveryState.exhausted: return AppColors.warmSupport;
      case RecoveryState.burnout: return AppColors.warmSupport;
    }
  }
}

// ========================================================================
// EMOTIONAL MEMORY CONTROLS
// ========================================================================

class EmotionalMemoryControlsScreen extends ConsumerWidget {
  const EmotionalMemoryControlsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(emotionalMemorySettingsProvider);

    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      appBar: AppBar(
        backgroundColor: AppSurfaces.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textSecondary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Emotional memory', style: AppTypography.headingMedium.copyWith(fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        physics: const BouncingScrollPhysics(),
        children: [
          // Explanation
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.novaPurple.withOpacity(0.06),
              borderRadius: AppRadius.md,
            ),
            child: Column(
              children: [
                const Icon(Icons.privacy_tip_rounded, color: AppColors.novaPurple, size: 24),
                AppSpacing.v12,
                Text(
                  'MindNova remembers your preferences to support you better. You control what is remembered.',
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          AppSpacing.v32,

          Text('What MindNova remembers', style: AppTypography.headingMedium),
          AppSpacing.v16,

          _toggleRow(
            'Preferred tools',
            'Remember which tools help you most',
            settings.rememberPreferredTools,
            (val) {
              ref.read(emotionalMemorySettingsProvider.notifier).update(EmotionalMemorySettings(
                rememberPreferredTools: val,
                rememberCalmingBehaviors: settings.rememberCalmingBehaviors,
                rememberRecoveryPreferences: settings.rememberRecoveryPreferences,
                allowAdaptiveUI: settings.allowAdaptiveUI,
                allowNovaAdaptation: settings.allowNovaAdaptation,
              ));
            },
          ),
          AppSpacing.v12,

          _toggleRow(
            'Calming behaviors',
            'Track what calms your nervous system',
            settings.rememberCalmingBehaviors,
            (val) {
              ref.read(emotionalMemorySettingsProvider.notifier).update(EmotionalMemorySettings(
                rememberPreferredTools: settings.rememberPreferredTools,
                rememberCalmingBehaviors: val,
                rememberRecoveryPreferences: settings.rememberRecoveryPreferences,
                allowAdaptiveUI: settings.allowAdaptiveUI,
                allowNovaAdaptation: settings.allowNovaAdaptation,
              ));
            },
          ),
          AppSpacing.v12,

          _toggleRow(
            'Recovery preferences',
            'Remember recovery modes and pacing',
            settings.rememberRecoveryPreferences,
            (val) {
              ref.read(emotionalMemorySettingsProvider.notifier).update(EmotionalMemorySettings(
                rememberPreferredTools: settings.rememberPreferredTools,
                rememberCalmingBehaviors: settings.rememberCalmingBehaviors,
                rememberRecoveryPreferences: val,
                allowAdaptiveUI: settings.allowAdaptiveUI,
                allowNovaAdaptation: settings.allowNovaAdaptation,
              ));
            },
          ),
          AppSpacing.v32,

          Text('Adaptive behavior', style: AppTypography.headingMedium),
          AppSpacing.v16,

          _toggleRow(
            'Adaptive UI',
            'Let MindNova adjust layouts based on state',
            settings.allowAdaptiveUI,
            (val) {
              ref.read(emotionalMemorySettingsProvider.notifier).update(EmotionalMemorySettings(
                rememberPreferredTools: settings.rememberPreferredTools,
                rememberCalmingBehaviors: settings.rememberCalmingBehaviors,
                rememberRecoveryPreferences: settings.rememberRecoveryPreferences,
                allowAdaptiveUI: val,
                allowNovaAdaptation: settings.allowNovaAdaptation,
              ));
            },
          ),
          AppSpacing.v12,

          _toggleRow(
            'Nova adaptation',
            'Let Nova adjust tone and pacing',
            settings.allowNovaAdaptation,
            (val) {
              ref.read(emotionalMemorySettingsProvider.notifier).update(EmotionalMemorySettings(
                rememberPreferredTools: settings.rememberPreferredTools,
                rememberCalmingBehaviors: settings.rememberCalmingBehaviors,
                rememberRecoveryPreferences: settings.rememberRecoveryPreferences,
                allowAdaptiveUI: settings.allowAdaptiveUI,
                allowNovaAdaptation: val,
              ));
            },
          ),
          AppSpacing.v32,

          // Clear all
          GestureDetector(
            onTap: () {
              // Reset everything
              ref.read(emotionalMemorySettingsProvider.notifier).update(const EmotionalMemorySettings());
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: AppRadius.full,
              ),
              child: Center(
                child: Text(
                  'Reset emotional memory',
                  style: AppTypography.button.copyWith(color: AppColors.warmSupport),
                ),
              ),
            ),
          ),
          AppSpacing.v16,

          // Privacy note
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: AppRadius.sm,
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, color: AppColors.calmTeal, size: 16),
                AppSpacing.h8,
                Expanded(
                  child: Text(
                    'Emotional memory stays on your device. It is never shared or sold.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _toggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: AppRadius.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headingMedium.copyWith(fontSize: 14)),
                AppSpacing.v4,
                Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.novaPurple,
          ),
        ],
      ),
    );
  }
}
