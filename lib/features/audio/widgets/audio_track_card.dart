import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/audio_model.dart';
import '../providers/audio_player_provider.dart';

class AudioTrackCard extends ConsumerWidget {
  final AudioTrack track;
  final bool isCompact;
  final bool showRecommendationReason;
  final bool? isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onDownload;

  const AudioTrackCard({
    super.key,
    required this.track,
    this.isCompact = false,
    this.showRecommendationReason = false,
    this.isFavorite,
    this.onTap,
    this.onFavorite,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioPlayerProvider);
    final isCurrentTrack = playerState.current?.id == track.id;
    final isPlaying = isCurrentTrack && playerState.isPlaying;

    final categoryColors = _categoryColor();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(isCompact ? 12 : 14),
        decoration: BoxDecoration(
          color: isCurrentTrack
              ? categoryColors.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCurrentTrack
                ? categoryColors.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.07),
            width: isCurrentTrack ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Artwork / placeholder
            Container(
              width: isCompact ? 44 : 56,
              height: isCompact ? 44 : 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [categoryColors.withValues(alpha: 0.7), categoryColors.withValues(alpha: 0.3)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (track.artworkUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        track.artworkUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Text(_categoryEmoji(), style: TextStyle(fontSize: isCompact ? 18 : 22)),
                      ),
                    )
                  else
                    Text(_categoryEmoji(), style: TextStyle(fontSize: isCompact ? 18 : 22)),
                  if (isCurrentTrack)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: isCompact ? 18 : 22,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: isCompact ? 12 : 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (track.moodBenefit != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColors.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            track.moodBenefit!,
                            style: GoogleFonts.inter(
                              color: categoryColors,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Icon(Icons.timer_rounded, color: Colors.white30, size: 10),
                      const SizedBox(width: 2),
                      Text(
                        track.durationLabel,
                        style: GoogleFonts.inter(color: Colors.white30, fontSize: 10),
                      ),
                    ],
                  ),
                  if (showRecommendationReason && track.recommendationReason != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      track.recommendationReason!,
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Action buttons
            if (!isCompact)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onFavorite != null)
                    GestureDetector(
                      onTap: onFavorite,
                      child: Icon(
                        isFavorite == true ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFavorite == true ? const Color(0xFFEC4899) : Colors.white30,
                        size: 18,
                      ),
                    ),
                  const SizedBox(width: 10),
                  if (onDownload != null)
                    GestureDetector(
                      onTap: onDownload,
                      child: const Icon(Icons.download_rounded, color: Colors.white30, size: 18),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _categoryEmoji() => switch (track.category) {
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

  Color _categoryColor() => switch (track.category) {
    'RAIN' => const Color(0xFF3B82F6),
    'OCEAN' => const Color(0xFF0EA5E9),
    'FIREPLACE' => const Color(0xFFF97316),
    'WHITE_NOISE' => const Color(0xFF94A3B8),
    'BROWN_NOISE' => const Color(0xFFA16207),
    'MEDITATION' => const Color(0xFF7C3AED),
    'SLEEP_STORY' => const Color(0xFF6366F1),
    'FOCUS' => const Color(0xFF10B981),
    'NATURE' => const Color(0xFF22C55E),
    'PIANO' => const Color(0xFF64748B),
    'TIBETAN_BOWLS' => const Color(0xFFF59E0B),
    'SPACE' => const Color(0xFF8B5CF6),
    'ANXIETY_RELIEF' => const Color(0xFF0EA5E9),
    'DEEP_RELAXATION' => const Color(0xFFA855F7),
    _ => const Color(0xFF7C3AED),
  };
}
