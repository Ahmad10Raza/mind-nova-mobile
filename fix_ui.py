import re

with open('lib/features/mood_v2/presentation/mood_home_screen_v2.dart', 'r') as f:
    content = f.read()

# We need to find the end of `_buildEmotionalJourney()` which ends right before `_buildMoodComposition()`.
# Then we will replace everything from `_buildMoodComposition` up to `class _EmotionalCheckinScreenState` with the proper implementations.

new_methods = """  Widget _buildMoodComposition() {
    final distAsync = ref.watch(moodDistributionProvider(30));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mood Composition', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w500, color: const Color(0xFFDFE2F3))),
        const SizedBox(height: 24),
        _buildGlassCard(
          padding: const EdgeInsets.all(32),
          child: distAsync.when(
            data: (data) {
              if (!data.hasData) return const Center(child: Text('Not enough data', style: TextStyle(color: Colors.white)));
              return Column(
                children: [
                  _buildCompositionRow('Positive', '${data.positive}%', data.positive / 100, const Color(0xFF44E2CD)),
                  const SizedBox(height: 24),
                  _buildCompositionRow('Neutral', '${data.neutral}%', data.neutral / 100, const Color(0xFFCABEFF)),
                  const SizedBox(height: 24),
                  _buildCompositionRow('Negative', '${data.negative}%', data.negative / 100, const Color(0xFF938EA1)),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))),
            error: (e, st) => const Text('Error loading composition', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  Widget _buildCompositionRow(String label, String percent, double progress, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFC9C4D8))),
            Text(percent, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF262A37),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildInfluenceCards() {
    final triggerAsync = ref.watch(triggerAnalysisProvider(30));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What Shapes Your Emotions', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w500, color: const Color(0xFFDFE2F3))),
        const SizedBox(height: 24),
        triggerAsync.when(
          data: (data) {
            if (!data.hasData || data.topTriggers.isEmpty) return const SizedBox.shrink();
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: data.topTriggers.map((t) {
                  return SizedBox(
                    width: 280,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: _buildInfluenceCard('Influence', t.tag, 'Linked heavily to ${t.linkedMoods.join(" and ")}', Color(int.parse(t.color.replaceFirst('#', '0xFF')))),
                    ),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))),
          error: (e, st) => const Text('Error loading triggers', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildInfluenceCard(String label, String title, String body, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF171B28).withOpacity(0.4),
            border: Border(
              left: BorderSide(color: color, width: 4),
              top: BorderSide(color: Colors.white.withOpacity(0.08)),
              right: BorderSide(color: Colors.white.withOpacity(0.08)),
              bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: -0.05 * 12, color: color)),
              const SizedBox(height: 8),
              Text(title, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w500, color: const Color(0xFFDFE2F3))),
              const SizedBox(height: 12),
              Text(body, style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFC9C4D8))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecoveryActivities() {
    final recoveryAsync = ref.watch(recoveryEffectivenessProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What Helps You Recover', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w500, color: const Color(0xFFDFE2F3))),
        const SizedBox(height: 24),
        recoveryAsync.when(
          data: (data) {
            if (!data.hasData || data.tools.isEmpty) return const SizedBox.shrink();
            return Column(
              children: data.tools.map((t) {
                int score = (t.helpedPercent / 33).round();
                if (score > 3) score = 3;
                if (score < 1) score = 1;
                final labels = ['EMERGING IMPACT', 'MODERATE IMPACT', 'HIGH IMPACT'];
                final colors = [const Color(0xFFC2C6D1), const Color(0xFFCABEFF), const Color(0xFF44E2CD)];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildRecoveryRow(Icons.healing, t.name, labels[score-1], colors[score-1], score),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))),
          error: (e, st) => const Text('Error loading recovery', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildRecoveryRow(IconData icon, String title, String impactLabel, Color color, int score) {
    return _buildGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFFDFE2F3)))),
          Text(impactLabel, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.05 * 10, color: color)),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) => Container(
              width: 4, height: 16,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: index < score ? color : color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(100),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionHighlights() {
    final highlightsAsync = ref.watch(reflectionHighlightsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reflection Highlights', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w500, color: const Color(0xFFDFE2F3))),
        const SizedBox(height: 24),
        highlightsAsync.when(
          data: (data) {
            if (!data.hasData || data.highlights.isEmpty) return const SizedBox.shrink();
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: data.highlights.map((h) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildQuoteCard(h.category, h.quote, Color(int.parse(h.color.replaceFirst('#', '0xFF')))),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))),
          error: (e, st) => const Text('Error loading highlights', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildQuoteCard(String category, String quote, Color color) {
    return SizedBox(
      width: 220,
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.format_quote, color: color),
            const SizedBox(height: 16),
            Text(quote, style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: const Color(0xFFDFE2F3))),
            const SizedBox(height: 16),
            Text(category.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.05 * 10, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildNovaSuggests() {
    final suggestAsync = ref.watch(novaSuggestsProvider);
    return suggestAsync.when(
      data: (data) {
        return _buildGlassCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.8, -0.8),
                          radius: 1.5,
                          colors: [const Color(0xFF2A0088).withOpacity(0.4), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 100, height: 100,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFFCABEFF).withOpacity(0.3), blurRadius: 48)]),
                              ),
                              ClipOval(
                                child: Image.network('https://lh3.googleusercontent.com/aida-public/AB6AXuB2KJZNVuhrPtu2WGQAm6ocKFWUS5d5X4f96qbnxHowippfD2PhH1mR_ppqClBuSd3tUxZQ6f3FEQGJFqG-3IBOTAQEqJWven0WsBr0LSLcrPHbvVYel3-ujyEKec-AjOOsuuKQRwtxjNzOuOzk8qZMejMbK5CD8A6qA_YetDmU1TdZlQbr6Wkax_N5klQrCepq2lbD2d9RophFcwMNbMJaMC-FefHDtN7lfNi_vyJag_OwVCtEjA9IMMK9NYGU8pwjIexGmEwAPG3-', fit: BoxFit.cover),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(data.title, style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w500, color: const Color(0xFFCABEFF)), textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            Text(data.body, style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFDFE2F3)), textAlign: TextAlign.center),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  decoration: BoxDecoration(color: const Color(0xFF44E2CD), borderRadius: BorderRadius.circular(100), boxShadow: [BoxShadow(color: const Color(0xFF44E2CD).withOpacity(0.4), blurRadius: 20)]),
                                  child: Text(data.actionLabel, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF003731))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))),
      error: (e, st) => const Text('Error loading suggestions', style: TextStyle(color: Colors.red)),
    );
  }
}

class EmotionalCheckinScreen extends StatefulWidget {
  const EmotionalCheckinScreen({super.key});

  @override
  State<EmotionalCheckinScreen> createState() => _EmotionalCheckinScreenState();
}
"""

start_idx = content.find("Widget _buildMoodComposition() {")
end_idx = content.find("class _EmotionalCheckinScreenState extends State<EmotionalCheckinScreen> {")

if start_idx != -1 and end_idx != -1:
    new_content = content[:start_idx] + new_methods + '\n' + content[end_idx:]
    # Append missing closing brace for _EmotionalCheckinScreenState if it's missing at EOF
    if not new_content.strip().endswith('}'):
        new_content = new_content.strip() + '\n}\n'
    
    with open('lib/features/mood_v2/presentation/mood_home_screen_v2.dart', 'w') as f:
        f.write(new_content)
    print("Fixed mood_home_screen_v2.dart successfully.")
else:
    print("Could not find insertion points.")
