import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../providers/audio_player_provider.dart';

class AudioMiniPlayer extends ConsumerWidget {
  const AudioMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only essential non-frequent updates for the outer shell
    final isVisible = ref.watch(audioPlayerProvider.select((s) => s.isMiniPlayerVisible));
    final track = ref.watch(audioPlayerProvider.select((s) => s.current));
    final isPlaying = ref.watch(audioPlayerProvider.select((s) => s.isPlaying));

    if (!isVisible || track == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => context.push('/audio/player'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A0A3A).withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bar at top - Isolated in its own Consumer to avoid full widget rebuilds
                  Consumer(
                    builder: (context, ref, _) {
                      final position = ref.watch(audioPlayerProvider.select((s) => s.position));
                      final duration = ref.watch(audioPlayerProvider.select((s) => s.duration));
                      final progress = duration.inSeconds > 0
                          ? position.inSeconds / duration.inSeconds
                          : 0.0;
                          
                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 2,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
                        ),
                      );
                    }
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        // Artwork
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              _categoryEmoji(track.category),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Title + mood benefit
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                track.moodBenefit ?? track.category.toLowerCase().replaceAll('_', ' '),
                                style: GoogleFonts.inter(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Controls
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Play/Pause
                            GestureDetector(
                              onTap: () {
                                final notifier = ref.read(audioPlayerProvider.notifier);
                                if (isPlaying) {
                                  notifier.pause();
                                } else {
                                  notifier.resume();
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF7C3AED).withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Close
                            GestureDetector(
                              onTap: () {
                                ref.read(audioPlayerProvider.notifier).stop();
                              },
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white38,
                                size: 22,
                               ),
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
        ),
      ),
    );
  }

  String _categoryEmoji(String category) => switch (category) {
    'RAIN' => '🌧️',
    'OCEAN' => '🌊',
    'FIREPLACE' => '🔥',
    'WHITE_NOISE' => '☁️',
    'BROWN_NOISE' => '🤎',
    'MEDITATION' => '🧘',
    'SLEEP_STORY' => '🌙',
    'FOCUS' => '🎯',
    'NATURE' => '🌿',
    'PIANO' => '🎹',
    'TIBETAN_BOWLS' => '🔔',
    'SPACE' => '🌌',
    'ANXIETY_RELIEF' => '💙',
    'DEEP_RELAXATION' => '✨',
    _ => '🎵',
  };
}
