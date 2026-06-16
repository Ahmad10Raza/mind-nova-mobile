import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/audio_model.dart';
import '../providers/audio_provider.dart';
import '../providers/audio_player_provider.dart';

class AmbientMixBottomSheet extends ConsumerStatefulWidget {
  const AmbientMixBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AmbientMixBottomSheet(),
    );
  }

  @override
  ConsumerState<AmbientMixBottomSheet> createState() => _AmbientMixBottomSheetState();
}

class _AmbientMixBottomSheetState extends ConsumerState<AmbientMixBottomSheet> {
  // Ambient-suitable categories
  static const _ambientCategories = ['RAIN', 'OCEAN', 'FIREPLACE', 'WHITE_NOISE', 'BROWN_NOISE', 'NATURE', 'SPACE'];

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(audioPlayerProvider);
    final notifier = ref.read(audioPlayerProvider.notifier);
    final tracksAsync = ref.watch(audioTracksProvider(null));

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F0A24),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Text('🎚️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Text(
                    'Ambient Mix',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Layer a soft ambient sound beneath your primary track.',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 12, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            // Volume sliders (always visible)
            _buildVolumeSection(playerState, notifier),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withValues(alpha: 0.07)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Row(
                children: [
                  Text('Choose Ambient Track', style: GoogleFonts.inter(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            // Ambient track list
            Expanded(
              child: tracksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
                error: (_, __) => const SizedBox.shrink(),
                data: (tracks) {
                  final ambientTracks = tracks.where((t) => _ambientCategories.contains(t.category)).toList();
                  return ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: ambientTracks.length,
                    itemBuilder: (_, i) {
                      final track = ambientTracks[i];
                      final isSelected = playerState.ambientTrack?.id == track.id;
                      return GestureDetector(
                        onTap: () async {
                          if (isSelected) {
                            await notifier.setAmbientTrack(null);
                          } else {
                            await notifier.setAmbientTrack(track);
                          }
                          setState(() {});
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF7C3AED).withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF7C3AED).withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.07),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(_emoji(track.category), style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      track.title,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      track.moodBenefit ?? '',
                                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF7C3AED), size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeSection(AudioPlayerState ps, AudioPlayerNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSliderRow(
            label: 'Primary',
            emoji: '🎵',
            value: ps.primaryVolume,
            onChanged: (v) => notifier.setPrimaryVolume(v),
          ),
          const SizedBox(height: 8),
          _buildSliderRow(
            label: 'Ambient',
            emoji: '🌊',
            value: ps.ambientVolume,
            onChanged: ps.ambientTrack != null ? (v) => notifier.setAmbientVolume(v) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required String emoji,
    required double value,
    required ValueChanged<double>? onChanged,
  }) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              activeTrackColor: const Color(0xFF7C3AED),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF7C3AED).withValues(alpha: 0.15),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '${(value * 100).round()}%',
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _emoji(String category) => switch (category) {
    'RAIN' => '🌧️',
    'OCEAN' => '🌊',
    'FIREPLACE' => '🔥',
    'WHITE_NOISE' => '☁️',
    'BROWN_NOISE' => '🤎',
    'NATURE' => '🌿',
    'SPACE' => '🌌',
    _ => '🎵',
  };
}
