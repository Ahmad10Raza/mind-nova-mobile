import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/assessment_model.dart';
import '../providers/assessment_session_provider.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  final String assessmentId;
  final String depth;
  const AssessmentScreen({super.key, required this.assessmentId, this.depth = 'standard'});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Future.microtask(() => ref.read(assessmentSessionProvider.notifier).initializeAssessment(widget.assessmentId, depth: widget.depth));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onOptionSelected(String questionId, int score) {
    final notifier = ref.read(assessmentSessionProvider.notifier);
    notifier.selectOption(questionId, score);
    
    final state = ref.read(assessmentSessionProvider);
    if (_pageController.hasClients && state.activeSession != null) {
      if (state.currentIndex < state.activeSession!.shuffledQuestionIds.length) {
        _pageController.animateToPage(
          state.currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _showSaveAndExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Save and Exit?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your progress is automatically saved. You can resume this discovery anytime from your dashboard.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.go('/'); // Go home
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5E4B8B)),
            child: const Text('Exit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assessmentSessionProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF5E4B8B)),
              SizedBox(height: 24),
              Text('Aligning clinical parameters...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    if (state.status == AssessmentSessionStatus.error) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
                const SizedBox(height: 24),
                Text(
                  state.error ?? 'Connection interrupted',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => ref.read(assessmentSessionProvider.notifier).initializeAssessment(widget.assessmentId, depth: widget.depth),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E4B8B),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final session = state.activeSession;
    if (session == null || state.questionnaire == null) return const Scaffold();

    final questions = state.questionnaire!.questions;
    final shuffledIds = session.shuffledQuestionIds;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(state.questionnaire?.title ?? 'Discovery', style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: _showSaveAndExitDialog,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded, color: Colors.white70),
            onPressed: () => context.go('/'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(state.progress * 100).toInt()}% complete',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    Text(
                      'Question ${state.currentIndex + 1}/${shuffledIds.length}',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: state.progress,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5E4B8B)),
                minHeight: 4,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shuffledIds.length,
                itemBuilder: (context, index) {
                  final qId = shuffledIds[index];
                  final question = questions.firstWhere((q) => q.id == qId);
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          question.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 48),
                        ...question.options.map((opt) => _buildOptionTile(context, question.id, opt)),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Footer Action
            if (state.currentIndex == shuffledIds.length - 1 && state.answers.containsKey(shuffledIds.last))
              Container(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state.isSubmitting ? null : () async {
                      final result = await ref.read(assessmentSessionProvider.notifier).submit();
                      if (result != null && context.mounted) {
                        context.push('/assessment-result', extra: result);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E4B8B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: state.isSubmitting 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Complete Discovery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, String questionId, Option option) {
    final state = ref.watch(assessmentSessionProvider);
    final isSelected = state.answers[questionId] == option.score;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => _onOptionSelected(questionId, option.score),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5E4B8B).withOpacity(0.2) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF5E4B8B) : Colors.white12,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option.text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
              ),
              if (isSelected) 
                const Icon(Icons.check_circle, color: Color(0xFF5E4B8B), size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
