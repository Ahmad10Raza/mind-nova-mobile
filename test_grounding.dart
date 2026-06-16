import 'dart:convert';
import 'lib/features/grounding/models/grounding_model.dart';

void main() {
  const jsonStr = '''{
    "currentStreak": 0,
    "longestStreak": 0,
    "totalSessions": 0,
    "totalMinutes": 0,
    "badges": [],
    "mostUsedExercise": null,
    "mostEffectiveExercise": null,
    "averageCalmRating": 0,
    "favoriteEnvironment": null,
    "recentSessions": []
  }''';
  
  try {
    final parsed = GroundingDashboard.fromJson(jsonDecode(jsonStr));
    print("Success: ${parsed.totalMinutes}");
  } catch (e, stack) {
    print("Error: $e");
    print(stack);
  }
}
