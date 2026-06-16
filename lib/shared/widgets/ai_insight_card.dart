import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../features/ai_reports/providers/ai_insight_provider.dart';

class AiInsightCard extends ConsumerWidget {
  final String insightId;
  final Color themeColor;

  const AiInsightCard({
    Key? key,
    required this.insightId,
    required this.themeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(aiInsightProvider(insightId));

    return stateAsync.when(
      loading: () => _buildLoadingState(),
      error: (err, stack) => _buildErrorState(err.toString()),
      data: (insight) {
        final status = insight['status'];
        final riskLevel = insight['riskLevel'] ?? 'LOW';
        final headline = insight['headline'] ?? 'Analysis in Progress...';
        final summary = insight['summary'] ?? 'Generating deeper insights into your behavioral patterns.';
        final content = insight['content'] ?? {};
        final reasonCodes = List<String>.from(insight['reasonCodes'] ?? []);
        final confidence = insight['confidenceMatrix'] ?? {};

        return Column(
          children: [
            Card(
              elevation: 8,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surfaceWhite,
                      themeColor.withOpacity(0.02),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Risk Badge
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          _buildRiskBadge(riskLevel),
                          const Spacer(),
                          if (status == 'GENERATING' || status == 'PENDING')
                            const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        headline,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        summary,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Reason Code Chips
                    if (reasonCodes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: reasonCodes.map((code) => _buildReasonChip(code)).toList(),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Confidence Indicators (Improvement #2)
                    _buildConfidenceMatrix(confidence),

                    const Divider(height: 1),

                    // Actionable Suggestions
                    _buildActionSection(content['actions'] ?? {}),

                    // Action Buttons (Section 7)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildActionButton(
                            context,
                            label: 'Talk to Nova AI',
                            icon: Icons.chat_bubble_outline,
                            onPressed: () => context.go('/chat'),
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            context,
                            label: 'Share with Therapist',
                            icon: Icons.share_outlined,
                            outlined: true,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    
                    // Safety Disclaimer (Improvement #4 / Section 8)
                    _buildSafetyFooter(riskLevel),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRiskBadge(String level) {
    Color color;
    switch (level) {
      case 'LOW': color = Colors.green; break;
      case 'MED': color = Colors.amber; break;
      case 'HIGH': color = Colors.orange; break;
      case 'SEVERE':
      case 'EMERGENCY': color = Colors.red; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        level,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildReasonChip(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        code.replaceAll('_', ' '),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildConfidenceMatrix(Map confidence) {
    final ml = (confidence['mlScore'] as num? ?? 0.0).toDouble() * 100;
    final llm = (confidence['llmScore'] as num? ?? 0.0).toDouble() * 100;
    final data = (confidence['dataCompleteness'] as num? ?? 0.0).toDouble() * 100;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildConfItem('ML Model', ml),
          _buildConfItem('AI Confidence', llm),
          _buildConfItem('Data Context', data),
        ],
      ),
    );
  }

  Widget _buildConfItem(String label, double val) {
    return Column(
      children: [
        Text('${val.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildActionSection(Map actions) {
    final immediate = List<String>.from(actions['immediate'] ?? []);
    if (immediate.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recommended Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...immediate.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: themeColor, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(a, style: const TextStyle(fontSize: 14))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required String label, required IconData icon, bool outlined = false, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: outlined ? Colors.white : themeColor,
          foregroundColor: outlined ? themeColor : Colors.white,
          elevation: outlined ? 0 : 2,
          side: outlined ? BorderSide(color: themeColor) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSafetyFooter(String risk) {
    final isHigh = risk == 'HIGH' || risk == 'SEVERE' || risk == 'EMERGENCY';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHigh ? Colors.red.withOpacity(0.05) : AppColors.backgroundLight,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Text(
        'Nova AI provides guidance, not medical diagnosis. If you are in crisis, please seek immediate professional help.',
        style: TextStyle(fontSize: 11, color: isHigh ? Colors.red : AppColors.textSecondary, fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text('Deep AI Analysis...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Correlating mood trends with physiological data...', style: TextStyle(color: AppColors.textSecondary, fontSize: 13), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(child: Text('Failed to load insights: $error'));
  }
}
