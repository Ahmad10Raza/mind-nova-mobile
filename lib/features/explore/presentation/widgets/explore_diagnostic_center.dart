import 'package:flutter/material.dart';
import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../assessment/providers/assessment_session_provider.dart';
import '../../../assessment/providers/assessment_history_provider.dart';

class ExploreDiagnosticCenter extends ConsumerWidget {
  const ExploreDiagnosticCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessionsAsync = ref.watch(activeSessionsProvider);
    final historyAsync = ref.watch(assessmentHistoryProvider);

    final sessions = activeSessionsAsync.value ?? [];
    final history = historyAsync.value ?? [];

    Map<String, dynamic> _getAssessmentState(String slugPrefix) {
      final activeSession = sessions.where((s) => s.slug.startsWith(slugPrefix)).firstOrNull;
      if (activeSession != null) {
        final total = activeSession.shuffledQuestionIds.isNotEmpty ? activeSession.shuffledQuestionIds.length : 1;
        final progress = activeSession.currentIndex / total;
        return {
          'status': '${(progress * 100).toInt()}%',
          'progress': progress,
          'buttonText': 'Resume Assessment',
          'isCompleted': false,
        };
      }

      final hasHistory = history.where((h) => 
        (h.assessmentTitle?.toLowerCase().contains(slugPrefix) ?? false) || 
        (h.assessmentSlug?.toLowerCase().contains(slugPrefix) ?? false) ||
        h.id.toLowerCase().contains(slugPrefix)
      ).isNotEmpty;
      
      return {
        'status': hasHistory ? 'Retake Available' : (slugPrefix == 'ptsd' ? 'New' : 'Not Started'),
        'progress': 0.0,
        'buttonText': hasHistory ? 'Retake Assessment' : (slugPrefix == 'ptsd' ? 'Begin Screen' : 'Start Assessment'),
        'isCompleted': false,
      };
    }

    VoidCallback _getOnTap(Map<String, dynamic> state, String routeName) {
      return () => context.push('/assessment/$routeName');
    }

    final depression = _getAssessmentState('phq');
    final anxiety = _getAssessmentState('gad');
    final stress = _getAssessmentState('pss');
    final ptsd = _getAssessmentState('ptsd');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: Text(
            'Clinical Assessment Center',
            style: AppTypography.headingLarge,
          ),
        ),
        AppSpacing.v16,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.s12,
            crossAxisSpacing: AppSpacing.s12,
            childAspectRatio: 1.1,
            children: [
              _buildAssessmentCard(
                title: 'Depression (PHQ-9)',
                status: depression['status'],
                progress: depression['progress'],
                buttonText: depression['buttonText'],
                color: AppColors.secondary,
                buttonColor: depression['isCompleted'] ? AppColors.textMuted : null,
                onTap: _getOnTap(depression, 'depression'),
              ),
              _buildAssessmentCard(
                title: 'Anxiety (GAD-7)',
                status: anxiety['status'],
                progress: anxiety['progress'],
                buttonText: anxiety['buttonText'],
                color: AppColors.primary,
                buttonColor: anxiety['isCompleted'] ? AppColors.textMuted : null,
                onTap: _getOnTap(anxiety, 'anxiety'),
              ),
              Opacity(
                opacity: stress['isCompleted'] ? 0.6 : 1.0,
                child: _buildAssessmentCard(
                  title: 'Stress Level (PSS)',
                  status: stress['status'],
                  progress: stress['progress'],
                  buttonText: stress['buttonText'],
                  color: AppColors.tertiary,
                  buttonColor: stress['isCompleted'] ? AppColors.textMuted : null,
                  onTap: _getOnTap(stress, 'stress'),
                ),
              ),
              _buildAssessmentCard(
                title: 'PTSD Screening',
                status: ptsd['status'],
                progress: ptsd['progress'],
                buttonText: ptsd['buttonText'],
                color: AppColors.primary,
                buttonColor: ptsd['isCompleted'] ? AppColors.textMuted : null,
                onTap: _getOnTap(ptsd, 'ptsd'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssessmentCard({
    required String title,
    required String status,
    required double progress,
    required String buttonText,
    required Color color,
    Color? buttonColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary.withOpacity(0.5),
          borderRadius: AppRadius.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(title, style: AppTypography.labelLarge)),
                AppSpacing.h8,
                Text(status, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
              ],
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: AppRadius.full,
              child: LinearProgressIndicator(
                value: progress > 0 ? progress : 0,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
            AppSpacing.v12,
            Text(
              buttonText,
              style: AppTypography.labelMedium.copyWith(color: buttonColor ?? AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
