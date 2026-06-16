import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scoring_model.dart';
import '../services/scoring_service.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for the most recent CMHI score
final latestCMHIProvider = FutureProvider.autoDispose<CMHIScore?>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.status != AuthStatus.authenticated && authState.status != AuthStatus.anonymous) {
    return null;
  }
  
  final service = ref.watch(scoringServiceProvider);
  return await service.calculateLatestScore();
});

/// Provider for the historical score list
final scoreHistoryProvider = FutureProvider.autoDispose<List<CMHIScore>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.status != AuthStatus.authenticated && authState.status != AuthStatus.anonymous) {
    return [];
  }

  final service = ref.watch(scoringServiceProvider);
  return await service.getScoreHistory();
});

/// Provider for specific score insights
final scoreInsightProvider = FutureProvider.family.autoDispose<ScoreExplanation?, String>((ref, scoreId) async {
  final service = ref.watch(scoringServiceProvider);
  return await service.getScoreInsight(scoreId);
});

/// Provider for growth summary (current score vs previous)
final growthSummaryProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final service = ref.watch(scoringServiceProvider);
  return await service.getGrowthSummary();
});
