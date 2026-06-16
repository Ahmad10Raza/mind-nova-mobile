import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audio_service/audio_service.dart';
import '../../providers/audio_provider.dart';
import '../../constants/sleep_colors.dart';
import '../../models/sleep_sound.dart';
import 'dynamic_atmosphere_background.dart';
import '../../services/sleep_audio_handler.dart';

class FullAudioPlayerSheet extends ConsumerStatefulWidget {
  const FullAudioPlayerSheet({super.key});

  @override
  ConsumerState<FullAudioPlayerSheet> createState() => _FullAudioPlayerSheetState();
}

class _FullAudioPlayerSheetState extends ConsumerState<FullAudioPlayerSheet> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(audioPlayerProvider);
    final handler = ref.watch(audioHandlerProvider);
    final isPlaying = playbackState.playing;
    
    if (handler == null) {
      return const Scaffold(body: Center(child: Text('Audio service unavailable')));
    }
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Inherits from bottom sheet
      body: StreamBuilder<MediaItem?>(
        stream: handler.mediaItem,
        builder: (context, snapshot) {
          final mediaItem = snapshot.data;
          if (mediaItem == null) return const Center(child: CircularProgressIndicator());

          final themeStr = mediaItem.extras?['themeType'] as String?;
          final theme = ThemeType.values.firstWhere(
            (e) => e.name == themeStr,
            orElse: () => ThemeType.none,
          );

          return Stack(
            children: [
              // Dynamic Blur Atmosphere
              DynamicAtmosphereBackground(
                animationValue: _bgController.value,
                theme: theme,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                  child: Container(
                    color: SleepColors.midnightBlack.withValues(alpha: 0.6),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            'NOW PLAYING',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                              letterSpacing: 2,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cloud_download_outlined, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Big Artwork
                    Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: SleepColors.indigo.withValues(alpha: 0.3),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                        image: mediaItem.artUri != null
                            ? DecorationImage(
                                image: NetworkImage(mediaItem.artUri.toString()),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Titles & Favorite
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mediaItem.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  mediaItem.album ?? 'Atmosphere',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 32),
                            onPressed: () {},
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Scrub Bar
                    StreamBuilder<Duration>(
                      stream: AudioService.position,
                      builder: (context, posSnapshot) {
                        final position = posSnapshot.data ?? Duration.zero;
                        final duration = mediaItem.duration ?? Duration.zero;
                        final max =  (duration.inMilliseconds > 0) ? duration.inMilliseconds.toDouble() : 1.0;
                        final val = position.inMilliseconds.toDouble().clamp(0.0, max);

                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 6,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                activeTrackColor: SleepColors.moonGold,
                                inactiveTrackColor: Colors.white12,
                                thumbColor: SleepColors.moonGold,
                              ),
                              child: Slider(
                                value: val,
                                max: max,
                                onChanged: (value) {
                                  ref.read(audioPlayerProvider.notifier).seek(Duration(milliseconds: value.toInt()));
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(position), style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                                  Text(_formatDuration(duration), style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    ),

                    const SizedBox(height: 16),

                    // Transport Controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(icon: const Icon(Icons.shuffle_rounded, color: Colors.white54), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 40), onPressed: () {}),
                          GestureDetector(
                            onTap: () {
                              if (isPlaying) {
                                ref.read(audioPlayerProvider.notifier).pause();
                              } else {
                                ref.read(audioPlayerProvider.notifier).play();
                              }
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: SleepColors.moonGold,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: SleepColors.moonGold.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  )
                                ],
                              ),
                              child: Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: SleepColors.deepNavy,
                                size: 48,
                              ),
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 40), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.timer_outlined, color: Colors.white54), onPressed: () {}),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
