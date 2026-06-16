import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/design/shadows/app_shadows.dart';
import '../../../../core/widgets/animations/mind_nova_animations.dart';

import 'nova_avatar_widget.dart';

/// A breathing thinking indicator that replaces the standard dots.
/// Uses the BreathingScale to create a calming, alive pulsation.
class NovaThinkingIndicator extends StatelessWidget {
  const NovaThinkingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const NovaAvatarWidget(size: 36, isActive: true),
          AppSpacing.h12,
          BreathingScale(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s24,
                vertical: AppSpacing.s16,
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.radiusMD),
                  topRight: const Radius.circular(AppRadius.radiusMD),
                  bottomLeft: const Radius.circular(AppRadius.radiusXS),
                  bottomRight: const Radius.circular(AppRadius.radiusMD),
                ),
                boxShadow: AppShadows.shadowSubtle,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < 2 ? AppSpacing.s8 : 0,
                    ),
                    child: _BreathingDot(delay: index * 200),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreathingDot extends StatefulWidget {
  final int delay;

  const _BreathingDot({required this.delay});

  @override
  State<_BreathingDot> createState() => _BreathingDotState();
}

class _BreathingDotState extends State<_BreathingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.novaPurpleLight,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
