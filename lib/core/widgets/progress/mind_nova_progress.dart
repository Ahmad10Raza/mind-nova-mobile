import 'package:flutter/material.dart';
import '../../design/colors/app_colors.dart';
import '../../design/typography/app_typography.dart';
import '../../design/spacing/app_spacing.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final Color? color;
  final Widget? centerChild;

  const ProgressRing({
    Key? key,
    required this.progress,
    this.size = 120.0,
    this.color,
    this.centerChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.backgroundTertiary),
          ),
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.calmTeal),
            strokeCap: StrokeCap.round,
          ),
          if (centerChild != null) centerChild!,
        ],
      ),
    );
  }
}

class RecoveryMeter extends StatelessWidget {
  final double recoveryLevel; // 0.0 to 1.0
  final String label;

  const RecoveryMeter({
    Key? key,
    required this.recoveryLevel,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodySmall),
            Text('${(recoveryLevel * 100).toInt()}%', style: AppTypography.bodySmall.copyWith(color: AppColors.calmTeal)),
          ],
        ),
        AppSpacing.v8,
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: recoveryLevel,
            minHeight: 8,
            backgroundColor: AppColors.backgroundTertiary,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.calmTeal),
          ),
        ),
      ],
    );
  }
}
