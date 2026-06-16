import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/colors/app_colors.dart';
import '../../../core/design/typography/app_typography.dart';
import '../../../core/design/spacing/app_spacing.dart';
import '../../../core/design/surfaces/app_surfaces.dart';
import '../../../core/design/radius/app_radius.dart';

import '../data/recovery_modes.dart';
import 'widgets/recovery_hero_section.dart';
import 'widgets/recovery_mode_card.dart';
import 'widgets/recovery_journey_card.dart';
import 'widgets/recovery_audio_card.dart';
import 'widgets/recovery_insight_widget.dart';

/// The redesigned Recovery Home — an emotional sanctuary.
/// Strict 6-section layout with maximum breathing room.
class RecoveryHomeScreenV2 extends StatelessWidget {
  const RecoveryHomeScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── 1. Emotional Recovery Hero ──────────────────
          const SliverToBoxAdapter(
            child: RecoveryHeroSection(
              insightText: 'You rest better after grounding exercises.',
            ),
          ),

          // ─── 2. Recovery Modes ───────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24, AppSpacing.s32, AppSpacing.s24, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recovery modes', style: AppTypography.headingMedium),
                  AppSpacing.v4,
                  Text(
                    'Choose what your mind needs',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                  ),
                  AppSpacing.v16,
                  // First two modes as full-width immersive cards
                  ...RecoveryModes.all.take(2).map((mode) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                      child: RecoveryModeCard(
                        mode: mode,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecoveryModeScreen(mode: mode),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ─── 3. More modes (horizontal scroll) ──────────
          SliverPadding(
            padding: const EdgeInsets.only(top: AppSpacing.s8),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  itemCount: RecoveryModes.all.length - 2,
                  separatorBuilder: (_, __) => AppSpacing.h12,
                  itemBuilder: (context, index) {
                    final mode = RecoveryModes.all[index + 2];
                    return SizedBox(
                      width: 240,
                      child: RecoveryModeCard(
                        mode: mode,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecoveryModeScreen(mode: mode),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ─── 4. Guided Recovery Journeys ─────────────────
          SliverPadding(
            padding: const EdgeInsets.only(top: AppSpacing.s32),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.s24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Guided journeys', style: AppTypography.headingMedium),
                        AppSpacing.v4,
                        Text(
                          'Multi-step restoration flows',
                          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.v16,
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      itemCount: RecoveryJourneys.all.length,
                      separatorBuilder: (_, __) => AppSpacing.h12,
                      itemBuilder: (context, index) {
                        return RecoveryJourneyCard(
                          journey: RecoveryJourneys.all[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── 5. Calm Audio ───────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24, AppSpacing.s32, AppSpacing.s24, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calm sounds', style: AppTypography.headingMedium),
                  AppSpacing.v16,
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.s12,
                      mainAxisSpacing: AppSpacing.s12,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: RecoveryAudioCategories.all.length,
                    itemBuilder: (context, index) {
                      return RecoveryAudioCard(
                        category: RecoveryAudioCategories.all[index],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ─── 6. Recovery Insight ─────────────────────────
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s24, AppSpacing.s32, AppSpacing.s24, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: RecoveryInsightWidget(
                insightText: 'Your nervous system seems calmer on days you practice grounding. Consider making it part of your evening routine.',
              ),
            ),
          ),

          // ─── Safe Space shortcut ─────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24, AppSpacing.s24, AppSpacing.s24, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SafeSpaceScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  decoration: BoxDecoration(
                    color: AppColors.recoveryBlue.withOpacity(0.08),
                    borderRadius: AppRadius.md,
                    border: Border.all(color: AppColors.recoveryBlue.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s12),
                        decoration: BoxDecoration(
                          color: AppColors.recoveryBlue.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_rounded, color: AppColors.recoveryBlue, size: 22),
                      ),
                      AppSpacing.h16,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter Safe Space',
                              style: AppTypography.headingMedium.copyWith(
                                fontSize: 15,
                                color: AppColors.recoveryBlue,
                              ),
                            ),
                            AppSpacing.v4,
                            Text(
                              'Low-stimulation emergency calm',
                              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.recoveryBlue, size: 14),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// ========================================================================
// RECOVERY MODE SCREEN — Immersive single-mode experience
// ========================================================================

class RecoveryModeScreen extends StatelessWidget {
  final RecoveryMode mode;

  const RecoveryModeScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      body: Container(
        decoration: BoxDecoration(gradient: mode.gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: AppRadius.sm,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  ),
                ),
                const Spacer(),

                // Mode icon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(mode.icon, color: Colors.white, size: 40),
                ),
                AppSpacing.v24,

                // Title
                Text(
                  mode.title,
                  style: AppTypography.heroXL.copyWith(color: Colors.white),
                ),
                AppSpacing.v8,
                Text(
                  mode.emotionalIntent,
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                AppSpacing.v40,

                // Tools
                Text(
                  'Included tools',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.v12,
                ...mode.toolRoutes.map((route) {
                  final toolName = _routeToName(route);
                  final toolIcon = _routeToIcon(route);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                    child: GestureDetector(
                      onTap: () => context.push(route),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: AppRadius.md,
                        ),
                        child: Row(
                          children: [
                            Icon(toolIcon, color: Colors.white, size: 20),
                            AppSpacing.h12,
                            Text(toolName, style: AppTypography.body.copyWith(color: Colors.white)),
                            const Spacer(),
                            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.5), size: 14),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const Spacer(),

                // Start breathing CTA
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImmersiveBreathingScreen(
                        pattern: BreathingPatterns.fromId(mode.breathingPattern),
                        backgroundColor: mode.accentColor,
                      ),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: AppRadius.full,
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        'Begin with Breathing',
                        style: AppTypography.button.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _routeToName(String route) {
    switch (route) {
      case '/breathing': return 'Breathing Exercise';
      case '/grounding': return 'Grounding Exercise';
      case '/meditation': return 'Meditation';
      case '/audio': return 'Calm Sounds';
      case '/sleep': return 'Sleep Support';
      case '/journal': return 'Journal';
      case '/gratitude': return 'Gratitude';
      case '/focus': return 'Focus Session';
      default: return 'Tool';
    }
  }

  IconData _routeToIcon(String route) {
    switch (route) {
      case '/breathing': return Icons.air_rounded;
      case '/grounding': return Icons.spa_rounded;
      case '/meditation': return Icons.self_improvement_rounded;
      case '/audio': return Icons.music_note_rounded;
      case '/sleep': return Icons.bedtime_rounded;
      case '/journal': return Icons.edit_note_rounded;
      case '/gratitude': return Icons.auto_awesome_rounded;
      case '/focus': return Icons.center_focus_strong_rounded;
      default: return Icons.circle_rounded;
    }
  }
}

// ========================================================================
// IMMERSIVE BREATHING SCREEN — Full-screen breathing experience
// ========================================================================

class ImmersiveBreathingScreen extends StatelessWidget {
  final BreathingPattern pattern;
  final Color backgroundColor;

  const ImmersiveBreathingScreen({
    super.key,
    required this.pattern,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: AppRadius.sm,
                      ),
                      child: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                  Column(
                    children: [
                      Text(pattern.name, style: AppTypography.headingMedium.copyWith(fontSize: 15)),
                      Text(
                        pattern.description,
                        style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(width: 44), // Balance
                ],
              ),
            ),

            // Breathing circle (fills remaining space)
            Expanded(
              child: Center(
                child: _buildBreathingCircle(),
              ),
            ),

            // Bottom guidance
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Text(
                'Follow the circle. Breathe naturally.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreathingCircle() {
    // Import the widget inline to avoid circular deps
    return _ImmersiveBreathingAnimation(pattern: pattern);
  }
}

class _ImmersiveBreathingAnimation extends StatefulWidget {
  final BreathingPattern pattern;

  const _ImmersiveBreathingAnimation({required this.pattern});

  @override
  State<_ImmersiveBreathingAnimation> createState() => _ImmersiveBreathingAnimationState();
}

class _ImmersiveBreathingAnimationState extends State<_ImmersiveBreathingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _phase = 'Breathe in';
  int _cycle = 0;

  @override
  void initState() {
    super.initState();
    final total = widget.pattern.totalCycleSeconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: total),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _cycle++;
        _controller.forward(from: 0.0);
      }
    });

    _controller.addListener(() {
      final p = widget.pattern;
      final t = p.totalCycleSeconds.toDouble();
      final progress = _controller.value * t;

      String newPhase;
      if (progress < p.inhaleSeconds) {
        newPhase = 'Breathe in';
      } else if (progress < p.inhaleSeconds + p.holdSeconds) {
        newPhase = 'Hold';
      } else if (progress < p.inhaleSeconds + p.holdSeconds + p.exhaleSeconds) {
        newPhase = 'Breathe out';
      } else {
        newPhase = 'Hold';
      }
      if (newPhase != _phase) {
        setState(() => _phase = newPhase);
        HapticFeedback.selectionClick();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final p = widget.pattern;
        final t = p.totalCycleSeconds.toDouble();
        final progress = _controller.value * t;

        double scale;
        if (progress < p.inhaleSeconds) {
          scale = 0.4 + 0.6 * (progress / p.inhaleSeconds);
        } else if (progress < p.inhaleSeconds + p.holdSeconds) {
          scale = 1.0;
        } else if (progress < p.inhaleSeconds + p.holdSeconds + p.exhaleSeconds) {
          final exhaleProgress = (progress - p.inhaleSeconds - p.holdSeconds) / p.exhaleSeconds;
          scale = 1.0 - 0.6 * exhaleProgress;
        } else {
          scale = 0.4;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 240 * scale,
              height: 240 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.color.withOpacity(0.12),
                border: Border.all(color: p.color.withOpacity(0.25), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: p.color.withOpacity(0.12 * scale),
                    blurRadius: 50,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 130 * scale,
                  height: 130 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.color.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            AppSpacing.v40,
            Text(
              _phase,
              style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
            ),
            AppSpacing.v8,
            Text(
              'Cycle ${_cycle + 1}',
              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
            ),
          ],
        );
      },
    );
  }
}

// ========================================================================
// SAFE SPACE SCREEN — Low-stimulation emergency recovery
// ========================================================================

class SafeSpaceScreen extends StatelessWidget {
  const SafeSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: AppRadius.sm,
                    ),
                    child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.4), size: 20),
                  ),
                ),
              ),

              const Spacer(),

              // Shield icon with soft glow
              Container(
                padding: const EdgeInsets.all(AppSpacing.s24),
                decoration: BoxDecoration(
                  color: AppColors.recoveryBlue.withOpacity(0.08),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.recoveryBlue.withOpacity(0.1),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(Icons.shield_rounded, color: AppColors.recoveryBlue.withOpacity(0.6), size: 48),
              ),
              AppSpacing.v32,

              // Heading
              Text(
                'You are safe here.',
                style: AppTypography.headingLarge.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.v16,

              Text(
                'Nothing to do.\nNothing to fix.\nJust breathe.',
                style: AppTypography.body.copyWith(
                  color: Colors.white.withOpacity(0.4),
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.v40,

              // Grounding prompt
              Container(
                padding: const EdgeInsets.all(AppSpacing.s20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: AppRadius.md,
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Grounding',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.calmTeal.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.v12,
                    Text(
                      'Name 5 things you can see.\nName 4 things you can touch.\nName 3 things you can hear.',
                      style: AppTypography.body.copyWith(
                        color: Colors.white.withOpacity(0.5),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Breathing button
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ImmersiveBreathingScreen(
                      pattern: BreathingPatterns.panicReset,
                      backgroundColor: AppColors.recoveryBlue,
                    ),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.recoveryBlue.withOpacity(0.15),
                    borderRadius: AppRadius.full,
                    border: Border.all(color: AppColors.recoveryBlue.withOpacity(0.25)),
                  ),
                  child: Center(
                    child: Text(
                      'Start Breathing',
                      style: AppTypography.button.copyWith(
                        color: AppColors.recoveryBlue,
                      ),
                    ),
                  ),
                ),
              ),
              AppSpacing.v12,

              // Crisis link
              GestureDetector(
                onTap: () => context.push('/crisis-support'),
                child: Text(
                  'Need to talk to someone?',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withOpacity(0.3),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
