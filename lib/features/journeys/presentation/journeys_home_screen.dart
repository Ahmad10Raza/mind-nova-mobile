import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/colors/app_colors.dart';
import '../../../core/design/typography/app_typography.dart';
import '../../../core/design/spacing/app_spacing.dart';
import '../../../core/design/surfaces/app_surfaces.dart';
import '../../../core/design/radius/app_radius.dart';
import '../../../core/design/gradients/app_gradients.dart';

import '../data/journey_data.dart';
import 'widgets/journey_hero_section.dart';
import 'widgets/journey_card.dart';
import 'widgets/journey_day_flow.dart';

/// The Guided Healing Journeys Home — emotional progression engine.
/// NOT a self-improvement challenge system. A healing pathway.
class JourneysHomeScreen extends StatelessWidget {
  const JourneysHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── 1. Welcome Hero ─────────────────────────────
          const SliverToBoxAdapter(
            child: JourneyHeroSection(),
          ),

          // ─── 2. Nova Guidance ───────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24, AppSpacing.s32, AppSpacing.s24, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s20),
                decoration: BoxDecoration(
                  color: AppColors.novaPurple.withOpacity(0.06),
                  borderRadius: AppRadius.md,
                  border: Border.all(color: AppColors.novaPurple.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s8),
                      decoration: BoxDecoration(
                        color: AppColors.novaPurple.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppColors.novaPurple, size: 18),
                    ),
                    AppSpacing.h12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nova recommends',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.novaPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AppSpacing.v4,
                          Text(
                            'Based on your recent mood, the Anxiety Reset journey might feel supportive right now.',
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── 3. Featured Journeys (full cards) ──────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24, AppSpacing.s32, AppSpacing.s24, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Healing pathways', style: AppTypography.headingMedium),
                  AppSpacing.v4,
                  Text(
                    'Guided step-by-step emotional healing',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                  ),
                  AppSpacing.v16,
                  ...GuidedJourneys.all.take(3).map((journey) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                      child: JourneyCard(
                        journey: journey,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JourneyDetailScreen(journey: journey),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ─── 4. Beginner Journeys (horizontal) ──────────
          SliverPadding(
            padding: const EdgeInsets.only(top: AppSpacing.s24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.s24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gentle starts', style: AppTypography.headingMedium),
                        AppSpacing.v4,
                        Text(
                          'Beginner-friendly healing paths',
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
                      itemCount: GuidedJourneys.gentle.length,
                      separatorBuilder: (_, __) => AppSpacing.h12,
                      itemBuilder: (context, index) {
                        final journey = GuidedJourneys.gentle[index];
                        return JourneyCardCompact(
                          journey: journey,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JourneyDetailScreen(journey: journey),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── 5. Therapist-Guided (horizontal) ───────────
          if (GuidedJourneys.therapistGuided.isNotEmpty)
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
                          Row(
                            children: [
                              Text('Therapist-guided', style: AppTypography.headingMedium),
                              AppSpacing.h8,
                              const Icon(Icons.verified_rounded, color: AppColors.calmTeal, size: 14),
                            ],
                          ),
                          AppSpacing.v4,
                          Text(
                            'Professional support woven in',
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
                        itemCount: GuidedJourneys.therapistGuided.length,
                        separatorBuilder: (_, __) => AppSpacing.h12,
                        itemBuilder: (context, index) {
                          final journey = GuidedJourneys.therapistGuided[index];
                          return JourneyCardCompact(
                            journey: journey,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JourneyDetailScreen(journey: journey),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ─── 6. More Journeys ───────────────────────────
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
                        Text('All journeys', style: AppTypography.headingMedium),
                        AppSpacing.v4,
                        Text(
                          'Explore every healing path',
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
                      itemCount: GuidedJourneys.all.length,
                      separatorBuilder: (_, __) => AppSpacing.h12,
                      itemBuilder: (context, index) {
                        final journey = GuidedJourneys.all[index];
                        return JourneyCardCompact(
                          journey: journey,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JourneyDetailScreen(journey: journey),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Reassurance footer ─────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24, AppSpacing.s24, AppSpacing.s24, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: AppRadius.sm,
                ),
                child: Text(
                  'There is no timeline for healing. You can pause, rest, and return. That is part of the journey.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// ========================================================================
// JOURNEY DETAIL SCREEN — Immersive journey overview + daily flow
// ========================================================================

class JourneyDetailScreen extends StatelessWidget {
  final GuidedHealingJourney journey;

  const JourneyDetailScreen({super.key, required this.journey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Gradient header
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: journey.gradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.radiusXL),
                  bottomRight: Radius.circular(AppRadius.radiusXL),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s24, AppSpacing.s16, AppSpacing.s24, AppSpacing.s40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: AppRadius.sm,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
                        ),
                      ),
                      AppSpacing.v32,
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(journey.icon, color: Colors.white, size: 32),
                      ),
                      AppSpacing.v24,
                      Text(journey.title, style: AppTypography.heroXL.copyWith(color: Colors.white)),
                      AppSpacing.v8,
                      Text(journey.emotionalIntent, style: AppTypography.body.copyWith(color: Colors.white60, fontStyle: FontStyle.italic)),
                      AppSpacing.v16,
                      Row(
                        children: [
                          _chip(journey.duration),
                          AppSpacing.h8,
                          _chip(journey.difficulty),
                          if (journey.isTherapistGuided) ...[
                            AppSpacing.h8,
                            _chip('Therapist-guided'),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Journey days
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24, AppSpacing.s32, AppSpacing.s24, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your healing path', style: AppTypography.headingMedium),
                  AppSpacing.v4,
                  Text(
                    '${journey.days.length} days of guided steps',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                  ),
                  AppSpacing.v24,
                  ...journey.days.map((day) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s32),
                      child: JourneyDayFlow(day: day, accentColor: journey.color),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Begin CTA
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24, 0, AppSpacing.s24, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
                  // Begin the first day
                  if (journey.days.isNotEmpty && journey.days.first.steps.isNotEmpty) {
                    final firstRoute = journey.days.first.steps.first.route;
                    if (firstRoute != null) context.push(firstRoute);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                  decoration: BoxDecoration(
                    gradient: journey.gradient,
                    borderRadius: AppRadius.full,
                    boxShadow: [
                      BoxShadow(
                        color: journey.color.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Begin Your Journey',
                      style: AppTypography.button.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Compassion note
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24, AppSpacing.s24, AppSpacing.s24, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: AppRadius.sm,
                ),
                child: Text(
                  'Healing is not linear. If you need to pause, that is part of the journey too.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: AppRadius.full,
      ),
      child: Text(text, style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 11)),
    );
  }
}

// ========================================================================
// COMPASSIONATE RETURN SCREEN — When users come back after pausing
// ========================================================================

class CompassionateReturnScreen extends StatelessWidget {
  final GuidedHealingJourney journey;
  final int lastDay;

  const CompassionateReturnScreen({
    super.key,
    required this.journey,
    required this.lastDay,
  });

  @override
  Widget build(BuildContext context) {
    final message = CompassionateMessages.getPauseMessage();

    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: Column(
            children: [
              const Spacer(),

              // Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.s20),
                decoration: BoxDecoration(
                  color: journey.color.withOpacity(0.08),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: journey.color.withOpacity(0.1),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(journey.icon, color: journey.color.withOpacity(0.6), size: 40),
              ),
              AppSpacing.v32,

              Text(
                'Welcome back.',
                style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              AppSpacing.v16,
              Text(
                message,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.v12,
              Text(
                'You were on Day $lastDay of ${journey.title}.',
                style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Continue
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JourneyDetailScreen(journey: journey),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                  decoration: BoxDecoration(
                    gradient: journey.gradient,
                    borderRadius: AppRadius.full,
                  ),
                  child: Center(
                    child: Text(
                      'Continue My Journey',
                      style: AppTypography.button.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
              AppSpacing.v12,

              // Not now
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: AppRadius.full,
                  ),
                  child: Center(
                    child: Text("Not right now", style: AppTypography.button),
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
