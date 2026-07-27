import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../data/voice_service.dart';
import 'voice_record_provider.dart';

enum VoiceMode { journal, mood, therapist, nova, gratitude, community }

class VoiceOrchestratorState {
  final bool isProcessing;
  final String? transcript;
  final String? errorMessage;
  final VoiceEntryResult? result;

  VoiceOrchestratorState({
    this.isProcessing = false,
    this.transcript,
    this.errorMessage,
    this.result,
  });

  VoiceOrchestratorState copyWith({
    bool? isProcessing,
    String? transcript,
    String? errorMessage,
    VoiceEntryResult? result,
  }) {
    return VoiceOrchestratorState(
      isProcessing: isProcessing ?? this.isProcessing,
      transcript: transcript ?? this.transcript,
      errorMessage: errorMessage ?? this.errorMessage,
      result: result ?? this.result,
    );
  }
}

class VoiceOrchestratorNotifier extends Notifier<VoiceOrchestratorState> {
  @override
  VoiceOrchestratorState build() {
    return VoiceOrchestratorState();
  }

  Future<void> processRecording({
    required String audioPath,
    required VoiceMode mode,
    String? appointmentId,
    String? therapistId,
  }) async {
    state = state.copyWith(isProcessing: true, errorMessage: null, transcript: null);
    
    try {
      final voiceService = ref.read(voiceServiceProvider);
      final featureType = mode.toString().split('.').last.toUpperCase();
      
      // 1. Upload and Transcribe
      final result = await voiceService.transcribeAudio(
        filePath: audioPath,
        featureType: featureType,
        keepRecording: true,
      );

      // 2. Process based on Mode
      if (mode == VoiceMode.mood) {
        await voiceService.analyzeEmotion(result.voiceEntryId);
        await voiceService.createMoodFromVoice(result.voiceEntryId);
      } else if (mode == VoiceMode.therapist) {
        if (appointmentId != null && therapistId != null) {
          await voiceService.generateTherapistNotesFromVoice(
            appointmentId, 
            result.voiceEntryId, 
            therapistId,
          );
        } else {
          throw Exception("Missing appointmentId or therapistId for therapist mode");
        }
      }

      state = state.copyWith(
        isProcessing: false,
        transcript: result.transcript,
        result: result,
      );
    } catch (e) {
      debugPrint("VoiceOrchestrator error: $e");
      state = state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = VoiceOrchestratorState();
    ref.read(voiceRecordProvider.notifier).reset();
  }
}

final voiceOrchestratorProvider = NotifierProvider<VoiceOrchestratorNotifier, VoiceOrchestratorState>(() {
  return VoiceOrchestratorNotifier();
});
