import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class RecoveryAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  RecoveryAudioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> loadRecoveryTrack(String url, String title) async {
    final mediaItem = MediaItem(
      id: url,
      album: 'MindNova Recovery',
      title: title,
      artist: 'MindNova Guide',
    );
    this.mediaItem.add(mediaItem);
    await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
    _player.play(); // Auto-start playback
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  @override
  Future<void> onTaskRemoved() {
    stop();
    return super.onTaskRemoved();
  }
}

// Global Singleton definition
RecoveryAudioHandler? _recoveryAudioHandler;
RecoveryAudioHandler get recoveryAudioHandler {
  if (_recoveryAudioHandler == null) {
    _recoveryAudioHandler = RecoveryAudioHandler();
  }
  return _recoveryAudioHandler!;
}

set recoveryAudioHandler(RecoveryAudioHandler handler) => _recoveryAudioHandler = handler;
