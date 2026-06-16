import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../domain/audio_model.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class AudioPlayerState {
  final AudioTrack? current;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final bool isMiniPlayerVisible;

  // Queue support
  final AudioQueue queue;
  final AudioRepeatMode repeatMode;

  // Ambient mixing
  final AudioTrack? ambientTrack;
  final double primaryVolume;
  final double ambientVolume;
  final bool ambientEnabled;

  // Sleep timer
  final double? sleepTimerMinutes;
  final DateTime? sleepTimerEnd;

  // Download state
  final Map<String, double> downloadProgress; // trackId → 0.0–1.0
  final Set<String> downloadingIds;

  const AudioPlayerState({
    this.current,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isMiniPlayerVisible = false,
    this.queue = const AudioQueue(),
    this.repeatMode = AudioRepeatMode.none,
    this.ambientTrack,
    this.primaryVolume = 1.0,
    this.ambientVolume = 0.4,
    this.ambientEnabled = false,
    this.sleepTimerMinutes,
    this.sleepTimerEnd,
    this.downloadProgress = const {},
    this.downloadingIds = const {},
  });

  AudioPlayerState copyWith({
    AudioTrack? current,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    bool? isMiniPlayerVisible,
    AudioQueue? queue,
    AudioRepeatMode? repeatMode,
    AudioTrack? Function()? ambientTrack,
    double? primaryVolume,
    double? ambientVolume,
    bool? ambientEnabled,
    double? Function()? sleepTimerMinutes,
    DateTime? Function()? sleepTimerEnd,
    Map<String, double>? downloadProgress,
    Set<String>? downloadingIds,
  }) {
    return AudioPlayerState(
      current: current ?? this.current,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isMiniPlayerVisible: isMiniPlayerVisible ?? this.isMiniPlayerVisible,
      queue: queue ?? this.queue,
      repeatMode: repeatMode ?? this.repeatMode,
      ambientTrack: ambientTrack != null ? ambientTrack() : this.ambientTrack,
      primaryVolume: primaryVolume ?? this.primaryVolume,
      ambientVolume: ambientVolume ?? this.ambientVolume,
      ambientEnabled: ambientEnabled ?? this.ambientEnabled,
      sleepTimerMinutes: sleepTimerMinutes != null ? sleepTimerMinutes() : this.sleepTimerMinutes,
      sleepTimerEnd: sleepTimerEnd != null ? sleepTimerEnd() : this.sleepTimerEnd,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadingIds: downloadingIds ?? this.downloadingIds,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AudioPlayerNotifier extends Notifier<AudioPlayerState> {
  AudioPlayer? _primary;
  AudioPlayer? _ambient;

  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _bufferingSub;
  StreamSubscription? _processingStateSub;
  Timer? _sleepTimer;

  @override
  AudioPlayerState build() {
    try {
      _primary = AudioPlayer();
      _ambient = AudioPlayer();
      _initListeners();
    } catch (e) {
      print("🚨 Audio Player Initialization Failed: $e");
      // On some platforms (like Linux without libmpv), AudioPlayer() can throw.
      // We catch it so the provider doesn't enter an error state.
    }

    ref.onDispose(() {
      _positionSub?.cancel();
      _durationSub?.cancel();
      _playingSub?.cancel();
      _bufferingSub?.cancel();
      _processingStateSub?.cancel();
      _sleepTimer?.cancel();
      _primary?.dispose();
      _ambient?.dispose();
    });
    return const AudioPlayerState();
  }

  void _initListeners() {
    final player = _primary;
    if (player == null) return;

    _positionSub = player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
      // Check sleep timer
      if (state.sleepTimerEnd != null && DateTime.now().isAfter(state.sleepTimerEnd!)) {
        pause();
        cancelSleepTimer();
      }
    });

    _durationSub = player.durationStream.listen((dur) {
      if (dur != null) state = state.copyWith(duration: dur);
    });

    _playingSub = player.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    _bufferingSub = player.bufferedPositionStream.listen((_) {});

    _processingStateSub = player.processingStateStream.listen((ps) {
      if (ps == ProcessingState.loading || ps == ProcessingState.buffering) {
        state = state.copyWith(isBuffering: true);
      } else {
        state = state.copyWith(isBuffering: false);
        // Auto-play next when track ends
        if (ps == ProcessingState.completed) {
          _handleTrackEnd();
        }
      }
    });
  }

  void _handleTrackEnd() {
    final q = state.queue;
    if (q.tracks.isEmpty) return;

    if (state.repeatMode == AudioRepeatMode.one) {
      seekTo(Duration.zero);
      _primary?.play();
      return;
    }

    final nextIndex = q.shuffle
        ? (q.tracks.length * (DateTime.now().millisecondsSinceEpoch % 1000) ~/ 1000).clamp(0, q.tracks.length - 1)
        : q.currentIndex + 1;

    if (nextIndex < q.tracks.length) {
      final newQueue = q.copyWith(currentIndex: nextIndex);
      state = state.copyWith(queue: newQueue);
      play(q.tracks[nextIndex]);
    } else if (state.repeatMode == AudioRepeatMode.all) {
      final newQueue = q.copyWith(currentIndex: 0);
      state = state.copyWith(queue: newQueue);
      play(q.tracks[0]);
    }
  }

  // ─── Playback Controls ──────────────────────────────────────────────────────

  Future<void> play(AudioTrack track) async {
    try {
      state = state.copyWith(
        current: track,
        isPlaying: true, // Optimistic update
        isBuffering: true,
        isMiniPlayerVisible: true,
        position: Duration.zero,
      );
      await _primary?.setUrl(track.audioUrl);
      await _primary?.setVolume(state.primaryVolume);
      _primary?.play(); // Don't await, it completes when playback finishes
    } catch (e) {
      state = state.copyWith(isBuffering: false, isPlaying: false);
    }
  }

  Future<void> pause() async {
    state = state.copyWith(isPlaying: false);
    await _primary?.pause();
    await _ambient?.pause();
  }

  Future<void> resume() async {
    state = state.copyWith(isPlaying: true);
    _primary?.play();
  }

  Future<void> stop() async {
    await _primary?.stop();
    await _ambient?.stop();
    state = state.copyWith(
      isPlaying: false,
      isMiniPlayerVisible: false,
      current: null,
      ambientTrack: () => null,
      ambientEnabled: false,
    );
  }

  Future<void> seekTo(Duration pos) async {
    await _primary?.seek(pos);
    state = state.copyWith(position: pos);
  }

  void skipNext() {
    final q = state.queue;
    if (q.tracks.isEmpty || q.currentIndex >= q.tracks.length - 1) return;
    final nextIndex = q.currentIndex + 1;
    state = state.copyWith(queue: q.copyWith(currentIndex: nextIndex));
    play(q.tracks[nextIndex]);
  }

  void skipPrevious() {
    final q = state.queue;
    if (q.tracks.isEmpty) return;
    if (state.position.inSeconds > 3) {
      seekTo(Duration.zero);
      return;
    }
    final prevIndex = (q.currentIndex - 1).clamp(0, q.tracks.length - 1);
    state = state.copyWith(queue: q.copyWith(currentIndex: prevIndex));
    play(q.tracks[prevIndex]);
  }

  void setRepeatMode(AudioRepeatMode mode) {
    state = state.copyWith(repeatMode: mode);
  }

  void toggleShuffle() {
    final newQueue = state.queue.copyWith(shuffle: !state.queue.shuffle);
    state = state.copyWith(queue: newQueue);
  }

  // ─── Queue Management ───────────────────────────────────────────────────────

  void setQueue(List<AudioTrack> tracks, {int startIndex = 0}) {
    state = state.copyWith(
      queue: AudioQueue(tracks: tracks, currentIndex: startIndex),
    );
    if (tracks.isNotEmpty) play(tracks[startIndex]);
  }

  void addToQueue(AudioTrack track) {
    final updated = [...state.queue.tracks, track];
    state = state.copyWith(queue: state.queue.copyWith(tracks: updated));
  }

  // ─── Ambient Mix ────────────────────────────────────────────────────────────

  Future<void> setAmbientTrack(AudioTrack? track) async {
    if (track == null) {
      await _ambient?.stop();
      state = state.copyWith(ambientTrack: () => null, ambientEnabled: false);
      return;
    }
    await _ambient?.setUrl(track.audioUrl);
    await _ambient?.setVolume(state.ambientVolume);
    await _ambient?.setLoopMode(LoopMode.one);
    if (state.isPlaying) await _ambient?.play();
    state = state.copyWith(ambientTrack: () => track, ambientEnabled: true);
  }

  Future<void> setPrimaryVolume(double vol) async {
    await _primary?.setVolume(vol.clamp(0.0, 1.0));
    state = state.copyWith(primaryVolume: vol.clamp(0.0, 1.0));
  }

  Future<void> setAmbientVolume(double vol) async {
    await _ambient?.setVolume(vol.clamp(0.0, 1.0));
    state = state.copyWith(ambientVolume: vol.clamp(0.0, 1.0));
  }

  void toggleAmbient() {
    if (state.ambientEnabled) {
      _ambient?.pause();
      state = state.copyWith(ambientEnabled: false);
    } else if (state.ambientTrack != null) {
      _ambient?.play();
      state = state.copyWith(ambientEnabled: true);
    }
  }

  // ─── Sleep Timer ────────────────────────────────────────────────────────────

  void setSleepTimer(double minutes) {
    _sleepTimer?.cancel();
    final end = DateTime.now().add(Duration(minutes: minutes.round()));
    state = state.copyWith(
      sleepTimerMinutes: () => minutes,
      sleepTimerEnd: () => end,
    );
    _sleepTimer = Timer(Duration(minutes: minutes.round()), () {
      pause();
      cancelSleepTimer();
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    state = state.copyWith(
      sleepTimerMinutes: () => null,
      sleepTimerEnd: () => null,
    );
  }

  // ─── Playback Speed ─────────────────────────────────────────────────────────

  Future<void> setSpeed(double speed) async {
    await _primary?.setSpeed(speed);
  }

  // ─── Download Progress Simulation ───────────────────────────────────────────

  void updateDownloadProgress(String trackId, double progress) {
    final updated = Map<String, double>.from(state.downloadProgress);
    updated[trackId] = progress;
    final downloading = Set<String>.from(state.downloadingIds);
    if (progress >= 1.0) {
      downloading.remove(trackId);
    } else {
      downloading.add(trackId);
    }
    state = state.copyWith(downloadProgress: updated, downloadingIds: downloading);
  }

  void hideMiniPlayer() {
    state = state.copyWith(isMiniPlayerVisible: false);
  }

  void showMiniPlayer() {
    if (state.current != null) {
      state = state.copyWith(isMiniPlayerVisible: true);
    }
  }

}

// ─── Global Provider ─────────────────────────────────────────────────────────

final audioPlayerProvider = NotifierProvider<AudioPlayerNotifier, AudioPlayerState>(
  () => AudioPlayerNotifier(),
);
