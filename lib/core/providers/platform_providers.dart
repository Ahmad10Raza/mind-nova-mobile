import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../../features/mood/data/mood_service.dart';
import '../../features/assessment/data/assessment_service.dart';
import '../database/local_db_service.dart';

// Services
final moodServiceProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return MoodService(client);
});

final assessmentServiceProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return AssessmentService(client);
});
