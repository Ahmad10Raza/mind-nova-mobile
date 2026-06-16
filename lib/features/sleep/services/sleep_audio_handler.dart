import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

class SleepAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  Timer? _sleepTimer;
  Timer? _fadeTimer;
  double _currentVolume = 1.0;

  SleepAudioHandler() {
    _initPlayer();
  }

  void _initPlayer() {
    // Forward state updates to audio_service System UI
    _player.onPlayerStateChanged.listen((state) {
      final isPlaying = state == PlayerState.playing;
      playbackState.add(playbackState.value.copyWith(
        playing: isPlaying,
        controls: [
          MediaControl.skipToPrevious,
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        processingState: const {
          PlayerState.playing: AudioProcessingState.ready,
          PlayerState.paused: AudioProcessingState.ready,
          PlayerState.stopped: AudioProcessingState.idle,
          PlayerState.completed: AudioProcessingState.completed,
          PlayerState.disposed: AudioProcessingState.idle,
        }[state]!,
      ));
    });

    _player.onPositionChanged.listen((pos) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: pos,
      ));
    });

    _player.onDurationChanged.listen((duration) {
      if (mediaItem.value != null && duration.inMilliseconds > 0) {
        mediaItem.add(mediaItem.value!.copyWith(duration: duration));
      }
    });
  }

  @override
  Future<void> play() async {
    // Implement Safe Volume Fade-in logic
    _currentVolume = 0.1;
    await _player.setVolume(_currentVolume);
    await _player.resume();

    // Fade in over 3 seconds
    int steps = 10;
    int msDelay = 300;
    double volStep = 0.9 / steps;
    Timer.periodic(Duration(milliseconds: msDelay), (timer) {
      _currentVolume += volStep;
      if (_currentVolume >= 1.0) {
        _currentVolume = 1.0;
        _player.setVolume(_currentVolume);
        timer.cancel();
      } else {
        _player.setVolume(_currentVolume);
      }
    });
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    _cancelTimers();
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  // Custom Method to load specific MindNova tracks
  Future<void> loadNewTrack(String url, String title, String category, {String? artworkUrl, String? themeType}) async {
    mediaItem.add(MediaItem(
      id: url,
      title: title,
      album: category,
      artist: 'MindNova Sleep Mode',
      artUri: artworkUrl != null ? Uri.parse(artworkUrl) : null,
      extras: {
        'themeType': themeType,
      },
    ));

    await _player.setReleaseMode(ReleaseMode.loop); // Sleep mode loops by default
    await _player.play(AssetSource(url.replaceFirst('assets/', '')));
  }

  Future<void> loadRecoveryTrack(String url, String title) async {
    mediaItem.add(MediaItem(
      id: url,
      title: title,
      album: 'MindNova Recovery',
      artist: 'MindNova Guide',
    ));

    await _player.setReleaseMode(ReleaseMode.stop); // Recovery doesn't loop
    if (url.startsWith('http')) {
      await _player.play(UrlSource(url));
    } else {
      await _player.play(AssetSource(url.replaceFirst('assets/', '')));
    }
  }

  // Sleep Timer Fade Out Hook
  void setSleepTimer(Duration duration) {
    _cancelTimers();
    if (duration.inSeconds == 0) return;

    _sleepTimer = Timer(duration, () => _startFadeOut(60)); // 60 sec fade out
  }

  void _startFadeOut(int seconds) {
    if (_player.state != PlayerState.playing) return;
    
    int steps = seconds * 2;
    int msDelay = 500;
    double volStep = _currentVolume / steps;

    _fadeTimer = Timer.periodic(Duration(milliseconds: msDelay), (timer) {
      _currentVolume -= volStep;
      if (_currentVolume <= 0.0) {
        _currentVolume = 0.0;
        _player.setVolume(0.0);
        timer.cancel();
        stop(); // Terminate gracefully
      } else {
        _player.setVolume(_currentVolume);
      }
    });
  }

  void _cancelTimers() {
    _sleepTimer?.cancel();
    _fadeTimer?.cancel();
  }
}

// Global Singleton definition - made nullable to avoid LateInitializationError
SleepAudioHandler? _audioHandler;
SleepAudioHandler get audioHandler {
  if (_audioHandler == null) {
    throw StateError('AudioHandler not initialized. Ensure AudioService.init was called.');
  }
  return _audioHandler!;
}

set audioHandler(SleepAudioHandler handler) => _audioHandler = handler;
