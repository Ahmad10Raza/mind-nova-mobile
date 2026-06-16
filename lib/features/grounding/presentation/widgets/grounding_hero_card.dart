import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/grounding_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

class GroundingHeroCard extends ConsumerStatefulWidget {
  const GroundingHeroCard({super.key});

  @override
  ConsumerState<GroundingHeroCard> createState() => _GroundingHeroCardState();
}

class _GroundingHeroCardState extends ConsumerState<GroundingHeroCard>
    with SingleTickerProviderStateMixin {
  final List<String> _messages = [
    "Reconnect with the present moment",
    "Take a pause and ground yourself",
    "You are safe right now",
    "Let's slow things down together",
    "This moment is enough",
    "You are here. You are okay.",
  ];

  int _msgIndex = 0;
  late Timer _msgTimer;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _msgTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _msgIndex = (_msgIndex + 1) % _messages.length);
    });

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _msgTimer.cancel();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(groundingDashboardProvider);

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.s20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.backgroundTertiary,
                const Color(0xFF0D6B6B).withAlpha(180),
                AppColors.backgroundSecondary,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            borderRadius: AppRadius.xl,
            border: Border.all(color: Colors.white.withAlpha(13)),
            boxShadow: [
              BoxShadow(
                color: AppColors.calmTeal.withAlpha((_glowAnimation.value * 100).toInt()),
                blurRadius: 40,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.spa_rounded, color: AppColors.calmTeal, size: 22),
                  ),
                  AppSpacing.h12,
                  Text(
                    "GROUNDING SPACE",
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.calmTeal,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              AppSpacing.v20,
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  _messages[_msgIndex],
                  key: ValueKey(_msgIndex),
                  style: AppTypography.headingXL.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
              AppSpacing.v24,
              dashboardAsync.when(
                data: (dashboard) => Row(
                  children: [
                    _buildStat("${dashboard.currentStreak}d", "Streak", Icons.local_fire_department_rounded),
                    _buildDivider(),
                    _buildStat("${dashboard.totalSessions}", "Sessions", Icons.self_improvement_rounded),
                    _buildDivider(),
                    _buildStat("${dashboard.totalMinutes}m", "Grounded", Icons.timer_rounded),
                  ],
                ),
                loading: () => const SizedBox(height: 28),
                error: (_, __) => const SizedBox.shrink(),
              ),
              AppSpacing.v24,
              Row(
                children: [
                  _buildCTA(context, "Start Grounding", Icons.play_arrow_rounded, '/grounding/sensory', AppColors.calmTeal),
                  AppSpacing.h12,
                  _buildCTA(context, "Panic Reset", Icons.emergency_rounded, '/grounding/panic', AppColors.novaPurple),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.calmTeal, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.headingM.copyWith(color: AppColors.textPrimary, fontSize: 20),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withAlpha(38),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildCTA(BuildContext context, String label, IconData icon, String route, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.lg,
            boxShadow: [BoxShadow(color: color.withAlpha(102), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
