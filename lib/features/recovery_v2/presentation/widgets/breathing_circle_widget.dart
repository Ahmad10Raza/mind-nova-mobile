import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';

import '../../data/recovery_modes.dart';

/// An immersive, full-screen breathing circle that visually and haptically
/// guides the user through inhale-hold-exhale cycles.
class BreathingCircleWidget extends StatefulWidget {
  final BreathingPattern pattern;

  const BreathingCircleWidget({super.key, required this.pattern});

  @override
  State<BreathingCircleWidget> createState() => _BreathingCircleWidgetState();
}

class _BreathingCircleWidgetState extends State<BreathingCircleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _currentPhase = 'Inhale';
  int _cycleCount = 0;

  @override
  void initState() {
    super.initState();
    final totalSeconds = widget.pattern.totalCycleSeconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalSeconds),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _cycleCount++;
        _controller.forward(from: 0.0);
      }
    });

    _controller.addListener(() {
      _updatePhase();
    });

    _controller.forward();
  }

  void _updatePhase() {
    final p = widget.pattern;
    final total = p.totalCycleSeconds.toDouble();
    final progress = _controller.value * total;

    String newPhase;
    if (progress < p.inhaleSeconds) {
      newPhase = 'Breathe in';
    } else if (progress < p.inhaleSeconds + p.holdSeconds) {
      newPhase = 'Hold';
    } else if (progress < p.inhaleSeconds + p.holdSeconds + p.exhaleSeconds) {
      newPhase = 'Breathe out';
    } else {
      newPhase = 'Hold';
    }

    if (newPhase != _currentPhase) {
      setState(() => _currentPhase = newPhase);
      // Gentle haptic on phase change
      HapticFeedback.selectionClick();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final p = widget.pattern;
        final total = p.totalCycleSeconds.toDouble();
        final progress = _controller.value * total;

        // Calculate circle scale based on phase
        double scale;
        if (progress < p.inhaleSeconds) {
          // Inhale — expand
          scale = 0.5 + 0.5 * (progress / p.inhaleSeconds);
        } else if (progress < p.inhaleSeconds + p.holdSeconds) {
          // Hold — stay expanded
          scale = 1.0;
        } else if (progress < p.inhaleSeconds + p.holdSeconds + p.exhaleSeconds) {
          // Exhale — contract
          final exhaleProgress =
              (progress - p.inhaleSeconds - p.holdSeconds) / p.exhaleSeconds;
          scale = 1.0 - 0.5 * exhaleProgress;
        } else {
          // Hold after exhale — stay contracted
          scale = 0.5;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Breathing circle
            Container(
              width: 220 * scale,
              height: 220 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.color.withOpacity(0.15),
                border: Border.all(
                  color: p.color.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: p.color.withOpacity(0.15 * scale),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 120 * scale,
                  height: 120 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.color.withOpacity(0.25),
                  ),
                ),
              ),
            ),
            AppSpacing.v32,

            // Phase label
            Text(
              _currentPhase,
              style: AppTypography.headingLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.v8,

            // Cycle counter
            Text(
              'Cycle ${_cycleCount + 1}',
              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
            ),
          ],
        );
      },
    );
  }
}
