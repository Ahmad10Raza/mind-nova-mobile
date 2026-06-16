import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../mood/providers/mood_flow_provider.dart';
import '../../mood/providers/mood_log_provider.dart';
import '../../mood/providers/analytics_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../mood/data/mood_theme_mapper.dart';
import '../../../core/widgets/cards/mind_nova_cards.dart';
import '../../../core/design/typography/app_typography.dart';
import '../../../core/design/colors/app_colors.dart';

class AISuggestionsScreen extends ConsumerStatefulWidget {
  final String mood;
  const AISuggestionsScreen({super.key, required this.mood});

  @override
  ConsumerState<AISuggestionsScreen> createState() => _AISuggestionsScreenState();
}

class _AISuggestionsScreenState extends ConsumerState<AISuggestionsScreen> {
  String? _aiComfortMessage;
  bool _isLoadingAi = true;
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasFetched) {
        _hasFetched = true;
        _fetchAiComfortMessage();
        // Invalidate all analytics providers so every screen reflects the new log
        _invalidateAnalytics();
      }
    });
  }

  void _invalidateAnalytics() {
    ref.invalidate(moodHomeWidgetProvider);
    ref.invalidate(moodTrendsProvider);
    ref.invalidate(analyticsProvider);
    ref.invalidate(moodHistoryProvider);
    ref.invalidate(weeklyInsightsProvider);
    ref.invalidate(recoveryEffectivenessProvider(30));
    ref.invalidate(moodStreakProvider);
    // Invalidate distribution and summary for all common day ranges
    ref.invalidate(moodAnalyticsSummaryProvider(7));
    ref.invalidate(moodAnalyticsSummaryProvider(30));
    ref.invalidate(moodDistributionProvider(30));
    ref.invalidate(triggerAnalysisProvider(30));
  }

  Future<void> _fetchAiComfortMessage() async {
    final flowData = ref.read(moodFlowProvider);
    final mood = flowData.selectedMood ?? widget.mood;
    final intensity = flowData.intensity ?? 'moderate';
    final tags = flowData.tags;
    final answers = flowData.answers;

    // Build a therapeutic prompt from all context
    final prompt = _buildTherapeuticPrompt(mood, intensity, tags, answers);

    try {
      final service = ref.read(moodServiceProvider);
      final response = await service.getAiComfortMessage(prompt);
      if (mounted) {
        setState(() {
          _aiComfortMessage = response;
          _isLoadingAi = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiComfortMessage = null;
          _isLoadingAi = false;
        });
      }
    }
  }

  String _buildTherapeuticPrompt(String mood, String intensity, List<String> tags, List<Map<String, String>> answers) {
    final tagStr = tags.isNotEmpty ? tags.join(', ') : 'general life';
    final answerStr = answers.map((a) => a['answer'] ?? '').where((a) => a.isNotEmpty).join('. ');

    return '''You are a warm, empathetic mental health support companion named Nova. 
The user just completed a mood check-in. Their mood is "$mood" with "$intensity" intensity.
Contributing factors: $tagStr.
${answerStr.isNotEmpty ? 'Their reflections: "$answerStr"' : ''}

Write a short, personal, warm comfort message (2-3 sentences max). 
Be specific to their mood and context. Do NOT be generic.
Do NOT use bullet points. Speak directly to them like a caring friend.
Never diagnose. Never preach. Just be present and supportive.''';
  }

  // Cache flow data at first build to avoid scroll-resetting rebuilds
  MoodFlowData? _cachedFlowData;
  MoodTheme? _cachedTheme;

  @override
  Widget build(BuildContext context) {
    // Read once, don't watch — prevents rebuilds that reset scroll position
    _cachedFlowData ??= ref.read(moodFlowProvider);
    final flowData = _cachedFlowData!;
    _cachedTheme ??= MoodThemeMapper.getTheme(flowData.selectedMood ?? widget.mood);
    final theme = _cachedTheme!;
    final primaryColor = theme.gradient.last;
    final result = flowData.resultData ?? {};

    final status = result['status'] as String? ?? 'SUCCESS';
    final suggestions = (result['suggestions'] as List<dynamic>?) ?? [];
    final quickTools = (result['quickTools'] as List<dynamic>?) ?? [];
    final config = result['configuration'] as Map<String, dynamic>?;
    final subtitle = config?['subtitle'] as String? ?? theme.subtitle;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      resizeToAvoidBottomInset: false, // Prevents layout jumping if keyboard was open
      body: Stack(
        children: [
          // Fixed Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withValues(alpha: 0.18),
                    const Color(0xFF0A0A0F),
                    const Color(0xFF0A0A0F),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          // Scrollable Content
          SafeArea(
            child: status == 'CRITICAL_INTERVENTION'
                ? _buildCrisisLayout(context, ref, flowData, result, theme, primaryColor)
                : _buildNormalLayout(context, ref, flowData, theme, primaryColor, subtitle, suggestions, quickTools),
          ),
        ],
      ),
    );
  }

  // ─── CRISIS LAYOUT ─────────────────────────────────────────

  Widget _buildCrisisLayout(
    BuildContext context, WidgetRef ref,
    MoodFlowData data, Map<String, dynamic> result,
    MoodTheme theme, Color primaryColor,
  ) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        CrisisSupportCard(
          hotlineName: 'Crisis Hotline',
          hotlineNumber: '102',
          onCall: () {
            // In production: launch tel:102
          },
          onBreathe: () => context.push('/breathing'),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              Icon(Icons.spa, color: primaryColor, size: 32),
              const SizedBox(height: 12),
              Text(
                '5-4-3-2-1 Grounding',
                style: GoogleFonts.inter(
                  fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, and 1 you can taste.',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white54, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.push('/mood-analytics'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.analytics_outlined, size: 18),
                const SizedBox(width: 10),
                Text('View My Journey', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              ref.read(moodFlowProvider.notifier).reset();
              context.go('/');
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Return Home', style: GoogleFonts.inter(color: Colors.white70)),
          ),
        ),
      ],
    );
  }

  // ─── NORMAL / POSITIVE LAYOUT ──────────────────────────────

  Widget _buildNormalLayout(
    BuildContext context, WidgetRef ref,
    MoodFlowData data, MoodTheme theme, Color primaryColor,
    String subtitle, List<dynamic> suggestions, List<dynamic> quickTools,
  ) {
    final isPositive = theme.category == 'positive';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // ─── Back Button ──────────────────
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white54),
            onPressed: () => context.go('/'),
          ),
        ),

        // ─── Hero Section ──────────────────
        const SizedBox(height: 8),
        Center(
          child: Text(theme.emoji, style: const TextStyle(fontSize: 72)),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            data.selectedMood ?? widget.mood,
            style: GoogleFonts.inter(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data.intensity?.toUpperCase() ?? 'MODERATE',
              style: GoogleFonts.outfit(
                fontSize: 12, letterSpacing: 1.5,
                color: primaryColor, fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 15, color: Colors.white54, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ),

        // ─── AI Comfort Message ──────────────────
        const SizedBox(height: 24),
        _buildAiComfortSection(primaryColor),

        // ─── Contributing Factors (Tags) ──────────────────
        if (data.tags.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Contributing Factors',
            style: GoogleFonts.inter(
              fontSize: 14, color: Colors.white38, fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Text(tag, style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
            )).toList(),
          ),
        ],

        // ─── Positive Memory Card ──────────────────
        if (isPositive && data.state == MoodFlowState.positiveMemory) ...[
          const SizedBox(height: 32),
          PositiveMemoryCard(
            emotion: data.selectedMood ?? widget.mood,
            text: 'This was a moment worth remembering.',
            onSave: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Memory saved to your vault! ✨')),
              );
            },
          ),
        ],

        // ─── Top Recommendations ──────────────────
        const SizedBox(height: 32),
        Text(
          'YOUR RECOMMENDATIONS',
          style: GoogleFonts.outfit(
            fontSize: 12, letterSpacing: 2,
            color: primaryColor, fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        if (suggestions.isEmpty)
          ..._buildFallbackSuggestions(primaryColor)
        else
          ...suggestions.map((s) {
            final sMap = Map<String, dynamic>.from(s);
            return SuggestionActionCard(
              title: sMap['title'] ?? 'Suggestion',
              description: sMap['desc'] ?? sMap['description'] ?? '',
              actionType: sMap['type'] ?? 'IMMEDIATE_ACTION',
              onExecute: () {
                _handleToolRoute(context, sMap['title'] ?? '');
              },
            );
          }),

        // ─── Quick Tools ──────────────────
        if (quickTools.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'SUGGESTED TOOLS',
            style: GoogleFonts.outfit(
              fontSize: 12, letterSpacing: 2,
              color: Colors.white38, fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: quickTools.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final tool = quickTools[index].toString();
                return GestureDetector(
                  onTap: () => _handleToolRoute(context, tool),
                  child: Container(
                    width: 120,
                    decoration: MoodThemeMapper.getCardDecoration(theme.cardStyle, primaryColor),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_getToolIcon(tool), color: primaryColor, size: 24),
                          const SizedBox(height: 6),
                          Text(
                            tool,
                            style: GoogleFonts.inter(
                              color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        // ─── Action Bar ──────────────────
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.analytics_outlined, size: 20),
            label: Text('View My Journey', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
            onPressed: () => context.push('/mood-analytics'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: Text('AI Chat', style: GoogleFonts.inter(fontSize: 14)),
                onPressed: () => context.push('/chat'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text('Done', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                onPressed: () {
                  ref.read(moodFlowProvider.notifier).reset();
                  context.go('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ─── AI Comfort Message Widget ─────────────────────────────

  Widget _buildAiComfortSection(Color primaryColor) {
    if (_isLoadingAi) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2, color: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Nova is thinking about how to support you...',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      );
    }

    if (_aiComfortMessage == null || _aiComfortMessage!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: primaryColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'NOVA SAYS',
                style: GoogleFonts.outfit(
                  fontSize: 10, letterSpacing: 2,
                  color: primaryColor, fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _aiComfortMessage!,
            style: GoogleFonts.spectral(
              fontSize: 16, color: Colors.white.withValues(alpha: 0.85),
              height: 1.6, fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────

  List<Widget> _buildFallbackSuggestions(Color primaryColor) {
    return [
      SuggestionActionCard(
        title: 'Take a Breath',
        description: 'Pause and hold for 4 seconds. Exhale slowly.',
        actionType: 'IMMEDIATE_ACTION',
        onExecute: () {},
      ),
      SuggestionActionCard(
        title: 'Journal It Out',
        description: 'Writing about your feelings can bring clarity.',
        actionType: 'REFLECTION_PROMPT',
        onExecute: () {},
      ),
      SuggestionActionCard(
        title: 'Try Breathing Exercise',
        description: 'A 2-minute guided session to center yourself.',
        actionType: 'TOOL_RECOMMENDATION',
        onExecute: () {},
      ),
    ];
  }

  void _handleToolRoute(BuildContext context, String toolName) {
    final lower = toolName.toLowerCase();
    if (lower.contains('sleep')) {
      context.push('/sleep');
    } else if (lower.contains('breathing') || lower.contains('breath')) {
      context.push('/breathing');
    } else if (lower.contains('journal')) {
      context.push('/chat');
    } else if (lower.contains('chat') || lower.contains('ai')) {
      context.push('/chat');
    } else if (lower.contains('crisis') || lower.contains('hotline') || lower.contains('support')) {
      context.push('/crisis');
    } else if (lower.contains('grounding')) {
      context.push('/breathing');
    } else if (lower.contains('recovery') || lower.contains('burnout')) {
      context.push('/tools');
    } else {
      context.push('/tools');
    }
  }

  IconData _getToolIcon(String tool) {
    final lower = tool.toLowerCase();
    if (lower.contains('sleep')) return Icons.nightlight_round;
    if (lower.contains('journal')) return Icons.edit_note;
    if (lower.contains('breathing') || lower.contains('breath')) return Icons.air;
    if (lower.contains('chat') || lower.contains('ai')) return Icons.chat;
    if (lower.contains('grounding')) return Icons.spa;
    if (lower.contains('crisis') || lower.contains('hotline')) return Icons.warning_rounded;
    if (lower.contains('memory') || lower.contains('save')) return Icons.star_rounded;
    if (lower.contains('gratitude')) return Icons.favorite;
    if (lower.contains('focus') || lower.contains('timer')) return Icons.timer;
    if (lower.contains('walk')) return Icons.directions_walk;
    if (lower.contains('hydra')) return Icons.water_drop;
    if (lower.contains('recovery')) return Icons.healing;
    if (lower.contains('streak') || lower.contains('share')) return Icons.share;
    if (lower.contains('therapist')) return Icons.psychology;
    if (lower.contains('rain') || lower.contains('sound')) return Icons.surround_sound;
    return Icons.auto_awesome;
  }
}

// ==========================================
// FALLBACK WIDGETS (Replacing deleted v1 mood widgets)
// ==========================================

class CrisisSupportCard extends StatelessWidget {
  final String hotlineName;
  final String hotlineNumber;
  final VoidCallback onCall;
  final VoidCallback onBreathe;

  const CrisisSupportCard({
    super.key,
    required this.hotlineName,
    required this.hotlineNumber,
    required this.onCall,
    required this.onBreathe,
  });

  @override
  Widget build(BuildContext context) {
    return MindNovaHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_rounded, color: AppColors.emotionalDangerMuted),
              const SizedBox(width: 8),
              Text('Crisis Support', style: AppTypography.headingMedium),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCall,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emotionalDangerMuted),
            child: Text('Call $hotlineName ($hotlineNumber)'),
          ),
        ],
      ),
    );
  }
}

class PositiveMemoryCard extends StatelessWidget {
  final String emotion;
  final String text;
  final VoidCallback onSave;

  const PositiveMemoryCard({
    super.key,
    required this.emotion,
    required this.text,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return MindNovaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.emotionalWarning),
              const SizedBox(width: 8),
              Text('Positive Memory', style: AppTypography.headingSmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: AppTypography.body),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onSave,
            child: const Text('Save to Vault'),
          ),
        ],
      ),
    );
  }
}

class SuggestionActionCard extends StatelessWidget {
  final String title;
  final String description;
  final String actionType;
  final VoidCallback onExecute;

  const SuggestionActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.actionType,
    required this.onExecute,
  });

  @override
  Widget build(BuildContext context) {
    return MindNovaFeatureCard(
      title: title,
      subtitle: description,
      icon: Icons.lightbulb_rounded,
      onTap: onExecute,
    );
  }
}
