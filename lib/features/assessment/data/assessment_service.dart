import '../../../core/network/api_client.dart';
import '../models/assessment_model.dart';

class AssessmentService {
  final ApiClient _apiClient;

  AssessmentService(this._apiClient);

  Future<List<Questionnaire>> getAssessments() async {
    final response = await _apiClient.get('/assessments');
    return (response.data as List).map((a) => Questionnaire.fromJson(a)).toList();
  }

  Future<Questionnaire?> getQuestionnaire(String id) async {
    final response = await _apiClient.get('/assessments/$id');
    if (response.data == null) return null;
    return Questionnaire.fromJson(response.data);
  }

  Future<List<AssessmentSession>> getAllSessions() async {
    try {
      final response = await _apiClient.get('/assessments/sessions');
      return (response.data as List).map((s) => AssessmentSession.fromJson(s)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<AssessmentSession?> getSession(String assessmentId) async {
    try {
      final response = await _apiClient.get('/assessments/sessions/$assessmentId');
      if (response.data == null) return null;
      return AssessmentSession.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<AssessmentSession> startSession(String assessmentId, {String depth = 'standard'}) async {
    final response = await _apiClient.post(
      '/assessments/sessions/$assessmentId/start',
      queryParameters: {'depth': depth},
    );
    return AssessmentSession.fromJson(response.data);
  }

  Future<void> saveProgress(String assessmentId, Map<String, int> answers, int currentIndex) async {
    await _apiClient.patch('/assessments/sessions/$assessmentId/progress', data: {
      'answers': answers,
      'currentIndex': currentIndex,
    });
  }

  Future<AssessmentResult> submitAssessment(String assessmentId, Map<String, int> answers) async {
    final response = await _apiClient.post('/assessments/$assessmentId/submit', data: {
      'answers': answers,
    });
    return AssessmentResult.fromJson(response.data);
  }

  Future<List<AssessmentResult>> getAssessmentHistory() async {
    final response = await _apiClient.get('/assessments/history');
    return (response.data as List).map((ar) => AssessmentResult.fromJson(ar)).toList();
  }
}
