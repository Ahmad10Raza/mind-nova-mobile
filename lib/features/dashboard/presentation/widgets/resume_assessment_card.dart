import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../assessment/providers/assessment_session_provider.dart';

class ResumeAssessmentCard extends ConsumerWidget {
  const ResumeAssessmentCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(activeSessionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resume card for in-progress assessment
        sessionsAsync.when(
          data: (sessions) {
            if (sessions.isEmpty) return const SizedBox.shrink();
            final session = sessions.first;
            final progress = (session.currentIndex + 1) / session.shuffledQuestionIds.length;
            return _buildResumeCard(context, progress, session.assessmentId);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 16),

        // Assessment type carousel
        Text('Deep Dive Assessments', style: DashboardTheme.heading2),
        const SizedBox(height: 12),
        SizedBox(
          height: 68,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildAssessmentChip(
                context,
                label: 'Anxiety',
                icon: Icons.psychology_rounded,
                color: DashboardTheme.stressAmber,
                id: 'gad7',
                recommended: true,
              ),
              const SizedBox(width: 10),
              _buildAssessmentChip(
                context,
                label: 'Depression',
                icon: Icons.cloud_rounded,
                color: DashboardTheme.sleepBlue,
                id: 'phq9',
              ),
              const SizedBox(width: 10),
              _buildAssessmentChip(
                context,
                label: 'Stress',
                icon: Icons.whatshot_rounded,
                color: DashboardTheme.crisisRed,
                id: 'pss',
              ),
              const SizedBox(width: 10),
              _buildAssessmentChip(
                context,
                label: 'PTSD',
                icon: Icons.shield_rounded,
                color: DashboardTheme.recoveryTeal,
                id: 'pcl5',
              ),
              const SizedBox(width: 10),
              _buildAssessmentChip(
                context,
                label: 'Panic',
                icon: Icons.flash_on_rounded,
                color: DashboardTheme.anxietyPink,
                id: 'pdss',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResumeCard(BuildContext context, double progress, String assessmentId) {
    return GestureDetector(
      onTap: () => context.push('/assessment/$assessmentId/run'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
          border: Border.all(color: DashboardTheme.primaryPurple.withValues(alpha: 0.25)),
          boxShadow: DashboardTheme.softShadow(Colors.black),
        ),
        child: Row(
          children: [
            // Progress ring
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(DashboardTheme.accentViolet),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue Discovery',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Your assessment is in progress',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: DashboardTheme.accentViolet.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right_rounded, color: DashboardTheme.accentViolet, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentChip(BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required String id,
    bool recommended = false,
  }) {
    return GestureDetector(
      onTap: () => context.push('/assessment/$id'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(DashboardTheme.radiusM),
          border: Border.all(
            color: recommended 
                ? color.withValues(alpha: 0.5)
                : color.withValues(alpha: 0.12),
            width: recommended ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: DashboardTheme.textPrimary,
                  ),
                ),
              ],
            ),
            if (recommended) ...[
              const SizedBox(height: 4),
              Text(
                'Recommended',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
