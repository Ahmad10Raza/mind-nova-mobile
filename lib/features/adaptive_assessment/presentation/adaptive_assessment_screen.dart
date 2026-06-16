import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/adaptive_session_provider.dart';
import '../models/adaptive_node_model.dart';
import '../../assessment/models/assessment_model.dart';
import 'widgets/crisis_interruption_overlay.dart';
import '../../../core/network/api_client.dart';

class AdaptiveAssessmentScreen extends ConsumerStatefulWidget {
  final String treeId;

  const AdaptiveAssessmentScreen({super.key, required this.treeId});

  @override
  ConsumerState<AdaptiveAssessmentScreen> createState() => _AdaptiveAssessmentScreenState();
}

class _AdaptiveAssessmentScreenState extends ConsumerState<AdaptiveAssessmentScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adaptiveSessionProvider.notifier).startSession(widget.treeId));
  }

  void _handleOptionSelected(double score, String? textValue) async {
    await ref.read(adaptiveSessionProvider.notifier).submitAnswer(score, textValue: textValue);
    
    final state = ref.read(adaptiveSessionProvider);
    if (state.isCompleted && mounted) {
      try {
        final response = ref.read(adaptiveSessionProvider.notifier).lastResponseData;
        
        if (response != null && response['completed'] == true) {
          final scoreData = response['fullResult'];
          
          final result = AssessmentResult(
            id: scoreData['id'],
            createdAt: DateTime.parse(scoreData['calculatedAt']),
            totalScore: (scoreData['cmhi'] as num).toInt(),
            severityLevel: scoreData['riskCategory'],
            categoryScores: {
              'Emotional': (scoreData['emotional'] as num).toDouble(),
              'Cognitive': (scoreData['cognitive'] as num).toDouble(),
              'Behavioral': (scoreData['behavioral'] as num).toDouble(),
              'Physiological': (scoreData['physiological'] as num).toDouble(),
              'Temporal': (scoreData['temporal'] as num).toDouble(),
            },
            insight: response['summary'],
            anxietyRisk: (scoreData['anxietyRisk'] as num?)?.toDouble(),
            depressionRisk: (scoreData['depressionRisk'] as num?)?.toDouble(),
            burnoutRisk: (scoreData['burnoutRisk'] as num?)?.toDouble(),
            crisisRisk: (scoreData['crisisRisk'] as num?)?.toDouble(),
            topFactor: scoreData['explanation']?['topFactor'] ?? 'Overall',
          );
          
          context.push('/assessment-result', extra: result); 
        }
      } catch (e) {
        debugPrint('Finalization error: $e');
        // Fallback
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adaptiveSessionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text('Adaptive Discovery', style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: state.progress,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5E4B8B)),
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildBody(state),
          if (state.crisisModeTriggered)
            const CrisisInterruptionOverlay(),
        ],
      ),
    );
  }

  Widget _buildBody(AdaptiveSessionState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF5E4B8B)));
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(state.error!, style: const TextStyle(color: Colors.white70)),
            TextButton(
              onPressed: () => ref.read(adaptiveSessionProvider.notifier).startSession(widget.treeId),
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    final node = state.currentNode;
    if (node == null) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _QuestionCard(
        key: ValueKey(node.questionId),
        node: node,
        isSubmitting: state.isSubmitting,
        onOptionSelected: _handleOptionSelected,
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final AdaptiveNodeModel node;
  final bool isSubmitting;
  final Function(double, String?) onOptionSelected;

  const _QuestionCard({
    super.key,
    required this.node,
    required this.isSubmitting,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            node.text,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          if (node.category.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                node.category,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
              ),
            ),
          ],
          const SizedBox(height: 48),
          ...node.options.map((opt) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: InkWell(
                  onTap: isSubmitting
                      ? null
                      : () => onOptionSelected(opt['score']?.toDouble() ?? 0.0, null),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opt['text'] ?? '',
                            style: GoogleFonts.inter(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        if (isSubmitting)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5E4B8B)),
                          )
                        else
                          const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
