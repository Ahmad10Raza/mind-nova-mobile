import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

class GroundingModeData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String route;

  const GroundingModeData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.route,
  });
}

const _modes = [
  GroundingModeData(
    title: '5-4-3-2-1',
    subtitle: 'Sensory anchoring',
    icon: Icons.remove_red_eye_rounded,
    gradient: [Color(0xFF0D6B6B), Color(0xFF059669)],
    route: '/grounding/sensory',
  ),
  GroundingModeData(
    title: 'Panic Reset',
    subtitle: 'Immediate relief',
    icon: Icons.emergency_rounded,
    gradient: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
    route: '/grounding/panic',
  ),
  GroundingModeData(
    title: 'Touch & Hold',
    subtitle: 'Feel the present',
    icon: Icons.touch_app_rounded,
    gradient: [Color(0xFF0F4C75), Color(0xFF1B6CA8)],
    route: '/grounding/touch-hold',
  ),
  GroundingModeData(
    title: 'Safe Place',
    subtitle: 'Visualize calm',
    icon: Icons.landscape_rounded,
    gradient: [Color(0xFF065F46), Color(0xFF047857)],
    route: '/grounding/safe-place',
  ),
  GroundingModeData(
    title: 'Body Scan',
    subtitle: 'Release tension',
    icon: Icons.accessibility_new_rounded,
    gradient: [Color(0xFF92400E), Color(0xFFB45309)],
    route: '/grounding/body-scan',
  ),
  GroundingModeData(
    title: 'Color Breathing',
    subtitle: 'Breathe with color',
    icon: Icons.blur_circular_rounded,
    gradient: [Color(0xFF1E3A5F), Color(0xFF0D6B9A)],
    route: '/grounding/color-breathing',
  ),
];

class GroundingModeGrid extends StatelessWidget {
  const GroundingModeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: Text(
            "Grounding Exercises",
            style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
          ),
        ),
        AppSpacing.v16,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: _modes.length,
            itemBuilder: (context, index) => _GroundingModeCard(mode: _modes[index]),
          ),
        ),
      ],
    );
  }
}

class _GroundingModeCard extends StatefulWidget {
  final GroundingModeData mode;
  const _GroundingModeCard({required this.mode});

  @override
  State<_GroundingModeCard> createState() => _GroundingModeCardState();
}

class _GroundingModeCardState extends State<_GroundingModeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        context.push(widget.mode.route);
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.mode.gradient,
            ),
            borderRadius: AppRadius.lg,
            border: Border.all(color: Colors.white.withAlpha(13)),
            boxShadow: [
              BoxShadow(
                color: widget.mode.gradient.last.withAlpha(89),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: AppRadius.sm,
                ),
                child: Icon(widget.mode.icon, color: Colors.white, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.mode.title,
                    style: AppTypography.headingSmall.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.mode.subtitle,
                    style: AppTypography.caption.copyWith(color: Colors.white60),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
