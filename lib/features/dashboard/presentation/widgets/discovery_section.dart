import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/dashboard_theme.dart';
import 'resume_assessment_card.dart';
import 'mindful_moment_card.dart';
import '../../../scoring/providers/scoring_provider.dart';

class DiscoverySection extends ConsumerWidget {
  const DiscoverySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cmhiAsync = ref.watch(latestCMHIProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Discovery', style: DashboardTheme.heading2),
        ),
        const SizedBox(height: 16),
        // Item 1: Assessment (if needed) or Mindful Moment
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const ResumeAssessmentCard(), // Ideally only show if incomplete, but keeping for now
        ),
        const SizedBox(height: 16),
        // Item 2: Mindful Moment
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: cmhiAsync.when(
            data: (score) => MindfulMomentCard(riskLevel: score?.riskCategory),
            loading: () => const MindfulMomentCard(),
            error: (_, __) => const MindfulMomentCard(),
          ),
        ),
      ],
    );
  }
}
