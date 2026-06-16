import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/gradients/app_gradients.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/design/motion/app_motion.dart';
import '../../../../core/widgets/avatars/mind_nova_avatars.dart';

import '../../../scoring/models/scoring_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../notifications/providers/notification_provider.dart';
import '../../../../core/network/network_constants.dart';

class HomeHeroSection extends ConsumerWidget {
  final String userName;
  final RiskCategory? riskLevel;
  final int streakDays;

  const HomeHeroSection({
    super.key,
    required this.userName,
    this.riskLevel,
    this.streakDays = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hour = DateTime.now().hour;
    final greeting = _getGreeting(hour);
    final emotionalLine = _getEmotionalLine(riskLevel, streakDays);
    final authState = ref.watch(authProvider);
    final avatarUrl = authState.avatarUrl;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppGradients.sleep,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.radiusXL),
          bottomRight: Radius.circular(AppRadius.radiusXL),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s24, AppSpacing.s16, AppSpacing.s24, AppSpacing.s32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar: Menu + Notification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: _buildIconContainer(Icons.menu_rounded),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/notifications'),
                    child: _buildNotificationBell(ref),
                  ),
                ],
              ),
              AppSpacing.v24,

              // Main greeting row: Avatar + Text
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User avatar / Nova companion
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.novaPurpleLight.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: avatarUrl != null && avatarUrl.isNotEmpty && !avatarUrl.startsWith('file://')
                            ? Image.network(
                                avatarUrl.startsWith('http')
                                    ? avatarUrl
                                    : '${NetworkConstants.baseUrl}${avatarUrl.startsWith('/') ? '' : '/'}$avatarUrl',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildFallbackAvatar(userName),
                              )
                            : _buildFallbackAvatar(userName),
                      ),
                    ),
                  ),
                  AppSpacing.h16,

                  // Greeting text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                        ),
                        AppSpacing.v4,
                        Text(
                          userName,
                          style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.v20,

              // Emotional insight line
              Text(
                emotionalLine,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              // Streak badge (conditional)
              if (streakDays > 0) ...[
                AppSpacing.v16,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.novaPurple.withOpacity(0.1),
                    borderRadius: AppRadius.full,
                    border: Border.all(
                      color: AppColors.novaPurple.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 14)),
                      AppSpacing.h8,
                      Text(
                        '$streakDays day streak',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.novaPurpleLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: AppRadius.sm,
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 22),
    );
  }

  Widget _buildNotificationBell(WidgetRef ref) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: AppRadius.sm,
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary, size: 22),
          ),
          ref.watch(unreadCountProvider).when(
            data: (count) => count > 0
                ? Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.emotionalDangerMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      color: AppColors.novaPurple.withOpacity(0.2),
      child: Center(
        child: Text(
          initial,
          style: AppTypography.headingLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 20) return 'Good Evening';
    return 'Good Night';
  }

  String _getEmotionalLine(RiskCategory? risk, int streakDays) {
    if (risk == null) return 'Take a moment to check in with yourself today.';

    if (risk == RiskCategory.high || risk == RiskCategory.severe || risk == RiskCategory.emergency) {
      return "You've been carrying a lot lately. Let's slow things down today.";
    }
    if (streakDays >= 3 && (risk == RiskCategory.minimal || risk == RiskCategory.mild)) {
      return "You handled this week well. Keep showing up for yourself.";
    }
    if (streakDays > 0 && risk == RiskCategory.moderate) {
      return "Things have been tough, but you're still here. That takes strength.";
    }
    return "Let's take today one step at a time.";
  }
}
