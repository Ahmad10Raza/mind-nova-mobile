import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ai_prediction_service.dart';

class AiPredictionState {
  final bool isLoading;
  final Map<String, dynamic>? lastResult;
  final String? error;

  AiPredictionState({
    this.isLoading = false,
    this.lastResult,
    this.error,
  });

  AiPredictionState copyWith({
    bool? isLoading,
    Map<String, dynamic>? lastResult,
    String? error,
  }) {
    return AiPredictionState(
      isLoading: isLoading ?? this.isLoading,
      lastResult: lastResult ?? this.lastResult,
      error: error,
    );
  }
}

class AiPredictionNotifier extends Notifier<AiPredictionState> {
  @override
  AiPredictionState build() => AiPredictionState();

  AiPredictionService get _service => ref.read(aiPredictionServiceProvider);

  Future<void> predict(String type, Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, error: null, lastResult: null);

    try {
      final result = await _service.predictModel(type, payload);
      print('🌐 [AiPredictionProvider] Prediction Success: ${result['predictionType']} - Score: ${result['score']}');
      print('🌐 [AiPredictionProvider] AI Available: ${result['aiAvailable']}');
      
      state = state.copyWith(
        isLoading: false, 
        lastResult: result,
      );
    } catch (e) {
      print('❌ [AiPredictionProvider] Prediction Failed: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = AiPredictionState();
}

final aiPredictionProvider = NotifierProvider<AiPredictionNotifier, AiPredictionState>(AiPredictionNotifier.new);
