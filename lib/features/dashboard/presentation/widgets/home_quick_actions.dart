import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _QuickAction(
          icon: Icons.mood_rounded,
          label: 'Mood',
          color: AppColors.warmSupport,
          onTap: () => context.push('/mood-checkin'),
        ),
        _QuickAction(
          icon: Icons.air_rounded,
          label: 'Breathe',
          color: AppColors.recoveryBlue,
          onTap: () => context.push('/breathing'),
        ),
        _QuickAction(
          icon: Icons.auto_awesome_rounded,
          label: 'Nova',
          color: AppColors.novaPurple,
          onTap: () => context.push('/nova-chat'),
        ),
        _QuickAction(
          icon: Icons.edit_note_rounded,
          label: 'Journal',
          color: AppColors.calmTeal,
          onTap: () => context.push('/journal'),
        ),
        _QuickAction(
          icon: Icons.health_and_safety_rounded,
          label: 'SOS',
          color: AppColors.emotionalDangerMuted,
          onTap: () => context.push('/crisis-support'),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          AppSpacing.v8,
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
