import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/sleep_sound.dart';
import '../../constants/sleep_colors.dart';

class SleepSoundTile extends StatelessWidget {
  final SleepSound sound;
  final VoidCallback onTap;

  const SleepSoundTile({
    super.key,
    required this.sound,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork Container
            Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                color: SleepColors.darkPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                image: sound.artworkUrl != null
                    ? DecorationImage(
                        image: NetworkImage(sound.artworkUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  // Glassmorphism Overlay for empty artwork
                  if (sound.artworkUrl == null)
                    Center(
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  
                  // Category / Theme Icon
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForTheme(sound.themeType),
                        size: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),

                  // Favorite Button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 20,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),

                  // Mood Tag Pill
                  if (sound.moodTags.isNotEmpty)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              sound.moodTags.first,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              sound.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            // Duration & Status
            Text(
              '${(sound.durationSeconds / 60).round()} min · Ambient',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTheme(ThemeType type) {
    switch (type) {
      case ThemeType.rain: return Icons.water_drop_rounded;
      case ThemeType.space: return Icons.star_rounded;
      case ThemeType.fire: return Icons.local_fire_department_rounded;
      case ThemeType.none: return Icons.spa_rounded;
    }
  }
}
