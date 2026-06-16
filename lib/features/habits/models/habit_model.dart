class Habit {
  final String id;
  final String title;
  final String? description;
  final String category;
  final int duration;
  final bool isMicro;
  final bool isRoutine;
  final String? routineType;
  final String? preferredTime;
  final String? triggerType;
  final String? environment;
  final int difficultyLevel;
  final double adaptabilityScore;
  final bool isActive;
  final DateTime createdAt;
  final List<HabitLog> logs;
  final HabitStreak? streak;
  final HabitRecoveryState? recoveryState;

  Habit({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.duration,
    this.isMicro = false,
    this.isRoutine = false,
    this.routineType,
    this.preferredTime,
    this.triggerType,
    this.environment,
    this.difficultyLevel = 1,
    this.adaptabilityScore = 1.0,
    this.isActive = true,
    required this.createdAt,
    this.logs = const [],
    this.streak,
    this.recoveryState,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'MIND',
      duration: json['duration'] ?? 1,
      isMicro: json['isMicro'] ?? false,
      isRoutine: json['isRoutine'] ?? false,
      routineType: json['routineType'],
      preferredTime: json['preferredTime'],
      triggerType: json['triggerType'],
      environment: json['environment'],
      difficultyLevel: json['difficultyLevel'] ?? 1,
      adaptabilityScore: (json['adaptabilityScore'] as num?)?.toDouble() ?? 1.0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      logs: (json['logs'] as List? ?? [])
          .map((l) => HabitLog.fromJson(l))
          .toList(),
      streak: json['streak'] != null ? HabitStreak.fromJson(json['streak']) : null,
      recoveryState: json['recoveryState'] != null 
          ? HabitRecoveryState.fromJson(json['recoveryState']) 
          : null,
    );
  }
}

class HabitRecoveryState {
  final String id;
  final int missedDays;
  final bool recoveryPlanActive;

  HabitRecoveryState({
    required this.id,
    required this.missedDays,
    required this.recoveryPlanActive,
  });

  factory HabitRecoveryState.fromJson(Map<String, dynamic> json) {
    return HabitRecoveryState(
      id: json['id'] ?? '',
      missedDays: json['missedDays'] ?? 0,
      recoveryPlanActive: json['recoveryPlanActive'] ?? false,
    );
  }
}

class HabitLog {
  final String id;
  final String habitId;
  final DateTime completedAt;
  final int? moodBefore;
  final int? moodAfter;
  final String? note;
  final int? duration;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.completedAt,
    this.moodBefore,
    this.moodAfter,
    this.note,
    this.duration,
  });

  factory HabitLog.fromJson(Map<String, dynamic> json) {
    return HabitLog(
      id: json['id'] ?? '',
      habitId: json['habitId'] ?? '',
      completedAt: DateTime.parse(json['completedAt']),
      moodBefore: json['moodBefore'],
      moodAfter: json['moodAfter'],
      note: json['note'],
      duration: json['duration'],
    );
  }
}

class HabitStreak {
  final String id;
  final int currentStreak;
  final int longestStreak;
  final double consistencyScore;
  final DateTime? lastCompletedAt;

  HabitStreak({
    required this.id,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.consistencyScore = 0.0,
    this.lastCompletedAt,
  });

  factory HabitStreak.fromJson(Map<String, dynamic> json) {
    return HabitStreak(
      id: json['id'] ?? '',
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      consistencyScore: (json['consistencyScore'] as num?)?.toDouble() ?? 0.0,
      lastCompletedAt: json['lastCompletedAt'] != null 
          ? DateTime.parse(json['lastCompletedAt']) 
          : null,
    );
  }
}
