import 'package:flutter/material.dart';
import '../../design/colors/app_colors.dart';
import '../../design/radius/app_radius.dart';
import '../../design/shadows/app_shadows.dart';
import '../../design/spacing/app_spacing.dart';
import '../../design/typography/app_typography.dart';
import '../../design/surfaces/app_surfaces.dart';
import '../surfaces/mind_nova_surfaces.dart';

// ==========================================
// BASE CARD CONFIGURATION
// ==========================================
class MindNovaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;

  const MindNovaCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.s20),
    this.onTap,
    this.backgroundColor,
    this.boxShadow,
    this.borderRadius,
    this.borderSide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppSurfaces.secondary,
        borderRadius: borderRadius ?? AppRadius.md,
        boxShadow: boxShadow ?? AppShadows.shadowSoft,
        border: borderSide != null ? Border.fromBorderSide(borderSide!) : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}

// ==========================================
// HERO CARD (Top Emphasis)
// ==========================================
class MindNovaHeroCard extends StatelessWidget {
  final Widget child;
  
  const MindNovaHeroCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MindNovaCard(
      backgroundColor: AppSurfaces.accent,
      borderRadius: AppRadius.xl,
      boxShadow: AppShadows.glowPurple,
      padding: const EdgeInsets.all(AppSpacing.s32),
      child: child,
    );
  }
}

// ==========================================
// FEATURE CARD (Interactive Tools)
// ==========================================
class MindNovaFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconBackgroundColor;

  const MindNovaFeatureCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.iconBackgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MindNovaCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? AppColors.novaPurple.withOpacity(0.15),
              borderRadius: AppRadius.sm,
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 24),
          ),
          AppSpacing.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headingMedium),
                AppSpacing.v4,
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

// ==========================================
// INSIGHT CARD (Nova AI)
// ==========================================
class MindNovaInsightCard extends StatelessWidget {
  final String insight;

  const MindNovaInsightCard({Key? key, required this.insight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MindNovaCard(
      backgroundColor: AppSurfaces.elevated,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.calmTeal),
          AppSpacing.h12,
          Expanded(
            child: Text(
              insight,
              style: AppTypography.body.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// RECOVERY CARD (Emergency/Breathing)
// ==========================================
class MindNovaRecoveryCard extends StatelessWidget {
  final VoidCallback onTap;

  const MindNovaRecoveryCard({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MindNovaCard(
      onTap: onTap,
      backgroundColor: AppColors.recoveryBlue.withOpacity(0.1),
      borderSide: BorderSide(color: AppColors.recoveryBlue.withOpacity(0.3)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.recoveryBlue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.air_rounded, color: AppColors.recoveryBlue),
          ),
          AppSpacing.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Need a moment?', style: AppTypography.headingMedium.copyWith(color: AppColors.recoveryBlue)),
                Text('Start a guided breathing session', style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// GLASS CARD (Overlays)
// ==========================================
class MindNovaGlassCard extends StatelessWidget {
  final Widget child;

  const MindNovaGlassCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MindNovaGlassSurface(
      padding: const EdgeInsets.all(AppSpacing.s20),
      borderRadius: AppRadius.md,
      child: child,
    );
  }
}

// ==========================================
// COMPACT CARD (Dense Lists)
// ==========================================
class MindNovaCompactCard extends StatelessWidget {
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  const MindNovaCompactCard({
    Key? key,
    required this.title,
    required this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MindNovaCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.body),
          trailing,
        ],
      ),
    );
  }
}
