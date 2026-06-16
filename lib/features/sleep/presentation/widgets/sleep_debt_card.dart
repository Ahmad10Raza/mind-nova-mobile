import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/sleep_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/sleep_colors.dart';
import '../../providers/sleep_log_provider.dart';

/// Visual sleep debt indicator with color severity coding.
class SleepDebtCard extends ConsumerWidget {
  final double targetHours;

  const SleepDebtCard({
    super.key,
    this.targetHours = 8.0,
  });

  Color _severityColor(double debtHours) {
    if (debtHours <= 2) return SleepColors.successGreen;
    if (debtHours <= 5) return SleepColors.moonGold;
    if (debtHours <= 8) return Colors.orange;
    return SleepColors.emergencyRed;
  }

  String _severityLabel(double debtHours) {
    if (debtHours <= 2) return 'Well Rested';
    if (debtHours <= 5) return 'Mild Debt';
    if (debtHours <= 8) return 'Needs Recovery';
    return 'Critical Debt';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(sleepLogProvider);
    
    return logsAsync.when(
      loading: () => const SizedBox(height: 100),
      error: (_, __) => const SizedBox.shrink(),
      data: (logs) {
        double debtHours = 0.0;
        
        // Calculate sum of debt for available logs (days where hours < target)
        for (var log in logs) {
            if (log.durationHours < targetHours) {
                debtHours += (targetHours - log.durationHours);
            }
        }

        final debtRatio = (debtHours / 14.0).clamp(0.0, 1.0); // Max 14h debt
        final severityColor = _severityColor(debtHours);
        final severityLabel = _severityLabel(debtHours);

        return _buildDebtCard(context, debtHours, debtRatio, severityColor, severityLabel);
      },
    );
  }

  Widget _buildDebtCard(BuildContext context, double debtHours, double debtRatio, Color severityColor, String severityLabel) {

    return ClipRRect(
      borderRadius: BorderRadius.circular(SleepColors.cardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: SleepColors.glassBlurSigma,
          sigmaY: SleepColors.glassBlurSigma,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: SleepColors.glassCardWithGlow(severityColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.timelapse_rounded, color: severityColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Sleep Debt',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: SleepColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      severityLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: severityColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── Debt Bar ─────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: debtRatio,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(severityColor),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${debtHours.toStringAsFixed(1)}h behind',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: severityColor,
                    ),
                  ),
                  Text(
                    'Target: ${targetHours.toStringAsFixed(0)}h/night',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: SleepColors.textSecondary,
                    ),
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
