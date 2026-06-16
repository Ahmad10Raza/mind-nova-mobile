import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../providers/dashboard_provider.dart';

class FeatureCarouselSection extends ConsumerStatefulWidget {
  const FeatureCarouselSection({super.key});

  @override
  ConsumerState<FeatureCarouselSection> createState() => _FeatureCarouselSectionState();
}

class _FeatureCarouselSectionState extends ConsumerState<FeatureCarouselSection> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['All', 'Relief', 'Calm', 'Mind', 'Support'];

  final List<_FeatureItem> _features = [
    _FeatureItem(
      title: 'Nova AI Companion',
      description: '24/7 empathetic conversational AI for support and guidance.',
      icon: Icons.auto_awesome_rounded,
      color: DashboardTheme.primaryPurple,
      route: '/chat',
      asset: 'assets/images/nova_ai.png',
      category: 'Support',
    ),
    _FeatureItem(
      title: 'Resilience Challenges',
      description: 'Structured multi-day journeys designed to build lasting resilience.',
      icon: Icons.emoji_events_rounded,
      color: const Color(0xFFFFB74D),
      route: '/challenges',
      asset: 'assets/illustrations/Meditation.png',
      category: 'Calm',
    ),
    _FeatureItem(
      title: '5-4-3-2-1 Sensory',
      description: 'Sensory grounding to anchor yourself in the present moment.',
      icon: Icons.fingerprint_rounded,
      color: const Color(0xFF81C784),
      route: '/sensory-grounding',
      asset: 'assets/illustrations/Meditation.png',
      category: 'Relief',
    ),
    _FeatureItem(
      title: 'Panic Reset',
      description: 'High-intensity grounding for acute anxiety or panic attacks.',
      icon: Icons.bolt_rounded,
      color: DashboardTheme.crisisRed,
      route: '/panic-reset',
      asset: 'assets/illustrations/Meditation.png',
      category: 'Relief',
    ),
    _FeatureItem(
      title: 'Breathing Studio',
      description: '6+ techniques including Box, 4-7-8, and Color Breathing.',
      icon: Icons.air_rounded,
      color: DashboardTheme.sleepBlue,
      route: '/breathing',
      asset: 'assets/illustrations/Meditation.png',
      category: 'Calm',
    ),
    _FeatureItem(
      title: 'Zen Mode Focus',
      description: 'A distraction-free deep work timer with an immersive shield.',
      icon: Icons.timer_rounded,
      color: const Color(0xFF4DB6AC),
      route: '/zen-mode',
      asset: 'assets/illustrations/FlowerOnMind.png',
      category: 'Calm',
    ),
    _FeatureItem(
      title: 'Audio Sanctuary',
      description: 'Ambient soundscapes, white noise, and guided meditations.',
      icon: Icons.headphones_rounded,
      color: const Color(0xFF9575CD),
      route: '/audio',
      asset: 'assets/illustrations/Meditation.png',
      category: 'Calm',
    ),
    _FeatureItem(
      title: 'Safe Place',
      description: 'Guided visualization to create a mental sanctuary.',
      icon: Icons.fort_rounded,
      color: const Color(0xFFBA68C8),
      route: '/safe-place',
      asset: 'assets/illustrations/Meditation.png',
      category: 'Relief',
    ),
    _FeatureItem(
      title: 'Mood Flow & Insights',
      description: 'Quick-tap emotional check-ins with AI-driven trend analysis.',
      icon: Icons.emoji_emotions_rounded,
      color: DashboardTheme.moodGreen,
      route: '/mood-checkin',
      asset: 'assets/illustrations/FlowerOnMind.png',
      category: 'Mind',
    ),
    _FeatureItem(
      title: 'AI Journal Editor',
      description: 'Free-form journaling with AI-powered insight generation.',
      icon: Icons.edit_note_rounded,
      color: const Color(0xFF64B5F6),
      route: '/ai-journal',
      asset: 'assets/illustrations/FlowerOnMind.png',
      category: 'Mind',
    ),
    _FeatureItem(
      title: 'Gratitude Journal',
      description: 'A dedicated space for daily appreciation rituals.',
      icon: Icons.favorite_rounded,
      color: const Color(0xFFF06292),
      route: '/gratitude',
      asset: 'assets/illustrations/FlowerOnMind.png',
      category: 'Mind',
    ),
    _FeatureItem(
      title: 'Habit Formation',
      description: 'Ritual building and streak tracking for consistent wellness.',
      icon: Icons.check_circle_rounded,
      color: DashboardTheme.recoveryTeal,
      route: '/habits',
      asset: 'assets/illustrations/FlowerOnMind.png',
      category: 'Mind',
    ),
    _FeatureItem(
      title: 'Clinical Assessments',
      description: 'Standardized screening tools (PHQ-9, GAD-7, PSS).',
      icon: Icons.psychology_rounded,
      color: DashboardTheme.stressAmber,
      route: '/adaptive-assessment/clinical_main',
      asset: 'assets/illustrations/Meditation.png',
      category: 'Mind',
    ),
    _FeatureItem(
      title: 'Community Feed',
      description: 'A safe, moderated social space for sharing experiences.',
      icon: Icons.forum_rounded,
      color: DashboardTheme.anxietyPink,
      route: '/community/feed',
      asset: 'assets/illustrations/Meditation.png',
      category: 'Support',
    ),
    _FeatureItem(
      title: 'Live Circles',
      description: 'Real-time, guided audio support rooms with others.',
      icon: Icons.record_voice_over_rounded,
      color: const Color(0xFF4FC3F7),
      route: '/live-circles',
      asset: 'assets/illustrations/Meditation.png',
      category: 'Support',
    ),
    _FeatureItem(
      title: 'Recovery Engine',
      description: 'Holistic view of your mental recovery state and readiness.',
      icon: Icons.battery_charging_full_rounded,
      color: const Color(0xFF81C784),
      route: '/recovery',
      asset: 'assets/illustrations/Meditation.png',
      category: 'Mind',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMinimized = ref.watch(discoveryMinimizedProvider);
    
    return AnimatedCrossFade(
      firstChild: _buildFullDiscovery(),
      secondChild: _buildMinimizedDiscovery(),
      crossFadeState: isMinimized ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 600),
      firstCurve: Curves.easeInOutBack,
      secondCurve: Curves.easeOutBack,
    );
  }

  Widget _buildFullDiscovery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DISCOVERY HUB', style: DashboardTheme.heading2),
                  const SizedBox(height: 2),
                  Container(
                    height: 3,
                    width: 40,
                    decoration: BoxDecoration(
                      gradient: DashboardTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
              // Creative Hide Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(discoveryMinimizedProvider.notifier).setMinimized(true);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: DashboardTheme.textTertiary.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.expand_less_rounded, color: DashboardTheme.textSecondary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Hide',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: DashboardTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // ─── Tab Bar Navigation (Full Width) ──────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: DashboardTheme.textTertiary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false, // Distribute tabs across full width
              labelColor: Colors.white,
              unselectedLabelColor: DashboardTheme.textSecondary,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                gradient: DashboardTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: DashboardTheme.primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              labelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
              padding: const EdgeInsets.all(4),
              tabs: _categories.map((cat) => Tab(text: cat)).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // ─── Tab Bar Content (Tool Carousels) ────────
        SizedBox(
          height: 250,
          child: TabBarView(
            controller: _tabController,
            children: _categories.map((cat) {
              final catFeatures = cat == 'All' 
                  ? _features 
                  : _features.where((f) => f.category == cat).toList();
              return _CategoryCarousel(features: catFeatures);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMinimizedDiscovery() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(discoveryMinimizedProvider.notifier).setMinimized(false);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                DashboardTheme.primaryPurple.withValues(alpha: 0.08),
                DashboardTheme.primaryPurple.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: DashboardTheme.primaryPurple.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: DashboardTheme.primaryPurple.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.explore_rounded, color: DashboardTheme.primaryPurple, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                'Explore MindNova Tools',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: DashboardTheme.primaryPurple,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.keyboard_arrow_down_rounded, color: DashboardTheme.primaryPurple, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCarousel extends StatefulWidget {
  final List<_FeatureItem> features;
  const _CategoryCarousel({required this.features});

  @override
  State<_CategoryCarousel> createState() => _CategoryCarouselState();
}

class _CategoryCarouselState extends State<_CategoryCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients && widget.features.isNotEmpty) {
        int nextPage = _currentPage + 1;
        if (nextPage >= widget.features.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.features.isEmpty) {
      return const Center(child: Text('No tools found in this category.'));
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: widget.features.length,
            itemBuilder: (context, index) {
              final feature = widget.features[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.12)).clamp(0.0, 1.0);
                  } else {
                    value = index == 0 ? 1.0 : 0.88;
                  }

                  return Center(
                    child: Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value.clamp(0.6, 1.0),
                        child: _FeatureCard(feature: feature, isCurrent: _currentPage == index),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.features.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              width: _currentPage == index ? 16 : 4,
              decoration: BoxDecoration(
                color: _currentPage == index 
                    ? DashboardTheme.primaryPurple 
                    : DashboardTheme.textTertiary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem feature;
  final bool isCurrent;
  const _FeatureCard({required this.feature, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 210,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: DashboardTheme.cardWhite,
        borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          if (isCurrent)
            BoxShadow(
              color: feature.color.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 20),
              spreadRadius: -10,
            ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      feature.color.withValues(alpha: 0.04),
                      Colors.transparent,
                      feature.color.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: feature.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(feature.icon, color: feature.color, size: 22),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          feature.title,
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: DashboardTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature.description,
                          style: DashboardTheme.bodySmall.copyWith(
                            height: 1.3,
                            color: DashboardTheme.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 2,
                        ),
                        const Spacer(),
                        _buildCTA(context, feature),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: feature.color.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: ClipOval(
                              child: Image.asset(
                                feature.asset,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(Icons.spa_rounded, size: 35, color: feature.color),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTA(BuildContext context, _FeatureItem feature) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(feature.route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: feature.color,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: feature.color.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Explore',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 10),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final String asset;
  final String category;

  _FeatureItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    required this.asset,
    required this.category,
  });
}
