import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audio_service/audio_service.dart';
import '../../constants/sleep_colors.dart';
import '../../providers/audio_provider.dart';
import '../widgets/full_audio_player_sheet.dart';
import '../../services/sleep_audio_handler.dart';

class SleepPlayerMiniBar extends ConsumerWidget {
  const SleepPlayerMiniBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(audioPlayerProvider);
    final handler = ref.watch(audioHandlerProvider);
    final isPlaying = playbackState.playing;

    if (handler == null) return const SizedBox.shrink();

    return StreamBuilder<MediaItem?>(
      stream: handler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const FullAudioPlayerSheet(),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: SleepColors.darkPurple.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: SleepColors.indigo.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Row(
                  children: [
                    // Tiny Artwork
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: SleepColors.indigo,
                        borderRadius: BorderRadius.circular(12),
                        image: mediaItem.artUri != null
                            ? DecorationImage(
                                image: NetworkImage(mediaItem.artUri.toString()),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: mediaItem.artUri == null
                          ? const Icon(Icons.music_note_rounded, color: Colors.white54, size: 20)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    
                    // Titles
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mediaItem.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            mediaItem.album ?? 'MindNova Sleep',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Controls
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          ref.read(audioPlayerProvider.notifier).pause();
                        } else {
                          ref.read(audioPlayerProvider.notifier).play();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 24,
                      ),
                      onPressed: () {
                        ref.read(audioPlayerProvider.notifier).stop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
