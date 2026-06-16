import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../domain/audio_model.dart';
import '../providers/audio_provider.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/audio_track_card.dart';
import 'widgets/mini_audio_player.dart';

class AudioDashboardScreen extends ConsumerStatefulWidget {
  const AudioDashboardScreen({super.key});

  @override
  ConsumerState<AudioDashboardScreen> createState() => _AudioDashboardScreenState();
}

class _AudioDashboardScreenState extends ConsumerState<AudioDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;

  // Local files state (mocking recently played)
  List<File> _recentLocalFiles = [];
  String _selectedLibraryCategoryId = 'FOR_YOU';

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _pickLocalFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'flac', 'm4a', 'aac'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() {
        if (!_recentLocalFiles.any((f) => f.path == file.path)) {
          _recentLocalFiles.insert(0, file);
        }
      });
      
      // Play the local file
      final track = AudioTrack(
        id: file.path,
        title: result.files.single.name,
        category: 'LOCAL',
        audioUrl: file.path,
        durationSeconds: 0, 
      );
      
      final notifier = ref.read(audioPlayerProvider.notifier);
      notifier.setQueue([track]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F131F),
        body: Stack(
          children: [
            // Atmospheric background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.8, -0.6),
                    radius: 1.5,
                    colors: [Color(0x1A44E2CD), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              right: MediaQuery.of(context).size.width * 0.05,
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x26937DFF), Colors.transparent],
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: const SizedBox(),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                              onPressed: () => context.pop(),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFCABEFF).withValues(alpha: 0.3)),
                                image: const DecorationImage(
                                  image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuDLSTb5ys6Y6_7scqrXkP8ph8SpCTssjGlWUBL6Cjd6FSxLCAyC9ZTWRsjEadN3mKc_u2BO_Dej5P8jz5EkNreqtLOCOAna-semWAxpeUHFXLzAURafitbR_IjdkPnPcVtE4Lps3TkxU28Yv7k65cWo4cOo2xcfBhnGwfO-j7L6m12S4CbsH0CtvZU94VsOQZUg8T4DrnGSl40ZinCIl-iCdAt4rukzk15hgsDdR8ph3dhdfNuKMIxZg3ehmGCuNw0Hq5ILyDo1WuRq"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'MindNova Audio',
                              style: GoogleFonts.manrope(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFCABEFF),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, color: Color(0xFFCABEFF)),
                          onPressed: () => context.push('/audio/search'),
                        ),
                      ],
                    ),
                  ),

                  // TabBar
                  TabBar(
                    indicatorColor: const Color(0xFFCABEFF),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFFCABEFF),
                    unselectedLabelColor: const Color(0xFFC9C4D8),
                    labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
                    unselectedLabelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w500, fontSize: 16),
                    tabs: const [
                      Tab(text: 'MindNova Studio'),
                      Tab(text: 'My Device'),
                    ],
                  ),
                  
                  // TabBarView
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildOnlineTab(context),
                        _buildLocalTab(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Floating Mini Player
            const Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: MiniAudioPlayer(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Online Tab ────────────────────────────────────────────────────────────

  Widget _buildOnlineTab(BuildContext context) {
    final recommendedAsync = ref.watch(recommendedAudioProvider);
    final historyAsync = ref.watch(audioHistoryProvider);
    // You can fetch tracks by specific categories to populate the library list.
    // For now, we will reuse the recommended list or general list.

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 120), // Padding for mini player
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Hero Recommendation
                _buildHeroCard(recommendedAsync, historyAsync),
                const SizedBox(height: 48),
                
                // Emotional Pathways (Bento)
                _buildSectionTitle('psychology', 'Emotional Audio Pathways'),
                const SizedBox(height: 16),
                _buildBentoGrid(context),
                const SizedBox(height: 48),

                // Nova Audio Coach
                _buildAudioCoach(recommendedAsync),
                const SizedBox(height: 48),
                
                // Audio Library
                _buildSectionTitle('library_music', 'Recovery Audio Library'),
                const SizedBox(height: 16),
                _buildLibraryCategories(),
                const SizedBox(height: 16),
                _buildLibraryList(recommendedAsync),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(AsyncValue<List<AudioTrack>> recommendedAsync, AsyncValue<List<UserAudioHistory>> historyAsync) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B1F2C).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFCABEFF).withValues(alpha: 0.1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFF44E2CD), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'NOVA INSIGHT',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF44E2CD),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'High mental chatter detected.',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on your recent interactions, I\'ve curated a grounding frequency to help you recenter.',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFC9C4D8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    recommendedAsync.when(
                      loading: () => const CircularProgressIndicator(color: Color(0xFFCABEFF)),
                      error: (_, __) => const SizedBox(),
                      data: (tracks) {
                        if (tracks.isEmpty) return const SizedBox();
                        final track = tracks.first;
                        return ElevatedButton.icon(
                          onPressed: () {
                            ref.read(audioPlayerProvider.notifier).setQueue(tracks);
                            context.push('/audio/player', extra: track);
                          },
                          icon: const Icon(Icons.play_circle_fill, color: Color(0xFF31009A)),
                          label: Text(
                            'PLAY GROUNDING SESSION',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF31009A),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCABEFF),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          ),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String iconString, String title) {
    IconData icon;
    switch (iconString) {
      case 'psychology': icon = Icons.psychology; break;
      case 'library_music': icon = Icons.library_music; break;
      case 'history': icon = Icons.history; break;
      default: icon = Icons.circle;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFCABEFF), size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioCoach(AsyncValue<List<AudioTrack>> recommendedAsync) {
    return recommendedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
      data: (tracks) {
        if (tracks.isEmpty) return const SizedBox();
        // Use the second recommended track for the coach to provide variety from the Hero card.
        final track = tracks.length > 1 ? tracks[1] : tracks.first;
        final reason = track.recommendationReason ?? "Based on your recent activity, I've curated a specific sequence for your session.";

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B1F2C).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 4,
                    child: Container(color: const Color(0xFF44E2CD)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                // Star Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F131F),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFF44E2CD), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Nova Audio Coach',
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF44E2CD).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'PERSONALIZED',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF44E2CD),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reason,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFC9C4D8),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sub-card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F131F),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF44E2CD).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.graphic_eq, color: Color(0xFF44E2CD), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${track.title} (${track.durationLabel})',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Outcome: ${track.moodBenefit ?? "Deep relaxation"}',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF44E2CD).withValues(alpha: 0.8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(audioPlayerProvider.notifier).setQueue(tracks, startIndex: tracks.length > 1 ? 1 : 0);
                            context.push('/audio/player', extra: track);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF44E2CD)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Preview Insight',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF44E2CD),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ], // end Column children
                  ), // end Column
                ), // end Expanded
              ], // end Row children
            ), // end Row
          ), // end inner Padding
        ], // end Stack children
      ), // end Stack
    ), // end Container
  ), // end ClipRRect
); // end return Padding
      },
    );
  }

  Widget _buildBentoGrid(BuildContext context) {
    final items = [
      _BentoData(
        title: 'Sleep Faster',
        subtitle: '24 Sessions • Delta Waves',
        tag: 'SLEEP',
        imagePath: 'assets/images/audio/sleep_category.png',
        accentColor: const Color(0xFF44E2CD),
        categoryId: 'SLEEP_STORY',
        emoji: '🌙',
        gradientColors: [const Color(0xFF0D2137), const Color(0xFF050B18)],
      ),
      _BentoData(
        title: 'Calm Anxiety',
        subtitle: '18 Sessions • Breathwork',
        tag: 'ANXIETY',
        imagePath: 'assets/images/audio/anxiety_category.png',
        accentColor: const Color(0xFFCABEFF),
        categoryId: 'ANXIETY_RELIEF',
        emoji: '🍃',
        gradientColors: [const Color(0xFF1A0A2E), const Color(0xFF050B18)],
      ),
      _BentoData(
        title: 'Deep Meditation',
        subtitle: '30 Sessions • Zen Flow',
        tag: 'ZEN',
        imagePath: 'assets/images/audio/meditation_category.png',
        accentColor: const Color(0xFFB8A7FF),
        categoryId: 'MEDITATION',
        emoji: '🧘',
        gradientColors: [const Color(0xFF150B2A), const Color(0xFF050B18)],
      ),
      _BentoData(
        title: 'Focus & Flow',
        subtitle: '12 Sessions • Peak State',
        tag: 'FOCUS',
        imagePath: 'assets/images/audio/focus_category.png',
        accentColor: const Color(0xFF44E2CD),
        categoryId: 'FOCUS',
        emoji: '⚡',
        gradientColors: [const Color(0xFF0A1A2E), const Color(0xFF050B18)],
      ),
      _BentoData(
        title: 'Breathwork',
        subtitle: '15 Sessions • Air & Energy',
        tag: 'BREATH',
        imagePath: 'assets/images/audio/breathwork_category.png',
        accentColor: const Color(0xFF80F5E8),
        categoryId: 'BREATHWORK',
        emoji: '💨',
        gradientColors: [const Color(0xFF061822), const Color(0xFF050B18)],
      ),
      _BentoData(
        title: 'Binaural Beats',
        subtitle: '20 Sessions • Cosmic Sync',
        tag: 'BINAURAL',
        imagePath: 'assets/images/audio/binaural_category.png',
        accentColor: const Color(0xFFE0BAFF),
        categoryId: 'BINAURAL',
        emoji: '🌌',
        gradientColors: [const Color(0xFF1A0535), const Color(0xFF050B18)],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Top row: 1 large + 1 small (asymmetric like HTML design)
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: _buildBentoItem(context, items[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: _buildBentoItem(context, items[1]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Middle row: 2 equal
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(child: _buildBentoItem(context, items[2])),
                const SizedBox(width: 12),
                Expanded(child: _buildBentoItem(context, items[3])),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Bottom row: 1 small + 1 large (reversed asymmetric)
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildBentoItem(context, items[4]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: _buildBentoItem(context, items[5]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoItem(BuildContext context, _BentoData data) {
    return GestureDetector(
      onTap: () {
        context.push('/audio/category', extra: AudioCategoryMeta(
          id: data.categoryId,
          label: data.title,
          emoji: data.emoji,
          gradientStart: '#${data.accentColor.toARGB32().toRadixString(16).substring(2, 8)}',
          gradientEnd: '#0F131F',
          moodBenefit: data.subtitle,
        ));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              data.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: data.gradientColors,
                  ),
                ),
              ),
            ),
            // Cinematic gradient overlay from bottom
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Left accent glow
            Positioned(
              left: 0, top: 0, bottom: 0,
              width: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      data.accentColor.withValues(alpha: 0.0),
                      data.accentColor.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tag pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: data.accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: data.accentColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      data.tag,
                      style: GoogleFonts.inter(
                        color: data.accentColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.title,
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.subtitle,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryCategories() {
    final categoriesAsync = ref.watch(audioCategoriesProvider);
    
    return categoriesAsync.when(
      loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox(),
      data: (categories) {
        final allCategories = [
          AudioCategoryMeta(id: 'FOR_YOU', label: 'For You', emoji: '✨', gradientStart: '', gradientEnd: '', moodBenefit: ''),
          ...categories,
        ];
        
        return SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: allCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = allCategories[index];
              final isSelected = _selectedLibraryCategoryId == cat.id;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedLibraryCategoryId = cat.id);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFCABEFF) : const Color(0xFF1B1F2C),
                    borderRadius: BorderRadius.circular(100),
                    border: isSelected ? null : Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Text(
                    cat.label,
                    style: GoogleFonts.inter(
                      color: isSelected ? const Color(0xFF2A0088) : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLibraryList(AsyncValue<List<AudioTrack>> recommendedAsync) {
    final listAsync = _selectedLibraryCategoryId == 'FOR_YOU' 
        ? recommendedAsync 
        : ref.watch(audioTracksProvider(_selectedLibraryCategoryId));

    return listAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Failed to load library')),
      data: (tracks) {
        if (tracks.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No tracks found in this category.', style: TextStyle(color: Colors.white54))),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: tracks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final track = tracks[index];
            return AudioTrackCard(
              track: track,
              onTap: () {
                ref.read(audioPlayerProvider.notifier).setQueue(tracks, startIndex: index);
                context.push('/audio/player', extra: track);
              },
            );
          },
        );
      },
    );
  }

  // ─── Local Tab ─────────────────────────────────────────────────────────────

  Widget _buildLocalTab(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Dropzone
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: _pickLocalFile,
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1F2C).withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFCABEFF).withValues(alpha: 0.3),
                          width: 1,
                          style: BorderStyle.solid, // Flutter doesn't support dashed border natively easily without a package, using solid for now
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCABEFF).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.folder_open, color: Color(0xFFCABEFF), size: 40),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Play Offline Audio',
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Listen to your own downloaded meditations, audiobooks, or relaxing music directly in the MindNova player.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFC9C4D8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCABEFF),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'Browse Device Files',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF31009A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                _buildSectionTitle('history', 'Recently Played Offline'),
                const SizedBox(height: 16),
                
                if (_recentLocalFiles.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'No local files played recently.',
                      style: GoogleFonts.inter(color: Colors.white54),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _recentLocalFiles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final file = _recentLocalFiles[index];
                      final name = file.path.split('/').last;
                      return GestureDetector(
                        onTap: () {
                           final track = AudioTrack(
                            id: file.path,
                            title: name,
                            category: 'LOCAL',
                            audioUrl: file.path,
                            durationSeconds: 0, 
                          );
                          ref.read(audioPlayerProvider.notifier).setQueue([track]);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1F2C).withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF262A37),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.audio_file, color: Color(0xFFC9C4D8)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Internal Storage',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFC9C4D8).withValues(alpha: 0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.play_arrow_rounded, color: Colors.white54),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Data model for Bento items ─────────────────────────────────────────────

class _BentoData {
  final String title;
  final String subtitle;
  final String tag;
  final String imagePath;
  final Color accentColor;
  final String categoryId;
  final String emoji;
  final List<Color> gradientColors;

  const _BentoData({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.imagePath,
    required this.accentColor,
    required this.categoryId,
    required this.emoji,
    required this.gradientColors,
  });
}
