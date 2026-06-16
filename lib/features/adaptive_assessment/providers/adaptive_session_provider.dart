import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/adaptive_node_model.dart';
import '../../auth/providers/auth_provider.dart';

class AdaptiveSessionState {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? sessionId;
  final AdaptiveNodeModel? currentNode;
  final double progress;
  final bool isCompleted;
  final bool crisisModeTriggered;

  AdaptiveSessionState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.sessionId,
    this.currentNode,
    this.progress = 0.0,
    this.isCompleted = false,
    this.crisisModeTriggered = false,
  });

  AdaptiveSessionState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? sessionId,
    AdaptiveNodeModel? currentNode,
    double? progress,
    bool? isCompleted,
    bool? crisisModeTriggered,
  }) {
    return AdaptiveSessionState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      sessionId: sessionId ?? this.sessionId,
      currentNode: currentNode ?? this.currentNode,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      crisisModeTriggered: crisisModeTriggered ?? this.crisisModeTriggered,
    );
  }
}

class AdaptiveSessionNotifier extends Notifier<AdaptiveSessionState> {
  @override
  AdaptiveSessionState build() {
    return AdaptiveSessionState();
  }

  Future<void> startSession(String treeId, {String mode = 'STANDARD'}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        '/adaptive/start',
        data: {'treeId': treeId, 'mode': mode},
      );

      final nextQ = AdaptiveNodeModel.fromJson(response.data['nextQuestion']);
      
      state = state.copyWith(
        isLoading: false,
        sessionId: response.data['sessionId'],
        currentNode: nextQ,
        progress: response.data['progress']?.toDouble() ?? 0.0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  dynamic lastResponseData;

  Future<void> submitAnswer(double score, {String? textValue}) async {
    if (state.sessionId == null || state.currentNode == null) return;
    
    // Check local crisis flag before submitting
    if (state.currentNode!.crisisFlag && score > 2) {
       state = state.copyWith(crisisModeTriggered: true);
    }

    state = state.copyWith(isSubmitting: true, error: null);
    
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.patch(
        '/adaptive/answer',
        data: {
          'sessionId': state.sessionId,
          'questionId': state.currentNode!.questionId,
          'score': score,
          'textValue': textValue,
        },
      );

      lastResponseData = response.data;

      if (response.data['completed'] == true) {
        state = state.copyWith(isSubmitting: false, isCompleted: true);
      } else {
        final nextQ = AdaptiveNodeModel.fromJson(response.data['nextQuestion']);
        state = state.copyWith(
          isSubmitting: false,
          currentNode: nextQ,
          progress: response.data['progress']?.toDouble() ?? state.progress,
        );
      }
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }

  void dismissCrisisMode() {
    state = state.copyWith(crisisModeTriggered: false);
  }
}


final adaptiveSessionProvider = NotifierProvider<AdaptiveSessionNotifier, AdaptiveSessionState>(AdaptiveSessionNotifier.new);
