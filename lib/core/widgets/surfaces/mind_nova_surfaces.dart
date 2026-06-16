import 'package:flutter/material.dart';
import 'dart:ui';
import '../../design/colors/app_colors.dart';
import '../../design/radius/app_radius.dart';
import '../../design/surfaces/app_surfaces.dart';
import '../../design/shadows/app_shadows.dart';

class MindNovaSurface extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const MindNovaSurface({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.boxShadow,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppSurfaces.secondary,
        borderRadius: borderRadius ?? AppRadius.md,
        boxShadow: boxShadow,
        border: border,
      ),
      child: child,
    );
  }
}

class MindNovaGlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const MindNovaGlassSurface({
    Key? key,
    required this.child,
    this.borderRadius,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.md;
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppSurfaces.glassSoft,
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
