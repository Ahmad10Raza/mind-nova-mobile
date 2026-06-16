import 'package:flutter/material.dart';
import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class ExploreSleepSosSection extends StatelessWidget {
  const ExploreSleepSosSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sleep & Recovery
          GestureDetector(
            onTap: () => context.push('/recovery-engine'),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s24),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary.withOpacity(0.5),
                borderRadius: AppRadius.xl,
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bedtime, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'RECOVERY ENGINE',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                AppSpacing.v24,
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(150, 150),
                        painter: _CircularProgressPainter(
                          progress: 0.75,
                          gradient: LinearGradient(
                            colors: [AppColors.secondary, AppColors.primary],
                          ),
                          backgroundColor: AppColors.secondary.withOpacity(0.1),
                          strokeWidth: 12,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('75%', style: AppTypography.displayMedium),
                          Text('READINESS', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted, letterSpacing: 1.5)),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.v24,
                Text('7h 24m Sleep Duration', style: AppTypography.headingLarge),
                AppSpacing.v8,
                Text(
                  'Your deep sleep was 12% higher than your baseline. Physical restoration is near peak capacity.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.v24,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSleepStat('REM', '1h 45m'),
                    AppSpacing.h16,
                    _buildSleepStat('Deep', '2h 10m'),
                  ],
                ),
              ],
            ),
          ),
          ),
          AppSpacing.v16,
          // SOS Crisis Care
          GestureDetector(
            onTap: () => context.push('/crisis'),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s24),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: AppRadius.xl,
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emergency, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'PRIORITY ACCESS',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.error,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                AppSpacing.v16,
                Text('SOS Crisis Protocol', style: AppTypography.headingLarge.copyWith(color: Colors.white)),
                AppSpacing.v8,
                Text(
                  'Immediate human support and de-escalation tools for when things feel overwhelming.',
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white.withOpacity(0.8)),
                ),
                AppSpacing.v24,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/crisis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error.withOpacity(0.2),
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.lg,
                        side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'ACTIVATE SUPPORT',
                      style: AppTypography.labelMedium.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withOpacity(0.5),
        borderRadius: AppRadius.lg,
      ),
      child: Column(
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
          AppSpacing.v4,
          Text(value, style: AppTypography.labelLarge),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Gradient gradient;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.gradient,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
