import re

with open('lib/features/mood_v2/presentation/mood_home_screen_v2.dart', 'r') as f:
    content = f.read()

# 1. _buildHeroSection
hero_old = """  Widget _buildHeroSection() {
    return _buildGlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR EMOTIONAL MIRROR', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.05 * 14, color: const Color(0xFF44E2CD))),
          const SizedBox(height: 16),
          Text(
            'Over the last week you have shown greater emotional resilience during periods of reflection.',
            style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w500, height: 1.3, color: const Color(0xFFDFE2F3)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF44E2CD).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFF44E2CD).withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up, color: Color(0xFF44E2CD), size: 16),
                    const SizedBox(width: 8),
                    Text('Growing', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF44E2CD))),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmotionalCheckinScreen())),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCABEFF),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('Check In', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF2A0088))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }"""

hero_new = """  Widget _buildHeroSection() {
    final analyticsAsync = ref.watch(moodAnalyticsSummaryProvider(7));
    return _buildGlassCard(
      padding: const EdgeInsets.all(32),
      child: analyticsAsync.when(
        data: (data) {
          final isGrowing = data.trendDirection == 'up';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('YOUR EMOTIONAL MIRROR', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.05 * 14, color: const Color(0xFF44E2CD))),
              const SizedBox(height: 16),
              Text(
                data.summaryMessage ?? 'Start logging to build your emotional mirror.',
                style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w500, height: 1.3, color: const Color(0xFFDFE2F3)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (data.hasData)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF44E2CD).withOpacity(0.1),
                        border: Border.all(color: const Color(0xFF44E2CD).withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isGrowing ? Icons.trending_up : Icons.trending_flat, color: const Color(0xFF44E2CD), size: 16),
                          const SizedBox(width: 8),
                          Text(isGrowing ? 'Growing' : 'Stable', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF44E2CD))),
                        ],
                      ),
                    ),
                  if (data.hasData) const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmotionalCheckinScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCABEFF),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text('Check In', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF2A0088))),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))),
        error: (e, st) => Text('Error loading mirror', style: const TextStyle(color: Colors.red)),
      ),
    );
  }"""

content = content.replace(hero_old, hero_new)

# 2. _buildNovaNoticed
noticed_regex = re.compile(r'Widget _buildNovaNoticed\(\) \{.*?return Column\(\n.*?Row\(\n.*?"Nova Noticed".*?\}\);.*?\}', re.DOTALL)
noticed_new = """  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'bedtime': return Icons.bedtime;
      case 'label': return Icons.label;
      case 'warning': return Icons.warning;
      case 'health_and_safety': return Icons.health_and_safety;
      case 'trending_up': return Icons.trending_up;
      case 'trending_down': return Icons.trending_down;
      case 'weekend': return Icons.weekend;
      default: return Icons.auto_awesome;
    }
  }

  Widget _buildNovaNoticed() {
    final insightsAsync = ref.watch(weeklyInsightsProvider(7));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFCABEFF)),
            const SizedBox(width: 8),
            Text('Nova Noticed', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w500, color: const Color(0xFFDFE2F3))),
          ],
        ),
        const SizedBox(height: 24),
        insightsAsync.when(
          data: (data) {
            if (data.insights.isEmpty) return const SizedBox.shrink();
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: data.insights.map((insight) {
                  return Container(
                    width: 320,
                    margin: const EdgeInsets.only(right: 16),
                    child: _buildGlassCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: const Color(0xFF44E2CD).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                            child: Icon(_getIconData(insight.icon), color: const Color(0xFF44E2CD)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(insight.title, style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: const Color(0xFFDFE2F3))),
                                const SizedBox(height: 8),
                                Text(insight.subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF938EA1))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))),
          error: (e, st) => const Text('Failed to load insights', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }"""
content = noticed_regex.sub(noticed_new, content)

# 3. _buildEmotionalJourney (chart data binding)
journey_old = """      child: CustomPaint(
        size: const Size(double.infinity, 300),
        painter: _EmotionalJourneyPainter(),
      ),"""

journey_new = """      child: ref.watch(analyticsProvider(7)).isLoading
          ? const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD))))
          : CustomPaint(
              size: const Size(double.infinity, 300),
              painter: _EmotionalJourneyPainter(ref.watch(analyticsProvider(7)).trends),
            ),"""

content = content.replace(journey_old, journey_new)

# 4. _buildMoodComposition
comp_regex = re.compile(r'Widget _buildMoodComposition\(\) \{.*?return Column\(\n.*?Text\(\'Mood Composition\'.*?\}\);.*?\}', re.DOTALL)
comp_new = """  Widget _buildMoodComposition() {
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
  }"""
content = comp_regex.sub(comp_new, content)

# 5. _buildInfluenceCards
infl_regex = re.compile(r'Widget _buildInfluenceCards\(\) \{.*?return Column\(\n.*?Text\(\'What Shapes Your Emotions\'.*?\}\);.*?\}', re.DOTALL)
infl_new = """  Widget _buildInfluenceCards() {
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
  }"""
content = infl_regex.sub(infl_new, content)

# 6. _buildRecoveryActivities
rec_regex = re.compile(r'Widget _buildRecoveryActivities\(\) \{.*?return Column\(\n.*?Text\(\'What Helps You Recover\'.*?\}\);.*?\}', re.DOTALL)
rec_new = """  Widget _buildRecoveryActivities() {
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
  }"""
content = rec_regex.sub(rec_new, content)

# 7. _buildReflectionHighlights
refl_regex = re.compile(r'Widget _buildReflectionHighlights\(\) \{.*?return Column\(\n.*?Text\(\'Reflection Highlights\'.*?\}\);.*?\}', re.DOTALL)
refl_new = """  Widget _buildReflectionHighlights() {
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
  }"""
content = refl_regex.sub(refl_new, content)

# 8. _buildNovaSuggests
nova_regex = re.compile(r'Widget _buildNovaSuggests\(\) \{.*?return _buildGlassCard\(\n.*?padding: EdgeInsets.zero,.*?child: ClipRRect\(.*?\'Nova Suggests\'.*?\}\);.*?\}', re.DOTALL)
nova_new = """  Widget _buildNovaSuggests() {
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
  }"""
content = nova_regex.sub(nova_new, content)

with open('lib/features/mood_v2/presentation/mood_home_screen_v2.dart', 'w') as f:
    f.write(content)

