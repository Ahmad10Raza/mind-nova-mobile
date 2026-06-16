import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ai_prediction_service.dart';

final aiInsightProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, insightId) async* {
  final service = ref.watch(aiPredictionServiceProvider);
  
  // Continuous polling while the view is active
  while (true) {
    try {
      final result = await service.getInsight(insightId);
      yield result;

      // Stop polling if generation is complete, failed, or fallback used
      final status = result['status'];
      if (status != 'PENDING' && status != 'GENERATING') {
        break; 
      }
    } catch (e) {
      // StreamProvider will automatically catch this and provide it as AsyncValue.error
      rethrow;
    }
    
    // Wait before the next poll
    await Future.delayed(const Duration(seconds: 3));
  }
});
