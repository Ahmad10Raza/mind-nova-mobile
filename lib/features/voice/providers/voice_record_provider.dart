import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

enum RecordState { idle, recording, processing, error }

class VoiceRecordState {
  final RecordState state;
  final String? audioPath;
  final String? errorMessage;
  final Duration duration;

  VoiceRecordState({
    this.state = RecordState.idle,
    this.audioPath,
    this.errorMessage,
    this.duration = Duration.zero,
  });

  VoiceRecordState copyWith({
    RecordState? state,
    String? audioPath,
    String? errorMessage,
    Duration? duration,
  }) {
    return VoiceRecordState(
      state: state ?? this.state,
      audioPath: audioPath ?? this.audioPath,
      errorMessage: errorMessage ?? this.errorMessage,
      duration: duration ?? this.duration,
    );
  }
}

class VoiceRecordNotifier extends Notifier<VoiceRecordState> {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _timer;
  DateTime? _startTime;

  @override
  VoiceRecordState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _recorder.dispose();
    });
    return VoiceRecordState();
  }

  Future<void> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        String path = '';

        // On Web: pass empty path → record package auto-creates blob URL
        // On native: generate a real temp file path
        if (!kIsWeb) {
          try {
            final tempDir = await getTemporaryDirectory();
            final ts = DateTime.now().millisecondsSinceEpoch;
            path = '${tempDir.path}/voice_$ts.m4a';
          } catch (_) {
            // Fallback if getTemporaryDirectory fails (e.g. on Linux desktop)
            path = '/tmp/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
          }
        }

        // CRITICAL: Web browsers do NOT support AAC encoding.
        // Use opus (WebM) on Web, AAC on native.
        final config = RecordConfig(
          encoder: kIsWeb ? AudioEncoder.opus : AudioEncoder.aacLc,
          bitRate: 128000,
        );

        await _recorder.start(config, path: path);

        _startTime = DateTime.now();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          state = state.copyWith(
            duration: DateTime.now().difference(_startTime!),
          );
        });

        state = state.copyWith(state: RecordState.recording, errorMessage: null);
      } else {
        state = state.copyWith(
          state: RecordState.error,
          errorMessage: 'Microphone permission denied.',
        );
      }
    } catch (e) {
      debugPrint('VoiceRecordNotifier: startRecording error: $e');
      state = state.copyWith(
        state: RecordState.error,
        errorMessage: 'Failed to start recording: $e',
      );
    }
  }

  Future<String?> stopRecording() async {
    _timer?.cancel();
    try {
      final path = await _recorder.stop();
      debugPrint('VoiceRecordNotifier: stopRecording path: $path');
      if (path != null) {
        state = state.copyWith(
          state: RecordState.idle,
          audioPath: path,
          duration: Duration.zero,
        );
        return path;
      }
    } catch (e) {
      debugPrint('VoiceRecordNotifier: stopRecording error: $e');
      state = state.copyWith(
        state: RecordState.error,
        errorMessage: 'Failed to stop recording: $e',
      );
    }
    return null;
  }

  void reset() {
    state = VoiceRecordState();
  }
}

final voiceRecordProvider = NotifierProvider<VoiceRecordNotifier, VoiceRecordState>(() {
  return VoiceRecordNotifier();
});
