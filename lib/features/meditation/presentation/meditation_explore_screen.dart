import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/meditation_provider.dart';
import '../domain/meditation_model.dart';

class MeditationExploreScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const MeditationExploreScreen({super.key, this.initialCategory});

  @override
  ConsumerState<MeditationExploreScreen> createState() => _MeditationExploreScreenState();
}

class _MeditationExploreScreenState extends ConsumerState<MeditationExploreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  String? _selectedCategory;

  final List<Map<String, dynamic>> _allCategories = [
    {'key': null, 'label': 'All', 'icon': Icons.auto_awesome_rounded, 'emoji': '✨', 'gradient': [const Color(0xFF4F46E5), const Color(0xFF7C3AED)], 'desc': 'Every meditation'},
    {'key': 'SLEEP', 'label': 'Sleep', 'icon': Icons.bedtime_rounded, 'emoji': '🌙', 'gradient': [const Color(0xFF1E3A8A), const Color(0xFF312E81)], 'desc': 'Fall asleep faster'},
    {'key': 'ANXIETY_RELIEF', 'label': 'Anxiety', 'icon': Icons.favorite_rounded, 'emoji': '💜', 'gradient': [const Color(0xFF7C3AED), const Color(0xFF4F46E5)], 'desc': 'Ease your mind'},
    {'key': 'FOCUS', 'label': 'Focus', 'icon': Icons.visibility_rounded, 'emoji': '🎯', 'gradient': [const Color(0xFF0E7490), const Color(0xFF0F766E)], 'desc': 'Sharp & clear'},
    {'key': 'HEALING', 'label': 'Healing', 'icon': Icons.spa_rounded, 'emoji': '🌸', 'gradient': [const Color(0xFF9333EA), const Color(0xFFBE185D)], 'desc': 'Restore your soul'},
    {'key': 'STRESS_RECOVERY', 'label': 'Stress', 'icon': Icons.self_improvement_rounded, 'emoji': '🌊', 'gradient': [const Color(0xFF065F46), const Color(0xFF0E7490)], 'desc': 'Release tension'},
    {'key': 'GRATITUDE', 'label': 'Gratitude', 'icon': Icons.volunteer_activism_rounded, 'emoji': '🙏', 'gradient': [const Color(0xFFB45309), const Color(0xFF92400E)], 'desc': 'Open your heart'},
    {'key': 'SELF_LOVE', 'label': 'Self Love', 'icon': Icons.favorite_border_rounded, 'emoji': '🫶', 'gradient': [const Color(0xFFBE185D), const Color(0xFF9333EA)], 'desc': 'Love yourself'},
    {'key': 'CONFIDENCE', 'label': 'Confidence', 'icon': Icons.star_rounded, 'emoji': '⭐', 'gradient': [const Color(0xFFEA580C), const Color(0xFFD97706)], 'desc': 'Stand tall'},
    {'key': 'DEEP_RELAXATION', 'label': 'Deep Calm', 'icon': Icons.waves_rounded, 'emoji': '🌿', 'gradient': [const Color(0xFF1E3A8A), const Color(0xFF115E59)], 'desc': 'Pure stillness'},
    {'key': 'PANIC_RECOVERY', 'label': 'Panic', 'icon': Icons.emergency_rounded, 'emoji': '🆘', 'gradient': [const Color(0xFFDC2626), const Color(0xFF9333EA)], 'desc': 'Instant relief'},
    {'key': 'MORNING_ENERGY', 'label': 'Morning', 'icon': Icons.wb_sunny_rounded, 'emoji': '☀️', 'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)], 'desc': 'Start fresh'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _selectedCatData {
    if (_selectedCategory == null) return _allCategories.first;
    return _allCategories.firstWhere((c) => c['key'] == _selectedCategory, orElse: () => _allCategories.first);
  }

  List<Color> get _activeCatGradient => (_selectedCatData['gradient'] as List<Color>);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      body: Stack(
        children: [
          // Animated gradient background that changes per category
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _activeCatGradient.first.withOpacity(0.15),
                    const Color(0xFF050B18),
                    _activeCatGradient.last.withOpacity(0.08),
                  ],
                ),
              ),
            ),
          ),
          // Glowing background orb
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_activeCatGradient.first.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildCategoryTabs(),
                _buildSelectedCategoryHero(),
                Expanded(child: _buildCatalogList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Meditations',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Find your perfect practice',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Icons.search_rounded, color: Colors.white54, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _allCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _allCategories[i];
          final isActive = _selectedCategory == cat['key'];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['key']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(colors: cat['gradient'] as List<Color>)
                    : null,
                color: isActive ? null : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isActive
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.1),
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: (cat['gradient'] as List<Color>).first.withOpacity(0.4), blurRadius: 12, spreadRadius: -2)]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat['emoji'] as String, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    cat['label'] as String,
                    style: GoogleFonts.inter(
                      color: isActive ? Colors.white : Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedCategoryHero() {
    final cat = _selectedCatData;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: Container(
        key: ValueKey(_selectedCategory),
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: (cat['gradient'] as List<Color>).map((c) => c.withOpacity(0.3)).toList(),
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: (cat['gradient'] as List<Color>).first.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: cat['gradient'] as List<Color>),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(cat['emoji'] as String, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat['label'] as String, style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  Text(cat['desc'] as String, style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
                ],
              ),
            ),
            Icon(cat['icon'] as IconData, color: Colors.white.withOpacity(0.15), size: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogList() {
    final catalog = ref.watch(meditationCatalogProvider(_selectedCategory));
    return catalog.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
      error: (e, _) => _buildMockCatalog(),
      data: (items) {
        if (items.isEmpty) return _buildMockCatalog();
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _buildContentCard(context, items[i]),
        );
      },
    );
  }

  Widget _buildMockCatalog() {
    final mockItems = [
      _MockItem('Calm the Overthinking Mind', 10, 'ANXIETY_RELIEF', 'Beginner', '🌀'),
      _MockItem('Sleep Faster Tonight', 15, 'SLEEP', 'Easy', '🌙'),
      _MockItem('Morning Energy Boost', 8, 'MORNING_ENERGY', 'Beginner', '☀️'),
      _MockItem('Anxiety Reset', 10, 'ANXIETY_RELIEF', 'Beginner', '💨'),
      _MockItem('Deep Focus Flow', 20, 'FOCUS', 'Intermediate', '🎯'),
      _MockItem('Emotional Healing', 20, 'HEALING', 'Moderate', '💜'),
      _MockItem('Panic Recovery', 5, 'PANIC_RECOVERY', 'Urgent', '🆘'),
      _MockItem('Gratitude Awakening', 12, 'GRATITUDE', 'Beginner', '🙏'),
    ];
    final filtered = _selectedCategory == null
        ? mockItems
        : mockItems.where((m) => m.category == _selectedCategory).toList();
    final display = filtered.isEmpty ? mockItems : filtered;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: display.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final item = display[i];
        final gradColors = (_allCategories.firstWhere(
          (c) => c['key'] == item.category,
          orElse: () => _allCategories.first,
        )['gradient'] as List<Color>);
        return GestureDetector(
          onTap: () => context.push('/meditation/player'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradColors.map((c) => c.withOpacity(0.35)).toList()),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: gradColors.first.withOpacity(0.3)),
                  ),
                  child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: gradColors.first.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('${item.duration} min', style: GoogleFonts.inter(color: gradColors.first, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 6),
                          Text(item.difficulty, style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/meditation/player'),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradColors),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentCard(BuildContext context, MeditationContent item) {
    final gradColors = (_allCategories.firstWhere(
      (c) => c['key'] == item.category,
      orElse: () => _allCategories.first,
    )['gradient'] as List<Color>);
    final emoji = (_allCategories.firstWhere(
      (c) => c['key'] == item.category,
      orElse: () => _allCategories.first,
    )['emoji'] as String);

    return GestureDetector(
      onTap: () => context.push('/meditation/player', extra: item),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradColors.map((c) => c.withOpacity(0.35)).toList()),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: gradColors.first.withOpacity(0.3)),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: gradColors.first.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${item.durationMinutes} min', style: GoogleFonts.inter(color: gradColors.first, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 6),
                      Text(item.difficulty, style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
                      if (item.isFeatured) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBBF24).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('⭐ Featured', style: GoogleFonts.inter(color: const Color(0xFFFBBF24), fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/meditation/player', extra: item),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradColors),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockItem {
  final String title;
  final int duration;
  final String category;
  final String difficulty;
  final String emoji;
  _MockItem(this.title, this.duration, this.category, this.difficulty, this.emoji);
}
