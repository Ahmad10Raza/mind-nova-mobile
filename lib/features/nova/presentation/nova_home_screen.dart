import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/colors/app_colors.dart';
import '../../../core/design/typography/app_typography.dart';
import '../../../core/design/spacing/app_spacing.dart';
import '../../../core/design/surfaces/app_surfaces.dart';
import '../../../core/design/radius/app_radius.dart';
import '../../../core/design/shadows/app_shadows.dart';
import '../../../core/design/gradients/app_gradients.dart';

import '../data/nova_personality.dart';
import 'widgets/nova_avatar_widget.dart';

/// Nova's emotional home — the entry point to the companion experience.
/// This is NOT a chat screen. It's an emotionally guided lobby.
class NovaHomeScreen extends StatelessWidget {
  const NovaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = NovaPersonality.getGreeting(hour);

    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── 1. Emotional Greeting Hero ──────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s24, AppSpacing.s32, AppSpacing.s24, AppSpacing.s32,
                ),
                child: Column(
                  children: [
                    // Breathing Nova avatar
                    const NovaAvatarWidget(size: 96, isActive: true),
                    AppSpacing.v24,

                    Text(
                      greeting,
                      style: AppTypography.headingLarge,
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.v8,
                    Text(
                      "I'm here whenever you're ready.",
                      style: AppTypography.body.copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.v32,

                    // Start Conversation CTA
                    GestureDetector(
                      onTap: () => context.push('/nova-chat'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.s16,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppGradients.nova,
                          borderRadius: AppRadius.full,
                          boxShadow: AppShadows.glowPurple,
                        ),
                        child: Center(
                          child: Text(
                            'Talk to Nova',
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

          // ─── 2. Suggested Emotional Support ─────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How can I help?',
                    style: AppTypography.headingMedium,
                  ),
                  AppSpacing.v16,
                  ...NovaPersonality.conversationStarters.map((suggestion) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                      child: GestureDetector(
                        onTap: () => context.push('/nova-chat'),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.s16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSecondary,
                            borderRadius: AppRadius.md,
                            boxShadow: AppShadows.shadowSubtle,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.s8),
                                decoration: BoxDecoration(
                                  color: suggestion.color.withOpacity(0.12),
                                  borderRadius: AppRadius.sm,
                                ),
                                child: Icon(suggestion.icon, color: suggestion.color, size: 20),
                              ),
                              AppSpacing.h12,
                              Expanded(
                                child: Text(
                                  suggestion.text,
                                  style: AppTypography.body,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.textMuted,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ─── 3. Guided Flows ────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24, AppSpacing.s32, AppSpacing.s24, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guided support',
                    style: AppTypography.headingMedium,
                  ),
                  AppSpacing.v4,
                  Text(
                    'Structured emotional guidance',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                  ),
                  AppSpacing.v16,
                  ...NovaGuidedFlows.all.take(4).map((flow) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                      child: GestureDetector(
                        onTap: () => context.push('/nova-chat'),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.s16),
                          decoration: BoxDecoration(
                            color: flow.color.withOpacity(0.06),
                            borderRadius: AppRadius.md,
                            border: Border.all(color: flow.color.withOpacity(0.12)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.s8),
                                decoration: BoxDecoration(
                                  color: flow.color.withOpacity(0.12),
                                  borderRadius: AppRadius.sm,
                                ),
                                child: Icon(flow.icon, color: flow.color, size: 20),
                              ),
                              AppSpacing.h12,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(flow.title, style: AppTypography.headingMedium.copyWith(fontSize: 15)),
                                    AppSpacing.v4,
                                    Text(
                                      flow.subtitle,
                                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: flow.color.withOpacity(0.5),
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ─── 4. Disclaimer ──────────────────────────────
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
                  'Nova is an AI companion, not a therapist. For professional support, please reach out to a licensed professional.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );
  }
}
