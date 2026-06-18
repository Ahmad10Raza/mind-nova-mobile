import 'dart:async' show Timer;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../domain/meditation_model.dart';

import 'providers/meditation_provider.dart';

class MeditationPlayerScreen extends ConsumerStatefulWidget {
  final MeditationContent? content;
  const MeditationPlayerScreen({super.key, this.content});

  @override
  ConsumerState<MeditationPlayerScreen> createState() => _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState extends ConsumerState<MeditationPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _particleController;
  late AnimationController _colorController;
  late AnimationController _completionController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  bool _showCompletion = false;
  int _secondsElapsed = 0;
  Timer? _sessionTimer;
  double _sliderValue = 0.0;
  double _calmBefore = 5;
  double _calmAfter = 5;
  bool _showCalmRating = true;
  bool _calmRated = false;
  int _breathPhase = 0;
  Timer? _breathTimer;

  final List<String> _phases = ['Inhale', 'Hold', 'Exhale', 'Relax'];
  final List<int> _phaseDurations = [4, 4, 6, 2]; // seconds
  final List<Color> _categoryColors = [
    const Color(0xFF4F46E5),
    const Color(0xFF7C3AED),
    const Color(0xFF1E40AF),
    const Color(0xFF0E7490),
  ];

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _breathTimer = null;
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _startBreathCycle() {
    _breathingController.forward(from: 0);
    _breathTimer = Timer.periodic(
      Duration(seconds: _phaseDurations[_breathPhase]),
      (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() {
          _breathPhase = (_breathPhase + 1) % 4;
        });
        _breathingController.forward(from: 0);
      },
    );
  }

  void _togglePlayback() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _breathingController.repeat(reverse: true);
      _startBreathCycle();
      
      final audioUrl = widget.content?.audioUrl;
      if (audioUrl != null && audioUrl.isNotEmpty) {
        if (audioUrl.startsWith('http')) {
          _audioPlayer.play(UrlSource(audioUrl));
        } else {
          _audioPlayer.play(AssetSource(audioUrl));
        }
      } else {
        _audioPlayer.play(AssetSource('audio/space_ambience.mp3'));
      }

      // Start the session elapsed timer
      _sessionTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() {
          _secondsElapsed++;
          final totalSecs = (widget.content?.durationMinutes ?? 10) * 60;
          _sliderValue = (_secondsElapsed / totalSecs).clamp(0.0, 1.0);
          // Auto-complete when done
          if (_secondsElapsed >= totalSecs) {
            t.cancel();
            _sessionTimer = null;
            _isPlaying = false;
            _breathingController.stop();
            _breathTimer?.cancel();
            _audioPlayer.stop();
            _showCompletion = true;
          }
        });
      });
    } else {
      _breathingController.stop();
      _breathTimer?.cancel();
      _sessionTimer?.cancel();
      _sessionTimer = null;
      _audioPlayer.pause();
    }
  }

  void _seek(int offsetSeconds) async {
    final totalSecs = (widget.content?.durationMinutes ?? 10) * 60;
    final newElapsed = (_secondsElapsed + offsetSeconds).clamp(0, totalSecs);
    setState(() {
      _secondsElapsed = newElapsed;
      _sliderValue = (_secondsElapsed / totalSecs).clamp(0.0, 1.0);
    });

    try {
      await _audioPlayer.seek(Duration(seconds: newElapsed));
    } catch (_) {
      // Ignore if seeking fails (e.g. on short looped ambience tracks)
    }

    if (_secondsElapsed >= totalSecs && !_showCompletion) {
      _sessionTimer?.cancel();
      _sessionTimer = null;
      setState(() {
        _isPlaying = false;
        _showCompletion = true;
      });
      _breathingController.stop();
      _breathTimer?.cancel();
      _audioPlayer.stop();
    }
  }

  String get _currentPhaseLabel => _phases[_breathPhase];
  Color get _currentPhaseColor {
    switch (_breathPhase) {
      case 0: return const Color(0xFF86EFAC); // Inhale - green
      case 1: return const Color(0xFFFBBF24); // Hold - yellow
      case 2: return const Color(0xFF93C5FD); // Exhale - blue
      case 3: return const Color(0xFFD8B4FE); // Relax - purple
      default: return Colors.white;
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _particleController.dispose();
    _colorController.dispose();
    _completionController.dispose();
    _breathTimer?.cancel();
    _sessionTimer?.cancel();
    
    // Explicitly stop the player before disposing to prevent ghost audio
    // on certain platforms (like web) when the screen is closed
    _audioPlayer.stop().then((_) {
      _audioPlayer.dispose();
    }).catchError((_) {
      _audioPlayer.dispose();
    });
    
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.content?.title ?? 'Calm the Overthinking Mind';
    final category = widget.content?.category ?? 'Anxiety Relief';
    final duration = widget.content?.durationMinutes ?? 10;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          // Full screen animated background
          _buildBackground(),

          // Floating ambient particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              painter: _PlayerParticlePainter(_particleController.value),
              child: const SizedBox.expand(),
            ),
          ),

          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final artworkSize = (h * 0.25).clamp(90.0, 160.0);
                return Column(
                  children: [
                    _buildHeader(context),
                    const Spacer(flex: 1),
                    Expanded(
                      flex: 8,
                      child: _buildArtworkSized(artworkSize),
                    ),
                    const Spacer(flex: 1),
                    _buildTrackInfo(title, category),
                    if (_isPlaying) _buildBreathingGuide(),
                    const Spacer(flex: 4),
                    _buildProgressBar(duration),
                    const SizedBox(height: 16),
                    _buildControls(),
                    const SizedBox(height: 16),
                    _buildSecondaryControls(),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),

          // Calm before rating
          if (_showCalmRating && !_calmRated)
            _buildCalmRatingOverlay(context),

          // Completion overlay
          if (_showCompletion)
            _buildCompletionOverlay(context),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _colorController,
      builder: (_, __) {
        final t = _colorController.value;
        final color1 = Color.lerp(const Color(0xFF0d0730), const Color(0xFF050B18), math.sin(t * math.pi))!;
        final color2 = Color.lerp(const Color(0xFF0a1628), const Color(0xFF0d0730), math.cos(t * math.pi))!;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color1, color2, const Color(0xFF020617)],
              stops: const [0, 0.5, 1],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 22),
            ),
          ),
          Column(
            children: [
              Text('NOW PLAYING', style: GoogleFonts.inter(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              Text('Meditation Session', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          GestureDetector(
            onTap: () {
              _sessionTimer?.cancel();
              _sessionTimer = null;
              setState(() {
                _isPlaying = false;
                _showCompletion = true;
              });
              _breathingController.stop();
              _breathTimer?.cancel();
              _audioPlayer.stop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Text(
                'End',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Keep old _buildArtwork for any callers
  Widget _buildArtwork() => _buildArtworkSized(110);

  Widget _buildArtworkSized(double baseSize) {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (_, __) {
        final scale = 1.0 + (_isPlaying ? _breathingController.value * 0.12 : 0);
        final iconSize = (baseSize * 0.4).clamp(24.0, 48.0);
        return SizedBox(
          width: baseSize * 2.5,
          height: baseSize * 2.5,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Outer glow rings
                ...List.generate(4, (i) {
                  final ringScale = 1.0 + (i * 0.22) + (_isPlaying ? _breathingController.value * 0.08 * (i + 1) : 0);
                  return Container(
                    width: baseSize * ringScale,
                    height: baseSize * ringScale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF7C3AED).withOpacity(0.06 - i * 0.012),
                        width: 1,
                      ),
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF7C3AED).withOpacity(0.02 - i * 0.003),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                }),
                // Core orb
                Transform.scale(
                  scale: scale,
                  child: Container(
                    width: baseSize,
                    height: baseSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _isPlaying ? _currentPhaseColor.withOpacity(0.7) : const Color(0xFF7C3AED).withOpacity(0.6),
                          const Color(0xFF4F46E5).withOpacity(0.4),
                          const Color(0xFF1E3A8A).withOpacity(0.2),
                        ],
                        stops: const [0, 0.6, 1],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isPlaying ? _currentPhaseColor : const Color(0xFF7C3AED)).withOpacity(0.5),
                          blurRadius: 40 + (_isPlaying ? _breathingController.value * 20 : 0),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.self_improvement_rounded,
                        color: Colors.white.withOpacity(0.8),
                        size: iconSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreathingGuide() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(_breathPhase),
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _currentPhaseColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _currentPhaseColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPhaseColor,
                boxShadow: [BoxShadow(color: _currentPhaseColor.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _currentPhaseLabel,
              style: GoogleFonts.outfit(
                color: _currentPhaseColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_phaseDurations[_breathPhase]}s',
              style: GoogleFonts.inter(color: _currentPhaseColor.withOpacity(0.7), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackInfo(String title, String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, height: 1.2),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
            ),
            child: Text(
              category.replaceAll('_', ' '),
              style: GoogleFonts.inter(color: const Color(0xFFD8B4FE), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int duration) {
    final totalSecs = duration * 60;
    final remaining = totalSecs - _secondsElapsed;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: const Color(0xFF7C3AED),
              inactiveTrackColor: Colors.white.withOpacity(0.12),
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF7C3AED).withOpacity(0.2),
            ),
            child: Slider(
              value: _sliderValue,
              onChanged: (v) {
                final totalSecs = (widget.content?.durationMinutes ?? 10) * 60;
                final targetSeconds = (v * totalSecs).toInt();
                _seek(targetSeconds - _secondsElapsed);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(_secondsElapsed),
                  style: GoogleFonts.inter(
                    color: _isPlaying ? const Color(0xFFD8B4FE) : Colors.white38,
                    fontSize: 11,
                    fontWeight: _isPlaying ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (_isPlaying)
                  Text(
                    '-${_formatTime(remaining.clamp(0, totalSecs))}',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                  ),
                Text(
                  _formatTime(totalSecs),
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10_rounded, color: Colors.white60, size: 32),
          onPressed: () => _seek(-10),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: _togglePlayback,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.5),
                  blurRadius: _isPlaying ? 30 : 16,
                  spreadRadius: _isPlaying ? 4 : 0,
                ),
              ],
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
        const SizedBox(width: 24),
        IconButton(
          icon: const Icon(Icons.forward_10_rounded, color: Colors.white60, size: 32),
          onPressed: () => _seek(10),
        ),
      ],
    );
  }

  Widget _buildSecondaryControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSecondaryBtn(Icons.waves_rounded, 'Ambience'),
          _buildSecondaryBtn(Icons.timer_rounded, 'Timer'),
          _buildSecondaryBtn(Icons.record_voice_over_rounded, 'Voice'),
          _buildSecondaryBtn(Icons.subtitles_rounded, 'Guide'),
        ],
      ),
    );
  }

  Widget _buildSecondaryBtn(IconData icon, String label) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: Colors.white54, size: 18),
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildCalmRatingOverlay(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1a1060), Color(0xFF0d0730)]),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🌙', style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 16),
                Text('How calm do you feel right now?', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text('We\'ll measure your improvement after the session.', style: GoogleFonts.inter(color: Colors.white54, fontSize: 13), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                SliderTheme(
                  data: SliderThemeData(
                    thumbColor: const Color(0xFF7C3AED),
                    activeTrackColor: const Color(0xFF7C3AED),
                    inactiveTrackColor: Colors.white.withOpacity(0.15),
                    overlayColor: const Color(0xFF7C3AED).withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _calmBefore,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _calmBefore.toInt().toString(),
                    onChanged: (v) => setState(() => _calmBefore = v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Very stressed', style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
                    Text('${_calmBefore.toInt()}/10', style: GoogleFonts.outfit(color: const Color(0xFFD8B4FE), fontSize: 20, fontWeight: FontWeight.w800)),
                    Text('Perfectly calm', style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() { _calmRated = true; _togglePlayback(); }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: Text('Begin Meditation', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1a1060), Color(0xFF0d0730)]),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text('Session Complete', style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Beautiful. You showed up for yourself today.', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14), textAlign: TextAlign.center),
              const SizedBox(height: 28),
              Text('How calm do you feel now?', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderThemeData(
                  thumbColor: const Color(0xFF86EFAC),
                  activeTrackColor: const Color(0xFF86EFAC),
                  inactiveTrackColor: Colors.white.withOpacity(0.15),
                ),
                child: Slider(
                  value: _calmAfter,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _calmAfter.toInt().toString(),
                  onChanged: (v) => setState(() => _calmAfter = v),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF86EFAC).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF86EFAC).withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [
                      Text('Before', style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
                      Text('${_calmBefore.toInt()}/10', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.w700)),
                    ]),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white24, size: 20),
                    Column(children: [
                      Text('After', style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
                      Text('${_calmAfter.toInt()}/10', style: GoogleFonts.outfit(color: const Color(0xFF86EFAC), fontSize: 18, fontWeight: FontWeight.w700)),
                    ]),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF86EFAC).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '+${(_calmAfter - _calmBefore).clamp(0, 10).toInt()} lift',
                        style: GoogleFonts.outfit(color: const Color(0xFF86EFAC), fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final targetContentId = widget.content?.id ?? "3ce3fb43-b56b-4389-819f-6579cffb71cf"; // Fallback to Panic Reset Protocol id
                    
                    await ref.read(meditationServiceProvider).completeSession(
                      contentId: targetContentId,
                      durationSecs: _secondsElapsed,
                      calmBefore: _calmBefore.toInt(),
                      calmAfter: _calmAfter.toInt(),
                    );
                    // Invalidate providers to force Dashboard history refresh
                    ref.invalidate(recentSessionsProvider);
                    ref.invalidate(meditationDashboardProvider);
                    if (mounted) context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: Text('Save & Return', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Particles painter for the player
class _PlayerParticlePainter extends CustomPainter {
  final double progress;
  _PlayerParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    for (int i = 0; i < 28; i++) {
      final angle = (progress * 2 * math.pi * 0.3) + (i * math.pi * 2 / 28);
      final radius = 60 + rng.nextDouble() * (size.width * 0.45);
      final x = size.width / 2 + math.cos(angle + i * 0.8) * radius;
      final y = size.height * 0.38 + math.sin(angle * 0.5 + i * 0.4) * 90;
      final opacity = 0.03 + rng.nextDouble() * 0.06;
      final particlePaint = Paint()
        ..color = Color.lerp(const Color(0xFF7C3AED), const Color(0xFF4F46E5), rng.nextDouble())!.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 1.5 + rng.nextDouble() * 2.5, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
