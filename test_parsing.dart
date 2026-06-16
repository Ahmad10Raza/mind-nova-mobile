import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const starterJson = '''
  {
      "id": "starter",
      "userId": "test-user",
      "isStarter": true,
      "weekStartDate": "2026-04-25T00:00:00.000Z",
      "weekEndDate": "2026-04-25T00:00:00.000Z",
      "avgMoodScore": 0,
      "moodTrend": "FLAT",
      "moodLogCount": 0,
      "avgSleepHours": null,
      "sleepConsistency": null,
      "stressAvg": null,
      "burnoutRisk": null,
      "anxietyTrend": null,
      "depressionTrend": null,
      "gratitudeCount": 0,
      "journalCount": 0,
      "meditationMinutes": 0,
      "groundingSessions": 0,
      "audioMinutes": 0,
      "emotionalVolatility": null,
      "recoveryScore": null,
      "wellnessScore": null,
      "engagementScore": 0,
      "cmhiWeeklyScore": null,
      "streakScore": 0,
      "aiSummary": "Your first weekly insight starts building now. Log your moods, practice gratitude, and use the wellness tools — your personalized report will be ready this Sunday.",
      "aiTitle": "Your Journey Begins ✨",
      "aiWhatHelped": null,
      "aiChallenges": null,
      "aiComparison": null,
      "aiRecommendations": [
        "Log your mood at least once today",
        "Try a 5-minute meditation session",
        "Write one gratitude entry"
      ],
      "aiEncouragement": "Every journey starts with a single step. We're here to walk with you. 🌟",
      "previousWellnessScore": null,
      "previousMoodScore": null,
      "weekDelta": null,
      "improved": null,
      "crisisRiskLevel": "LOW",
      "dataCompleteness": 0,
      "dataConfidence": "STARTER",
      "reportVersion": "2.0",
      "isShared": false,
      "isExported": false,
      "createdAt": "2026-04-25T00:00:00.000Z"
    }
  ''';

  final json = jsonDecode(starterJson);
  
  // Simulation of WeeklyReport.fromJson
  try {
    final id = json['id'] as String;
    final userId = json['userId'] as String;
    final weekStartDate = DateTime.parse(json['weekStartDate'] as String);
    final weekEndDate = DateTime.parse(json['weekEndDate'] as String);
    final isStarter = json['isStarter'] as bool? ?? false;
    final avgMoodScore = (json['avgMoodScore'] as num).toDouble();
    final bestMoodDay = json['bestMoodDay'] as String?;
    final worstMoodDay = json['worstMoodDay'] as String?;
    final moodTrend = json['moodTrend'] as String? ?? 'FLAT';
    final moodLogCount = json['moodLogCount'] as int? ?? 0;
    final avgSleepHours = json['avgSleepHours'] != null ? (json['avgSleepHours'] as num).toDouble() : null;
    final sleepConsistency = json['sleepConsistency'] != null ? (json['sleepConsistency'] as num).toDouble() : null;
    final stressAvg = json['stressAvg'] != null ? (json['stressAvg'] as num).toDouble() : null;
    final burnoutRisk = json['burnoutRisk'] != null ? (json['burnoutRisk'] as num).toDouble() : null;
    final anxietyTrend = json['anxietyTrend'] != null ? (json['anxietyTrend'] as num).toDouble() : null;
    final depressionTrend = json['depressionTrend'] != null ? (json['depressionTrend'] as num).toDouble() : null;
    final gratitudeCount = json['gratitudeCount'] as int? ?? 0;
    final journalCount = json['journalCount'] as int? ?? 0;
    final meditationMinutes = json['meditationMinutes'] as int? ?? 0;
    final groundingSessions = json['groundingSessions'] as int? ?? 0;
    final audioMinutes = json['audioMinutes'] as int? ?? 0;
    final emotionalVolatility = json['emotionalVolatility'] != null ? (json['emotionalVolatility'] as num).toDouble() : null;
    final recoveryScore = json['recoveryScore'] != null ? (json['recoveryScore'] as num).toDouble() : null;
    final wellnessScore = json['wellnessScore'] != null ? (json['wellnessScore'] as num).toDouble() : null;
    final engagementScore = json['engagementScore'] != null ? (json['engagementScore'] as num).toDouble() : null;
    final cmhiWeeklyScore = json['cmhiWeeklyScore'] != null ? (json['cmhiWeeklyScore'] as num).toDouble() : null;
    final streakScore = json['streakScore'] as int? ?? 0;
    final aiSummary = json['aiSummary'] as String;
    final aiTitle = json['aiTitle'] as String?;
    final aiWhatHelped = json['aiWhatHelped'] as String?;
    final aiChallenges = json['aiChallenges'] as String?;
    final aiComparison = json['aiComparison'] as String?;
    final aiRecommendations = json['aiRecommendations'] != null ? List<String>.from(json['aiRecommendations'] as List) : [];
    final aiEncouragement = json['aiEncouragement'] as String?;
    final previousWellnessScore = json['previousWellnessScore'] != null ? (json['previousWellnessScore'] as num).toDouble() : null;
    final previousMoodScore = json['previousMoodScore'] != null ? (json['previousMoodScore'] as num).toDouble() : null;
    final weekDelta = json['weekDelta'] != null ? (json['weekDelta'] as num).toDouble() : null;
    final improved = json['improved'] as bool?;
    final crisisRiskLevel = json['crisisRiskLevel'] as String? ?? 'LOW';
    final dataCompleteness = json['dataCompleteness'] != null ? (json['dataCompleteness'] as num).toDouble() : 0;
    final dataConfidence = json['dataConfidence'] as String? ?? 'STARTER';
    final reportVersion = json['reportVersion'] as String? ?? '2.0';
    final isShared = json['isShared'] as bool? ?? false;
    final isExported = json['isExported'] as bool? ?? false;
    final createdAt = DateTime.parse(json['createdAt'] as String);

    print('Successfully parsed everything!');
  } catch (e, stack) {
    print('Failed parsing: $e\n$stack');
  }
}
