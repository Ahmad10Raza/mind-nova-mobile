import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/assessment_service.dart';
import '../models/assessment_model.dart';
import '../providers/assessment_session_provider.dart';
import '../../auth/providers/auth_provider.dart';

final assessmentHistoryProvider = FutureProvider<List<AssessmentResult>>((ref) async {
  // Watch auth provider so this list invalidates on login/logout/upgrade
  ref.watch(authProvider);
  
  final service = ref.watch(assessmentServiceProvider);
  return await service.getAssessmentHistory();
});
