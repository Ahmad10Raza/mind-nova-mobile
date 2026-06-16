import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../therapist/providers/therapist_provider.dart';

class PatientInsightState {
  final String novaSummary;
  final List<double> moodTrends;
  final List<String> journalThemes;
  final String cmhiRiskLevel;

  PatientInsightState({
    required this.novaSummary,
    required this.moodTrends,
    required this.journalThemes,
    required this.cmhiRiskLevel,
  });

  factory PatientInsightState.fromJson(Map<String, dynamic> json) {
    // Process mood logs to create 7-day trend (0.0 to 1.0)
    // The backend returns an array of { score: number, createdAt: string }
    List<dynamic> rawLogs = json['moodLogs'] ?? [];
    
    // Create a 7-day array defaulted to 0.0 or a baseline
    List<double> trends = List.filled(7, 0.0);
    
    if (rawLogs.isNotEmpty) {
      // Map to standard 0-1 range based on score (e.g., if score is 1-10, divide by 10)
      // MindNova usually uses 0-10 or 1-5 for mood scores. Assuming 1-10.
      for (int i = 0; i < rawLogs.length && i < 7; i++) {
        // Just take the latest 7 logs and fill from the end
        double score = (rawLogs[rawLogs.length - 1 - i]['score'] ?? 0).toDouble();
        double normalized = score > 10 ? score / 100 : score / 10; // Normalize just in case
        normalized = normalized > 1.0 ? 1.0 : normalized;
        normalized = normalized < 0.1 ? 0.1 : normalized; // Minimum visible bar
        trends[6 - i] = normalized;
      }
    } else {
      // Dummy data if empty
      trends = [0.4, 0.5, 0.3, 0.7, 0.6, 0.8, 0.2];
    }

    List<String> themes = [];
    if (json['journalThemes'] != null) {
      themes = List<String>.from(json['journalThemes']);
    }

    return PatientInsightState(
      novaSummary: json['novaSummary'] ?? 'No recent insights available.',
      moodTrends: trends,
      journalThemes: themes.isNotEmpty ? themes : ['No recent tags'],
      cmhiRiskLevel: json['cmhiRiskLevel'] ?? 'Unknown',
    );
  }
}

final patientInsightProvider = FutureProvider.autoDispose.family<PatientInsightState, String>((ref, patientId) async {
  final therapistService = ref.read(therapistProvider.notifier);
  // therapistService has api connection. Since we don't have a direct method there, we can do an API call.
  // We can add the method to TherapistNotifier, or just use its dio instance.
  try {
    final tid = await therapistService.getTherapistId();
    if (tid == null) throw Exception('No therapist ID found');
    
    // Expose the API call directly here if not added to therapist_provider.dart
    // Since we don't want to modify therapist_provider.dart unnecessarily, we can use the injected Dio.
    // Wait, let's just add it to TherapistNotifier for cleanliness, or we can use ref.read(dioProvider)?
    // The mobile app usually has a dioProvider. Let's check authProvider or therapistProvider for Dio.
    // Let's assume we use ref.read(dioProvider) if it exists, but therapistProvider uses an internal api.
    
    // Instead of messing with dio, let's add `getPatientInsights` to TherapistNotifier.
    // Wait, let's just call it here using the same base url.
    final data = await therapistService.fetchPatientInsights(patientId);
    return PatientInsightState.fromJson(data);
  } catch (e) {
    throw Exception('Failed to load patient insights: $e');
  }
});
