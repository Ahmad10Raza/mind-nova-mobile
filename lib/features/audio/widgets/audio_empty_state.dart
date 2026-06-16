import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AudioEmptyType { favorites, history, localMusic, downloads, search, recommendations }

class AudioEmptyState extends StatelessWidget {
  final AudioEmptyType type;
  final String? searchQuery;
  final VoidCallback? onAction;

  const AudioEmptyState({
    super.key,
    required this.type,
    this.searchQuery,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final data = _getData();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(data.$1, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text(
              data.$2,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data.$3,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white38,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            if (data.$4 != null && onAction != null) ...[
              const SizedBox(height: 28),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(data.$4!, style: GoogleFonts.inter(color: const Color(0xFFD8B4FE), fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  (String, String, String, String?) _getData() => switch (type) {
    AudioEmptyType.favorites => (
      '💜',
      'No Saved Tracks Yet',
      'Tap the heart ♡ on any track to save it here for quick access.',
      null,
    ),
    AudioEmptyType.history => (
      '🌿',
      'No Plays Yet',
      'Start your first listening session and it will appear here.',
      'Explore Tracks',
    ),
    AudioEmptyType.localMusic => (
      '🎵',
      'No Audio Files Found',
      'We couldn\'t find any audio files on your device.\nTry adding some MP3 or M4A files.',
      null,
    ),
    AudioEmptyType.downloads => (
      '⬇️',
      'No Offline Tracks',
      'Download tracks to listen anytime,\neven without internet.',
      'Browse Tracks',
    ),
    AudioEmptyType.search => (
      '🔍',
      searchQuery != null && searchQuery!.isNotEmpty ? 'No results for "$searchQuery"' : 'Search Audio Tracks',
      searchQuery != null && searchQuery!.isNotEmpty
          ? 'Try a different keyword like "rain", "ocean", or "piano".'
          : 'Type to search across all categories.',
      null,
    ),
    AudioEmptyType.recommendations => (
      '✨',
      'Recommendations Coming Soon',
      'Log your mood or complete a session to get personalized audio suggestions.',
      'Log Mood',
    ),
  };
}
