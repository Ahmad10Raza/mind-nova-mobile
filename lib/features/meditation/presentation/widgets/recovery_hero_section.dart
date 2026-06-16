import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

import '../providers/meditation_provider.dart';

class RecoveryHeroSection extends ConsumerWidget {
  final Animation<double> floatAnimation;
  const RecoveryHeroSection({super.key, required this.floatAnimation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(meditationDashboardProvider);
    final catalogAsync = ref.watch(meditationCatalogProvider(null));
    final firstItem = catalogAsync.asData?.value.isNotEmpty == true
        ? catalogAsync.asData!.value.first
        : null;

    return AnimatedBuilder(
      animation: floatAnimation,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, AppSpacing.s8),
          child: Container(
            constraints: const BoxConstraints(minHeight: 320),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1060),
                  AppColors.backgroundPrimary.withAlpha(230),
                  const Color(0xFF0A0820),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: AppRadius.xl,
              border: Border.all(color: Colors.white.withAlpha(20)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.novaPurpleDark.withAlpha(76),
                  blurRadius: 48,
                  spreadRadius: -6,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Floating orbs
                Positioned(
                  right: -20,
                  top: -20 + (floatAnimation.value * 14),
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.novaPurple.withAlpha(102),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 30,
                  bottom: -30 + (floatAnimation.value * 10),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.calmTeal.withAlpha(64),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.s24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.novaPurple.withAlpha(64),
                          borderRadius: AppRadius.pill,
                          border: Border.all(
                              color: AppColors.novaPurple.withAlpha(128)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🧠',
                                style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              'NOVA INTELLIGENCE',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.novaPurpleLight,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.v16,

                      // Title
                      Text(
                        'Recovery\nSanctuary',
                        style: AppTypography.headingXL.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 30,
                          height: 1.15,
                        ),
                      ),
                      AppSpacing.v12,

                      // Nova Insight
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(13),
                          borderRadius: AppRadius.md,
                          border:
                              Border.all(color: Colors.white.withAlpha(20)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.emotionalWarning.withAlpha(38),
                                borderRadius: AppRadius.sm,
                              ),
                              child: const Icon(Icons.psychology_rounded,
                                  color: AppColors.warmSupport, size: 16),
                            ),
                            AppSpacing.h8,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nova noticed elevated stress this week.',
                                    style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Recommended: Anxiety Reset · 10 min',
                                    style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.calmTeal),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.v16,

                      // Stat pills
                      dashboardAsync.when(
                        data: (stats) => Row(
                          children: [
                            _buildPill(
                              '📊',
                              '+${stats.averageCalmImprovement.toStringAsFixed(0)}%',
                              'Recovery',
                            ),
                            AppSpacing.h8,
                            _buildPill(
                              '🎯',
                              _formatCategory(
                                  stats.mostEffectiveCategory),
                              'Focus',
                            ),
                            AppSpacing.h8,
                            _buildPill(
                              '💚',
                              'Low',
                              'Risk',
                            ),
                          ],
                        ),
                        loading: () => const SizedBox(height: 34),
                        error: (_, __) => Row(
                          children: [
                            _buildPill('📊', '+0%', 'Recovery'),
                            AppSpacing.h8,
                            _buildPill('🎯', 'None', 'Focus'),
                            AppSpacing.h8,
                            _buildPill('💚', 'Low', 'Risk'),
                          ],
                        ),
                      ),
                      AppSpacing.v20,

                      // CTA
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.push(
                              '/meditation/player',
                              extra: firstItem),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.novaPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.md),
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_arrow_rounded,
                                  size: 20),
                              const SizedBox(width: 6),
                              Text('Begin Recovery',
                                  style: AppTypography.button
                                      .copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPill(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: AppRadius.sm,
          border: Border.all(color: Colors.white.withAlpha(13)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.textMuted, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCategory(String? cat) {
    if (cat == null) return 'None';
    return cat
        .split('_')
        .map((w) => w.isNotEmpty
            ? w[0].toUpperCase() + w.substring(1).toLowerCase()
            : '')
        .join(' ');
  }
}
