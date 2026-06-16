import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/breathing_model.dart';

class BreathingState {
  final BreathingTechnique? technique;
  final BreathingPhase currentPhase;
  final int secondsRemaining;
  final bool isActive;
  final int totalCycles;

  BreathingState({
    this.technique,
    this.currentPhase = BreathingPhase.inhale,
    this.secondsRemaining = 0,
    this.isActive = false,
    this.totalCycles = 0,
  });

  BreathingState copyWith({
    BreathingTechnique? technique,
    BreathingPhase? currentPhase,
    int? secondsRemaining,
    bool? isActive,
    int? totalCycles,
  }) {
    return BreathingState(
      technique: technique ?? this.technique,
      currentPhase: currentPhase ?? this.currentPhase,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isActive: isActive ?? this.isActive,
      totalCycles: totalCycles ?? this.totalCycles,
    );
  }
}

class BreathingNotifier extends Notifier<BreathingState> {
  Timer? _timer;

  @override
  BreathingState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return BreathingState();
  }

  void startSession(BreathingTechnique technique) {
    _timer?.cancel();
    state = state.copyWith(
      technique: technique,
      currentPhase: BreathingPhase.inhale,
      secondsRemaining: technique.inhale,
      isActive: true,
      totalCycles: 0,
    );
    _startTimer();
  }

  void stopSession() {
    _timer?.cancel();
    state = state.copyWith(isActive: false);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining > 1) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        _moveToNextPhase();
      }
    });
  }

  void _moveToNextPhase() {
    final t = state.technique;
    if (t == null) return;
    
    switch (state.currentPhase) {
      case BreathingPhase.inhale:
        if (t.holdIn > 0) {
          state = state.copyWith(currentPhase: BreathingPhase.holdIn, secondsRemaining: t.holdIn);
        } else {
          state = state.copyWith(currentPhase: BreathingPhase.exhale, secondsRemaining: t.exhale);
        }
        break;
      case BreathingPhase.holdIn:
        state = state.copyWith(currentPhase: BreathingPhase.exhale, secondsRemaining: t.exhale);
        break;
      case BreathingPhase.exhale:
        if (t.holdOut > 0) {
          state = state.copyWith(currentPhase: BreathingPhase.holdOut, secondsRemaining: t.holdOut);
        } else {
          _finishCycleOrContinue(t);
        }
        break;
      case BreathingPhase.holdOut:
        _finishCycleOrContinue(t);
        break;
    }
  }

  void _finishCycleOrContinue(BreathingTechnique t) {
    final newCycles = state.totalCycles + 1;
    if (t.targetCycles != null && newCycles >= t.targetCycles!) {
      state = state.copyWith(totalCycles: newCycles, isActive: false);
      _timer?.cancel();
    } else {
      state = state.copyWith(
        currentPhase: BreathingPhase.inhale, 
        secondsRemaining: t.inhale,
        totalCycles: newCycles,
      );
    }
  }
}

final breathingProvider = NotifierProvider<BreathingNotifier, BreathingState>(BreathingNotifier.new);
