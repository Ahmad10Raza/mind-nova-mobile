import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/breathing_model.dart';
import './widgets/custom_breathing_dialog.dart';
import '../providers/breathing_persistence_provider.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/design/surfaces/app_surfaces.dart';

class BreathingIntroScreen extends ConsumerWidget {
  const BreathingIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppSurfaces.primary,
        appBar: AppBar(
          title: Text('Mindfulness Breathing', style: AppTypography.headingMedium),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            indicatorColor: AppColors.novaPurple,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: AppTypography.labelMedium,
            dividerColor: Colors.white.withOpacity(0.05),
            tabs: const [
              Tab(text: 'Techniques'),
              Tab(text: 'My Sessions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DefaultTechniquesTab(),
            _MySavedSessionsTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 1: Default Techniques ─────────────────────────────────────
class _DefaultTechniquesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final techniques = BreathingTechnique.defaults;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a Technique',
            style: AppTypography.headingLarge,
          ),
          AppSpacing.v8,
          Text(
            'Select a rhythm that fits your current state. Each technique is designed for a specific mental goal.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
          AppSpacing.v32,
          ...techniques.map((t) => _buildTechniqueCard(context, t)),
          _buildCustomCard(context),
        ],
      ),
    );
  }

  Widget _buildTechniqueCard(BuildContext context, BreathingTechnique technique) {
    return GestureDetector(
      onTap: () => context.push('/breathing/exercise', extra: technique),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s16),
        padding: const EdgeInsets.all(AppSpacing.s20),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary.withOpacity(0.5),
          borderRadius: AppRadius.xl,
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: AppColors.novaPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.air, color: AppColors.novaPurple),
            ),
            AppSpacing.h16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(technique.name, style: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary)),
                  AppSpacing.v4,
                  Text(technique.description, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                  AppSpacing.v8,
                  Text(
                    'Rhythm: ${technique.inhale}-${technique.holdIn}-${technique.exhale}-${technique.holdOut}',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.novaPurple),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const CustomBreathingDialog(),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s16),
        padding: const EdgeInsets.all(AppSpacing.s20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: AppRadius.xl,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.settings_suggest_outlined, color: AppColors.textMuted),
            AppSpacing.h16,
            Text(
              'Create Custom Interval',
              style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            const Icon(Icons.add, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 2: My Saved Sessions ──────────────────────────────────────
class _MySavedSessionsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customAsync = ref.watch(customBreathingProvider);

    return customAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.novaPurple)),
      error: (e, _) => Center(
        child: Text('Could not load sessions', style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted)),
      ),
      data: (sessions) {
        if (sessions.isEmpty) {
          return _buildEmptyState(context);
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Custom Rhythms',
                style: AppTypography.headingLarge,
              ),
              AppSpacing.v8,
              Text(
                'These are your personally crafted breathing sessions.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
              ),
              AppSpacing.v24,
              ...sessions.map((t) => _buildSavedCard(context, ref, t)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.air_outlined, size: 64, color: AppColors.textMuted.withOpacity(0.3)),
            AppSpacing.v16,
            Text(
              'No custom sessions yet',
              style: AppTypography.headingSmall.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.v8,
            Text(
              'Create a custom breathing rhythm and it will appear here for quick access.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
            AppSpacing.v24,
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const CustomBreathingDialog(),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Custom'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.novaPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCard(BuildContext context, WidgetRef ref, BreathingTechnique technique) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withOpacity(0.5),
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.novaPurple.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.calmTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.waves_rounded, color: AppColors.calmTeal),
          ),
          AppSpacing.h16,
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/breathing/exercise', extra: technique),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(technique.name, style: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary)),
                  AppSpacing.v4,
                  Text(
                    'Rhythm: ${technique.inhale}-${technique.holdIn}-${technique.exhale}-${technique.holdOut}',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.novaPurple),
                  ),
                  if (technique.targetCycles != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${technique.targetCycles} cycles',
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: AppColors.textMuted.withOpacity(0.6), size: 20),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfaceHighest,
                  title: Text('Delete "${technique.name}"?', style: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary)),
                  content: Text('This will permanently remove this custom rhythm.', style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: AppColors.emotionalDangerMuted))),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(customBreathingProvider.notifier).remove(technique.id);
              }
            },
          ),
        ],
      ),
    );
  }
}
