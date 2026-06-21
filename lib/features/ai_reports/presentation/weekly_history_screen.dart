import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/design/colors/app_colors.dart';
import '../../../core/design/surfaces/app_surfaces.dart';
import '../../../core/design/typography/app_typography.dart';
import '../models/weekly_report_model.dart';
import '../providers/weekly_report_provider.dart';
import '../../mood/providers/mood_log_provider.dart';

class WeeklyReportHistoryScreen extends ConsumerWidget {
  const WeeklyReportHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(weeklyReportHistoryProvider);

    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Weekly History',
          style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppColors.novaPurpleLight),
            tooltip: 'Generate Latest',
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                        const SizedBox(height: 16),
                        Text(
                          'MindNova AI is analyzing your week...',
                          style: AppTypography.headingMedium.copyWith(fontSize: 14, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              try {
                await ref.read(triggerWeeklyReportProvider(null).future);
                ref.invalidate(weeklyReportHistoryProvider);
                ref.invalidate(weeklyReportProvider);
                
                // Close dialog
                if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Text('Weekly insights successfully generated!', style: AppTypography.body.copyWith(color: Colors.white)),
                        ],
                      ),
                      backgroundColor: const Color(0xFF7C4DFF),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              } catch (e) {
                // Close dialog
                if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: const Color(0xFFFF5252),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error loading history: $e')),
        data: (reports) {
          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: AppColors.textDisabled),
                  const SizedBox(height: 16),
                  Text(
                    'No reports found yet.',
                    style: AppTypography.body.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildReportTile(context, report);
            },
          );
        },
      ),
    );
  }

  Widget _buildReportTile(BuildContext context, WeeklyReport report) {
    final dateStr = DateFormat('MMM d').format(report.weekStartDate);
    final endDateStr = DateFormat('MMM d, yyyy').format(report.weekEndDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF171B28).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        onTap: () => context.push('/weekly-insight', extra: report),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.novaPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.novaPurple.withOpacity(0.3)),
                ),
                child: const Icon(Icons.insights_rounded, color: AppColors.novaPurpleLight, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week of $dateStr - $endDateStr',
                      style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.aiTitle ?? 'Summary of your progress',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
