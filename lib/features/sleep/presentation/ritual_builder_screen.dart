import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../providers/ritual_provider.dart';
import '../constants/sleep_colors.dart';
import 'widgets/night_sky_background.dart';
import '../models/audio_category.dart';

class RitualBuilderScreen extends ConsumerStatefulWidget {
  const RitualBuilderScreen({super.key});

  @override
  ConsumerState<RitualBuilderScreen> createState() => _RitualBuilderScreenState();
}

class _RitualBuilderScreenState extends ConsumerState<RitualBuilderScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

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
    final ritual = ref.watch(ritualProvider);

    return Scaffold(
      backgroundColor: SleepColors.midnightBlack,
      body: Stack(
        children: [
          NightSkyBackground(
            animationValue: _bgController.value,
            showMoon: false,
            child: const SizedBox.expand(),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                
                Expanded(
                  child: ritual.isEmpty
                      ? _buildEmptyState()
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          itemCount: ritual.length,
                          onReorder: (oldIndex, newIndex) {
                            ref.read(ritualProvider.notifier).reorder(oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final item = ritual[index];
                            return _buildRitualStep(item, index);
                          },
                        ),
                ),
                
                _buildLibrarySection(),
                
                _buildFooter(context, ritual),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            onPressed: () => context.pop(),
          ),
          Text(
            'Customize Ritual',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => ref.read(ritualProvider.notifier).reset(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_rounded, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          Text(
            'Your ritual is empty',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Add steps from the library below',
            style: GoogleFonts.inter(color: Colors.white30, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRitualStep(PlaylistItem item, int index) {
    final icon = _getIconForType(item.interstitialType ?? (item.isAudioTrack ? 'audio' : 'unknown'));

    return Container(
      key: ValueKey(item.id),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator_rounded, color: Colors.white24),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SleepColors.darkPurple.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: SleepColors.lavenderGlow, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  item.isAudioTrack ? 'Sleep Atmosphere' : 'Wellness Exercise',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () => ref.read(ritualProvider.notifier).removeStep(item.id),
          ),
        ],
      ),
    );
  }

  Widget _buildLibrarySection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Activity Library',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildLibraryItem('breathing_timer', 'Breathing', Icons.air_rounded),
                _buildLibraryItem('journal_prompt', 'Journaling', Icons.edit_note_rounded),
                _buildLibraryItem('audio', 'Sleep Sounds', Icons.music_note_rounded),
                _buildLibraryItem('meditation', 'Meditation', Icons.self_improvement_rounded),
                _buildLibraryItem('story', 'Sleep Story', Icons.auto_stories_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryItem(String type, String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        ref.read(ritualProvider.notifier).addStep(
          type, 
          title: label,
          isAudio: type == 'audio'
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Icon(icon, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, List<dynamic> ritual) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Duration',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
                ),
                Text(
                  '${ritual.length * 5} minutes',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: SleepColors.moonGold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: ritual.isEmpty ? null : () {
              context.push('/sleep/routine');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SleepColors.moonGold,
              foregroundColor: SleepColors.deepNavy,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              'Start Ritual',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitleForType(String type) {
    switch (type) {
      case 'breathing_timer': return 'Moon Breathing';
      case 'journal_prompt': return 'Grateful Journal';
      case 'audio': return 'Atmospheric Sound';
      case 'meditation': return 'Guided Meditation';
      case 'story': return 'Sleep Story';
      default: return 'Night Exercise';
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'breathing_timer': return Icons.air_rounded;
      case 'journal_prompt': return Icons.edit_note_rounded;
      case 'audio': return Icons.music_note_rounded;
      case 'meditation': return Icons.self_improvement_rounded;
      case 'story': return Icons.auto_stories_rounded;
      default: return Icons.bedtime_rounded;
    }
  }
}
