import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/colors/app_colors.dart';
import '../../../core/design/typography/app_typography.dart';
import '../../../core/design/spacing/app_spacing.dart';


import 'widgets/sanctuary_background_painter.dart';
import 'widgets/recovery_hero_section.dart';
import 'widgets/recovery_pathways_section.dart';
import 'widgets/recovery_journeys_section.dart';
import 'widgets/recovery_coach_section.dart';
import 'widgets/recovery_library_section.dart';
import 'widgets/recovery_stats_section.dart';
import 'widgets/recovery_recent_section.dart';

class MeditationDashboardScreen extends ConsumerStatefulWidget {
  const MeditationDashboardScreen({super.key});

  @override
  ConsumerState<MeditationDashboardScreen> createState() =>
      _MeditationDashboardScreenState();
}

class _MeditationDashboardScreenState
    extends ConsumerState<MeditationDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _particleController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              painter: SanctuaryBackgroundPainter(
                _particleController.value,
                _pulseController.value,
              ),
              child: const SizedBox.expand(),
            ),
          ),

          // Main content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── App Bar ───────────────────────────────────────
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                expandedHeight: 0,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withAlpha(30)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 16),
                  ),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  'Recovery Sanctuary',
                  style: AppTypography.headingM
                      .copyWith(color: AppColors.textPrimary),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white.withAlpha(30)),
                      ),
                      child: const Icon(Icons.history_rounded,
                          color: Colors.white, size: 18),
                    ),
                    onPressed: () => context.push('/meditation/history'),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // ─── 1. Hero Section ──────────────────────────────
              SliverToBoxAdapter(
                child: RecoveryHeroSection(floatAnimation: _floatAnimation),
              ),

              // ─── 2. Emotional Recovery Pathways ───────────────
              SliverToBoxAdapter(
                child: _buildSectionTitle('Emotional Recovery Pathways'),
              ),
              const SliverToBoxAdapter(
                child: RecoveryPathwaysSection(),
              ),

              // ─── 3. Guided Recovery Journeys ──────────────────
              SliverToBoxAdapter(
                child: _buildSectionTitle('Guided Recovery Journeys'),
              ),
              const SliverToBoxAdapter(
                child: RecoveryJourneysSection(),
              ),

              // ─── 4. Nova Recovery Coach ────────────────────────
              SliverToBoxAdapter(
                child: _buildSectionTitle('Nova Recovery Coach 🧠'),
              ),
              const SliverToBoxAdapter(
                child: RecoveryCoachSection(),
              ),

              // ─── 5. Recovery Library ──────────────────────────
              SliverToBoxAdapter(
                child: _buildSectionTitle('Recovery Library'),
              ),
              const SliverToBoxAdapter(
                child: RecoveryLibrarySection(),
              ),

              // ─── 6. Recovery Stats ────────────────────────────
              SliverToBoxAdapter(
                child: _buildSectionTitle('Your Recovery Stats 📊'),
              ),
              const SliverToBoxAdapter(
                child: RecoveryStatsSection(),
              ),

              // ─── 7. Recent Sessions ───────────────────────────
              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  'Recent Sessions',
                  trailing: GestureDetector(
                    onTap: () => context.push('/meditation/history'),
                    child: Text(
                      'View All',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.novaPurple),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: RecoveryRecentSection(),
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s24, AppSpacing.s24, AppSpacing.s24, AppSpacing.s12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            title,
            style: AppTypography.headingM
                .copyWith(color: AppColors.textPrimary, fontSize: 18),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
