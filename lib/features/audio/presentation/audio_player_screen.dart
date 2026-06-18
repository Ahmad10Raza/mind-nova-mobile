import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../domain/audio_model.dart';
import '../providers/audio_player_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/sleep_timer_bottom_sheet.dart';
import '../widgets/ambient_mix_bottom_sheet.dart';

class AudioPlayerScreen extends ConsumerStatefulWidget {
  final AudioTrack? initialTrack;
  const AudioPlayerScreen({super.key, this.initialTrack});

  @override
  ConsumerState<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends ConsumerState<AudioPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _artworkController;
  double _selectedSpeed = 1.0;
  final List<double> _speeds = [0.75, 1.0, 1.25, 1.5];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _artworkController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final track = widget.initialTrack;
      if (track != null) {
        final playerState = ref.read(audioPlayerProvider);
        if (playerState.current?.id != track.id) {
          ref.read(audioPlayerProvider.notifier).play(track);
        }
        if (track.category != 'LOCAL') {
          // Mark as played in backend
          ref.read(audioDataServiceProvider).markPlayed(track.id);
        }
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    _artworkController.dispose();
    
    // Stop audio when the user closes the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) return;
      try {
        ref.read(audioPlayerProvider.notifier).pause();
      } catch (e) {
        // Provider might already be disposed
      }
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(audioPlayerProvider);
    final track = playerState.current ?? widget.initialTrack;

    if (track == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF050B18),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎵', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text('No track selected', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 18)),
              const SizedBox(height: 20),
              TextButton(onPressed: () => context.pop(), child: const Text('Go Back')),
            ],
          ),
        ),
      );
    }

    final accentColor = _categoryColor(track.category);
    final progress = playerState.duration.inSeconds > 0
        ? (playerState.position.inSeconds / playerState.duration.inSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _glowController,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                accentColor.withValues(alpha: 0.12 + _glowController.value * 0.04),
                const Color(0xFF050B18),
                const Color(0xFF020509),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Background particles
              ..._buildParticles(accentColor),

              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // ─── Top Bar ───────────────────────────────────────────
                          _buildTopBar(track, playerState),
                          
                          // ─── Artwork ──────────────────────────────────────────
                          _buildArtwork(track, accentColor, playerState.isPlaying),
                          
                          // ─── Track Info ───────────────────────────────────────
                          _buildTrackInfo(track, playerState),
                          
                          // ─── Progress Bar ─────────────────────────────────────
                          _buildProgressBar(playerState, progress),
                          
                          // ─── Playback Controls ────────────────────────────────
                          _buildPlaybackControls(playerState, accentColor),
                          
                          // ─── Secondary Controls ───────────────────────────────
                          _buildSecondaryControls(track, playerState, accentColor),
                          
                          // ─── Speed Selector ───────────────────────────────────
                          _buildSpeedSelector(),
                          
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Top Bar ─────────────────────────────────────────────────────────────

  Widget _buildTopBar(AudioTrack track, AudioPlayerState ps) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          'Hide',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 1)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text('Now Playing', style: GoogleFonts.inter(color: Colors.white38, fontSize: 11, letterSpacing: 1.5)),
                Text(track.category.toLowerCase().replaceAll('_', ' '), style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showQueue(ps),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.queue_music_rounded, color: Colors.white70, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Artwork ──────────────────────────────────────────────────────────────

  Widget _buildArtwork(AudioTrack track, Color accentColor, bool isPlaying) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (_, __) => Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: isPlaying ? 280 : 240,
              height: isPlaying ? 280 : 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15 + _glowController.value * 0.1),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            // Spinning ring (slow rotation while playing)
            if (isPlaying)
              RotationTransition(
                turns: _artworkController,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    gradient: SweepGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.0),
                        accentColor.withValues(alpha: 0.2),
                        accentColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            // Artwork circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: isPlaying ? 220 : 190,
              height: isPlaying ? 220 : 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.4),
                    accentColor.withValues(alpha: 0.15),
                    const Color(0xFF0F0A24),
                  ],
                ),
                border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.25),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _categoryEmoji(track.category),
                  style: TextStyle(fontSize: isPlaying ? 72 : 60),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Track Info ───────────────────────────────────────────────────────────

  Widget _buildTrackInfo(AudioTrack track, AudioPlayerState ps) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (track.moodBenefit != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _categoryColor(track.category).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      track.moodBenefit!,
                      style: GoogleFonts.inter(
                        color: _categoryColor(track.category),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Favorite button
          GestureDetector(
            onTap: () => ref.read(audioDataServiceProvider).toggleFavorite(track.id),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.favorite_border_rounded, color: Colors.white60, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Progress Bar ─────────────────────────────────────────────────────────

  Widget _buildProgressBar(AudioPlayerState ps, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              activeTrackColor: const Color(0xFF7C3AED),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF7C3AED).withValues(alpha: 0.2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: progress,
              onChanged: (v) {
                final seekTo = Duration(seconds: (v * ps.duration.inSeconds).round());
                ref.read(audioPlayerProvider.notifier).seekTo(seekTo);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(ps.position), style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
                if (ps.sleepTimerEnd != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bedtime_rounded, color: Color(0xFFD8B4FE), size: 10),
                        const SizedBox(width: 4),
                        Text(
                          () {
                            final diff = ps.sleepTimerEnd!.difference(DateTime.now());
                            if (diff.inMinutes > 0) return '${diff.inMinutes}m';
                            final sec = diff.inSeconds;
                            return '${sec > 0 ? sec : 0}s';
                          }(),
                          style: GoogleFonts.inter(
                            color: const Color(0xFFD8B4FE),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(_formatDuration(ps.duration), style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Playback Controls ────────────────────────────────────────────────────

  Widget _buildPlaybackControls(AudioPlayerState ps, Color accentColor) {
    final notifier = ref.read(audioPlayerProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Shuffle
          GestureDetector(
            onTap: notifier.toggleShuffle,
            child: Icon(
              Icons.shuffle_rounded,
              color: ps.queue.shuffle ? const Color(0xFF7C3AED) : Colors.white30,
              size: 22,
            ),
          ),
          // Skip Previous
          GestureDetector(
            onTap: notifier.skipPrevious,
            child: const Icon(Icons.skip_previous_rounded, color: Colors.white70, size: 36),
          ),
          // Play / Pause
          GestureDetector(
            onTap: () => ps.isPlaying ? notifier.pause() : notifier.resume(),
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, __) => Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentColor,
                      accentColor.withValues(alpha: 0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.5 + _glowController.value * 0.2),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ps.isBuffering
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Icon(
                        ps.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
              ),
            ),
          ),
          // Skip Next
          GestureDetector(
            onTap: notifier.skipNext,
            child: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 36),
          ),
          // Repeat
          GestureDetector(
            onTap: () {
              final next = switch (ps.repeatMode) {
                AudioRepeatMode.none => AudioRepeatMode.all,
                AudioRepeatMode.all => AudioRepeatMode.one,
                AudioRepeatMode.one => AudioRepeatMode.none,
                _ => AudioRepeatMode.none,
              };
              notifier.setRepeatMode(next);
            },
            child: Stack(
              children: [
                Icon(
                  ps.repeatMode == AudioRepeatMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded,
                  color: ps.repeatMode != AudioRepeatMode.none ? const Color(0xFF7C3AED) : Colors.white30,
                  size: 22,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Secondary Controls ───────────────────────────────────────────────────

  Widget _buildSecondaryControls(AudioTrack track, AudioPlayerState ps, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildControlBtn(
            icon: Icons.bedtime_rounded,
            label: 'Sleep',
            isActive: ps.sleepTimerEnd != null,
            onTap: () => SleepTimerBottomSheet.show(context),
          ),
          _buildControlBtn(
            icon: Icons.layers_rounded,
            label: 'Ambient',
            isActive: ps.ambientEnabled,
            onTap: () => AmbientMixBottomSheet.show(context),
          ),
          _buildControlBtn(
            icon: Icons.download_rounded,
            label: 'Save',
            isActive: false,
            onTap: () => _downloadTrack(track),
          ),
          _buildControlBtn(
            icon: Icons.share_rounded,
            label: 'Share',
            isActive: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF7C3AED).withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? const Color(0xFF7C3AED).withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(icon, color: isActive ? const Color(0xFFD8B4FE) : Colors.white38, size: 20),
          ),
          const SizedBox(height: 5),
          Text(label, style: GoogleFonts.inter(color: Colors.white30, fontSize: 10)),
        ],
      ),
    );
  }

  // ─── Speed Selector ───────────────────────────────────────────────────────

  Widget _buildSpeedSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _speeds.map((speed) {
          final isSelected = _selectedSpeed == speed;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedSpeed = speed);
              ref.read(audioPlayerProvider.notifier).setSpeed(speed);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF7C3AED).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF7C3AED).withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.07),
                ),
              ),
              child: Text(
                '${speed}×',
                style: GoogleFonts.inter(
                  color: isSelected ? const Color(0xFFD8B4FE) : Colors.white30,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Floating Particles ───────────────────────────────────────────────────

  List<Widget> _buildParticles(Color accentColor) {
    final rng = Random(7);
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    return List.generate(10, (i) {
      final t = (_particleController.value + i * 0.1) % 1.0;
      final x = rng.nextDouble() * w;
      final baseY = rng.nextDouble() * h;
      final floatY = baseY + sin(t * 2 * pi) * 20;
      final size = rng.nextDouble() * 5 + 1.5;
      return Positioned(
        left: x,
        top: floatY,
        child: AnimatedBuilder(
          animation: _particleController,
          builder: (_, __) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.2 * (1 - t * 0.6)),
            ),
          ),
        ),
      );
    });
  }

  // ─── Queue Sheet ─────────────────────────────────────────────────────────

  void _showQueue(AudioPlayerState ps) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0A24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        final queue = ps.queue.tracks;
        if (queue.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: Text('Queue is empty', style: TextStyle(color: Colors.white54))),
          );
        }
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Queue', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: queue.length,
                itemBuilder: (_, i) {
                  final isActive = i == ps.queue.currentIndex;
                  return ListTile(
                    leading: Text(_categoryEmoji(queue[i].category), style: const TextStyle(fontSize: 22)),
                    title: Text(queue[i].title, style: GoogleFonts.inter(
                      color: isActive ? const Color(0xFFD8B4FE) : Colors.white,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    )),
                    trailing: isActive ? const Icon(Icons.equalizer_rounded, color: Color(0xFF7C3AED)) : null,
                    onTap: () {
                      ref.read(audioPlayerProvider.notifier).setQueue(queue, startIndex: i);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _downloadTrack(AudioTrack track) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${track.title}…'),
        backgroundColor: const Color(0xFF7C3AED),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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

  Color _categoryColor(String category) => switch (category) {
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
