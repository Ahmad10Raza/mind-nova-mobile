import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sleep_sound.dart';
import '../repositories/audio_repository.dart';
import 'widgets/night_sky_background.dart';
import 'widgets/sleep_sound_hero_card.dart';
import 'widgets/sleep_sound_tile.dart';
import 'widgets/audio_category_chip.dart';
import 'widgets/sleep_player_minibar.dart';
import '../providers/audio_provider.dart';
import '../constants/sleep_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart'; // For sharedPreferencesProvider if needed, or import directly if it's there

// Temporary provider just for the prototype dashboard
final sleepRepositoryProvider = Provider<AudioRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AudioRepository(prefs);
});

class SleepSoundsDashboard extends ConsumerStatefulWidget {
  const SleepSoundsDashboard({super.key});

  @override
  ConsumerState<SleepSoundsDashboard> createState() => _SleepSoundsDashboardState();
}

class _SleepSoundsDashboardState extends ConsumerState<SleepSoundsDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  int _selectedCategoryIndex = 0;
  
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.public_rounded},
    {'name': 'Nature', 'icon': Icons.water_drop_rounded},
    {'name': 'Frequencies', 'icon': Icons.waves_rounded},
    {'name': 'Meditation', 'icon': Icons.self_improvement_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(sleepRepositoryProvider);
    final sounds = repository.getFeaturedSounds();
    
    // For prototype, we'll pick the first as featured and others as popular
    final featuredTrack = sounds.first;
    final popularTracks = sounds.sublist(1);

    return Scaffold(
      backgroundColor: SleepColors.midnightBlack,
      body: Stack(
        children: [
          // Background Environment
          NightSkyBackground(
            animationValue: _bgController.value,
            showMoon: true,
            child: const SizedBox.expand(),
          ),

          // Main Scroll View
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(top: 20, bottom: 120), // Bottom padding for minibar
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                
                // Hero Section
                SleepSoundHeroCard(
                  featuredSound: featuredTrack,
                  onPlay: () {
                    ref.read(audioPlayerProvider.notifier).playTrack(
                      featuredTrack.audioUrl,
                      featuredTrack.title,
                      'Atmosphere of the Day',
                      themeType: featuredTrack.themeType.name,
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Categories
                _buildCategories(),
                
                const SizedBox(height: 32),
                
                // Popular Sounds Row
                _buildSectionTitle('Popular Tonight'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: popularTracks.length,
                    itemBuilder: (context, index) {
                      final sound = popularTracks[index];
                      return SleepSoundTile(
                        sound: sound,
                        onTap: () {
                          ref.read(audioPlayerProvider.notifier).playTrack(
                            sound.audioUrl,
                            sound.title,
                            'Popular Tonight',
                            themeType: sound.themeType.name,
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),
                
                // Recently Played Row (Reusing logic for prototype)
                _buildSectionTitle('Your Resonance'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: popularTracks.reversed.length,
                    itemBuilder: (context, index) {
                      return SleepSoundTile(
                        sound: popularTracks.reversed.toList()[index],
                        onTap: () {},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Persistent Mini Player 
          const Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: SleepPlayerMiniBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good evening,',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              Text(
                'Time to unwind.',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.cloud_download_rounded, color: Colors.white70),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return AudioCategoryChip(
            title: cat['name'],
            icon: cat['icon'],
            isSelected: _selectedCategoryIndex == index,
            onTap: () => setState(() => _selectedCategoryIndex = index),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
