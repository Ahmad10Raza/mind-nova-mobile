import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../models/focus_model.dart';
import '../data/focus_service.dart';
import '../../audio/domain/audio_model.dart';
import '../../audio/providers/audio_player_provider.dart';
import '../../../core/network/api_client.dart';

final focusServiceProvider = Provider<FocusService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FocusService(apiClient);
});

class FocusState {
  final FocusSession? activeSession;
  final int remainingSeconds;
  final bool isRunning;
  final bool isPaused;
  final FocusStats? stats;
  final List<FocusSession> history;
   final bool isLoading;
  final int interruptions;
  final int deviceInterrupted;
  final AudioTrack? selectedTrack;

  FocusState({
    this.activeSession,
    this.remainingSeconds = 0,
    this.isRunning = false,
    this.isPaused = false,
    this.stats,
    this.history = const [],
    this.isLoading = false,
    this.interruptions = 0,
    this.deviceInterrupted = 0,
    this.selectedTrack,
  });

  FocusState copyWith({
    FocusSession? activeSession,
    int? remainingSeconds,
    bool? isRunning,
    bool? isPaused,
    FocusStats? stats,
    List<FocusSession>? history,
    bool? isLoading,
    int? interruptions,
    int? deviceInterrupted,
    AudioTrack? Function()? selectedTrack,
  }) {
    return FocusState(
      activeSession: activeSession ?? this.activeSession,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      stats: stats ?? this.stats,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      interruptions: interruptions ?? this.interruptions,
      deviceInterrupted: deviceInterrupted ?? this.deviceInterrupted,
      selectedTrack: selectedTrack != null ? selectedTrack() : this.selectedTrack,
    );
  }
}

class FocusNotifier extends Notifier<FocusState> with WidgetsBindingObserver {
  Timer? _timer;
  final _storage = const FlutterSecureStorage();

  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  
  @override
  FocusState build() {
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() => _init());
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _timer?.cancel();
    });
    _listenToBackgroundService();
    return FocusState();
  }

  void _listenToBackgroundService() {
    if (!_isMobile) return;
    
    FlutterBackgroundService().on('updateTimer').listen((event) {
      if (event != null && state.isRunning) {
        Future.microtask(() {
          state = state.copyWith(
            remainingSeconds: event['seconds'],
            isPaused: event['isPaused'],
          );
        });
      }
    });

    FlutterBackgroundService().on('timerFinished').listen((event) {
      if (state.isRunning) {
        Future.microtask(() => _onSessionComplete());
      }
    });
  }

  FocusService get _service => ref.read(focusServiceProvider);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (this.state.isRunning && !this.state.isPaused) {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        // App backgrounded
        this.state = this.state.copyWith(
          deviceInterrupted: this.state.deviceInterrupted + 1,
        );
        _saveLocalState();
      }
    }
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    await Future.wait([
      _loadStats(),
      _loadHistory(),
      _resumeSessionIfAny(),
    ]);
    state = state.copyWith(isLoading: false);
  }

  Future<void> _resumeSessionIfAny() async {
    final activeId = await _storage.read(key: 'focus_active_id');
    if (activeId != null) {
      final remaining = await _storage.read(key: 'focus_remaining');
      final lastSavedTime = await _storage.read(key: 'focus_save_time');
      
      if (remaining != null && lastSavedTime != null) {
        final lastSaved = DateTime.parse(lastSavedTime);
        final diff = DateTime.now().difference(lastSaved).inSeconds;
        final newRemaining = int.parse(remaining) - diff;

        if (newRemaining > 0) {
          // In a real scenario, we'd fetch the full session object or use cached one
          // For now, let's assume we can recover basic state
          state = state.copyWith(
            remainingSeconds: newRemaining,
            isRunning: true,
            isPaused: false,
          );
          _startTimer();
        } else {
          _clearLocalState();
        }
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _service.getStats();
      state = state.copyWith(stats: stats);
    } catch (e) {}
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _service.getHistory();
      state = state.copyWith(history: history);
    } catch (e) {}
  }

  Future<void> startSession({
    required FocusMode mode,
    required int durationMinutes,
    String? goal,
    String? moodBefore,
    AudioTrack? selectedTrack,
  }) async {
    state = state.copyWith(isLoading: true, selectedTrack: () => selectedTrack);
    try {
      final session = await _service.startSession(
        mode: mode,
        durationMinutes: durationMinutes,
        goal: goal,
        moodBefore: moodBefore,
        selectedAudio: selectedTrack?.id,
      );

      state = state.copyWith(
        activeSession: session,
        remainingSeconds: durationMinutes * 60,
        isRunning: true,
        isPaused: false,
        isLoading: false,
        interruptions: 0,
        deviceInterrupted: 0,
      );

      if (selectedTrack != null) {
        ref.read(audioPlayerProvider.notifier).play(selectedTrack);
      }

      if (_isMobile) {
        await FlutterBackgroundService().startService();
        FlutterBackgroundService().invoke('startTimer', {
          'seconds': durationMinutes * 60,
        });
      } else {
        _startTimer();
      }
      
      _saveLocalState();
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0 && !state.isPaused) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
        if (state.remainingSeconds % 5 == 0) _saveLocalState();
      } else if (state.remainingSeconds == 0) {
        _onSessionComplete();
      }
    });
  }

  void addInterruption() {
    state = state.copyWith(interruptions: state.interruptions + 1);
  }

  void pauseSession() {
    state = state.copyWith(isPaused: true);
    if (_isMobile) {
      FlutterBackgroundService().invoke('pauseTimer');
    }
    _saveLocalState();
  }

  void resumeSession() {
    state = state.copyWith(isPaused: false);
    if (_isMobile) {
      FlutterBackgroundService().invoke('resumeTimer');
    } else {
      _startTimer();
    }
    _saveLocalState();
  }

  void startRescueSprint() {
    state = state.copyWith(remainingSeconds: 180, isPaused: false);
    if (_isMobile) {
      // Re-start the background service timer with 180 seconds
      FlutterBackgroundService().invoke('startTimer', {
        'seconds': 180,
      });
    } else {
      _startTimer();
    }
    _saveLocalState();
  }

  Future<void> endSession({String? moodAfter}) async {
    if (state.activeSession == null) return;
    
    _timer?.cancel();
    final elapsed = (state.activeSession!.durationMinutes * 60) - state.remainingSeconds;
    final percent = (elapsed / (state.activeSession!.durationMinutes * 60)) * 100;
    
    final finalSession = FocusSession(
      id: state.activeSession!.id,
      mode: state.activeSession!.mode,
      durationMinutes: state.activeSession!.durationMinutes,
      actualDurationSec: elapsed,
      completedPercent: percent,
      interruptions: state.interruptions,
      deviceInterrupted: state.deviceInterrupted,
      moodAfter: moodAfter,
      startedAt: state.activeSession!.startedAt,
    );

    try {
      await _service.endSession(state.activeSession!.id, finalSession);
      _loadStats();
      _loadHistory();
    } catch (e) {}

    if (_isMobile) {
      FlutterBackgroundService().invoke('stopService');
    }
    _timer?.cancel();
    ref.read(audioPlayerProvider.notifier).stop();

    state = state.copyWith(
      activeSession: null,
      isRunning: false,
      remainingSeconds: 0,
      selectedTrack: () => null,
    );
    _clearLocalState();
  }

  void _onSessionComplete() {
    _timer?.cancel();
    _clearLocalState();
    endSession();
  }

  Future<void> _saveLocalState() async {
    if (state.activeSession != null) {
      await _storage.write(key: 'focus_active_id', value: state.activeSession!.id);
      await _storage.write(key: 'focus_remaining', value: state.remainingSeconds.toString());
      await _storage.write(key: 'focus_save_time', value: DateTime.now().toIso8601String());
    }
  }

  Future<void> _clearLocalState() async {
    await _storage.delete(key: 'focus_active_id');
    await _storage.delete(key: 'focus_remaining');
    await _storage.delete(key: 'focus_save_time');
  }
}

final focusProvider = NotifierProvider<FocusNotifier, FocusState>(FocusNotifier.new);
