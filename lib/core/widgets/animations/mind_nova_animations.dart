import 'package:flutter/material.dart';
import '../../design/motion/app_motion.dart';
import '../../design/shadows/app_shadows.dart';

class BreathingScale extends StatefulWidget {
  final Widget child;
  final bool active;

  const BreathingScale({Key? key, required this.child, this.active = true}) : super(key: key);

  @override
  State<BreathingScale> createState() => _BreathingScaleState();
}

class _BreathingScaleState extends State<BreathingScale> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.breathing,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.calmEase),
    );

    if (widget.active) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant BreathingScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && oldWidget.active) {
      _controller.stop();
      _controller.animateTo(0.0, duration: AppMotion.slow, curve: AppMotion.calmEase);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

class EmotionalGlow extends StatelessWidget {
  final Widget child;
  final bool isGlowActive;
  final List<BoxShadow> activeGlow;

  const EmotionalGlow({
    Key? key,
    required this.child,
    required this.isGlowActive,
    required this.activeGlow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.slow,
      curve: AppMotion.calmEase,
      decoration: BoxDecoration(
        boxShadow: isGlowActive ? activeGlow : [],
      ),
      child: child,
    );
  }
}

class SoftPressAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const SoftPressAnimation({Key? key, required this.child, required this.onTap}) : super(key: key);

  @override
  State<SoftPressAnimation> createState() => _SoftPressAnimationState();
}

class _SoftPressAnimationState extends State<SoftPressAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.microFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.calmEase),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
