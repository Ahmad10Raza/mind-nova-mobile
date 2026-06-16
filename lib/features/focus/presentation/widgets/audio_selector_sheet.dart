import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_nova_mobile/features/audio/providers/audio_provider.dart';
import 'package:mind_nova_mobile/features/audio/domain/audio_model.dart';
import 'package:mind_nova_mobile/core/constants/app_colors.dart';

class AudioSelectorSheet extends ConsumerStatefulWidget {
  final AudioTrack? initialTrack;
  const AudioSelectorSheet({super.key, this.initialTrack});

  @override
  ConsumerState<AudioSelectorSheet> createState() => _AudioSelectorSheetState();
}

class _AudioSelectorSheetState extends ConsumerState<AudioSelectorSheet> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(audioCategoriesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CHOOSE AMBIENCE',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                if (_selectedCategoryId != null)
                  TextButton(
                    onPressed: () => setState(() => _selectedCategoryId = null),
                    child: Text('BACK', style: TextStyle(color: AppColors.primaryPurpleLight)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _selectedCategoryId == null 
                ? _buildCategoryGrid(categoriesAsync)
                : _buildTrackList(_selectedCategoryId!),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(AsyncValue<List<AudioCategoryMeta>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) => GridView.builder(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryId = cat.id),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse(cat.gradientStart.replaceAll('#', '0xFF'))),
                    Color(int.parse(cat.gradientEnd.replaceAll('#', '0xFF'))),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Text(cat.emoji, style: const TextStyle(fontSize: 60, color: Colors.white10)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          cat.label,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading categories', style: TextStyle(color: Colors.white70))),
    );
  }

  Widget _buildTrackList(String categoryId) {
    final tracksAsync = ref.watch(audioTracksProvider(categoryId));

    return tracksAsync.when(
      data: (tracks) => ListView.builder(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 100),
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          final isSelected = widget.initialTrack?.id == track.id;
          return ListTile(
            onTap: () => Navigator.pop(context, track),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.music_note_rounded, color: Colors.white38),
            ),
            title: Text(
              track.title,
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
            subtitle: Text(track.durationLabel, style: const TextStyle(color: Colors.white38)),
            trailing: isSelected 
                ? Icon(Icons.check_circle_rounded, color: AppColors.primaryPurpleLight)
                : const Icon(Icons.add_circle_outline_rounded, color: Colors.white10),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading tracks', style: TextStyle(color: Colors.white70))),
    );
  }
}
