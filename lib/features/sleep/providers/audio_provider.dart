import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../services/sleep_audio_handler.dart';

// Provides the singleton audio handler initialization status
final audioHandlerProvider = Provider<SleepAudioHandler?>((ref) {
  try {
    return audioHandler;
  } catch (_) {
    return null;
  }
});

// A robust Notifier mapping the Audio Handler's state
class AudioPlayerNotifier extends Notifier<PlaybackState> {
  @override
  PlaybackState build() {
    final handler = ref.watch(audioHandlerProvider);
    if (handler == null) return PlaybackState();

    // Instead of listening here, we could use a StreamProvider, 
    // but for compatibility with existing code we'll use a listener
    // that doesn't trigger state changes DURING build.
    Future.microtask(() {
      handler.playbackState.listen((state) {
        if (ref.mounted) {
          this.state = state;
        }
      });
    });

    return handler.playbackState.value;
  }

  Future<void> playTrack(String url, String title, String category, {String? themeType}) async {
    final handler = ref.read(audioHandlerProvider);
    if (handler != null) {
      await handler.loadNewTrack(url, title, category, themeType: themeType);
    }
  }

  void pause() => ref.read(audioHandlerProvider)?.pause();
  void play() => ref.read(audioHandlerProvider)?.play();
  void stop() => ref.read(audioHandlerProvider)?.stop();
  void seek(Duration pos) => ref.read(audioHandlerProvider)?.seek(pos);
  
  void setSleepTimer(Duration duration) => ref.read(audioHandlerProvider)?.setSleepTimer(duration);
}

final audioPlayerProvider = NotifierProvider<AudioPlayerNotifier, PlaybackState>(() {
  return AudioPlayerNotifier();
});

// A provider purely to observe position streams
final audioPositionProvider = StreamProvider<Duration>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  if (handler == null) return const Stream.empty();
  return AudioService.position;
});
