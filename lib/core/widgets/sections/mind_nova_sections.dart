import 'package:flutter/material.dart';
import '../../design/spacing/app_spacing.dart';

class MindNovaSection extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  const MindNovaSection({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.s24,
      vertical: AppSpacing.s32,
    ),
    this.maxWidth = 600.0, // Tablet safe default
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

class MindNovaHeroSection extends StatelessWidget {
  final Widget child;

  const MindNovaHeroSection({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: MindNovaSection(
        padding: const EdgeInsets.only(
          left: AppSpacing.s24,
          right: AppSpacing.s24,
          top: AppSpacing.s16,
          bottom: AppSpacing.s32,
        ),
        child: child,
      ),
    );
  }
}
