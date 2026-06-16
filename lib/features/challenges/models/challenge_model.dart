class Challenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final int durationDays;
  final int difficultyLevel;
  final String icon;
  final List<String> coverGradient;
  final List<ChallengeDay> days;
  final int participantCount;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationDays,
    this.difficultyLevel = 1,
    this.icon = '🎯',
    this.coverGradient = const ['#6A0DAD', '#9147FF'],
    this.days = const [],
    this.participantCount = 0,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'MENTAL_HEALTH',
      durationDays: json['durationDays'] ?? 3,
      difficultyLevel: json['difficultyLevel'] ?? 1,
      icon: json['icon'] ?? '🎯',
      coverGradient: (json['coverGradient'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          ['#6A0DAD', '#9147FF'],
      days: (json['days'] as List?)
              ?.map((d) => ChallengeDay.fromJson(d))
              .toList() ??
          [],
      participantCount: json['_count']?['userChallenges'] ?? 0,
    );
  }
}

class ChallengeDay {
  final String id;
  final int dayNumber;
  final String title;
  final String motivation;
  final List<ChallengeTask> tasks;

  ChallengeDay({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.motivation,
    this.tasks = const [],
  });

  factory ChallengeDay.fromJson(Map<String, dynamic> json) {
    return ChallengeDay(
      id: json['id'] ?? '',
      dayNumber: json['dayNumber'] ?? 1,
      title: json['title'] ?? '',
      motivation: json['motivation'] ?? '',
      tasks: (json['tasks'] as List?)
              ?.map((t) => ChallengeTask.fromJson(t))
              .toList() ??
          [],
    );
  }
}

class ChallengeTask {
  final String id;
  final String title;
  final String? description;
  final String type; // HABIT, AUDIO, REFLECTION, BREATHING
  final int duration;
  final int orderIndex;
  final String? habitId;

  ChallengeTask({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.duration = 2,
    this.orderIndex = 0,
    this.habitId,
  });

  factory ChallengeTask.fromJson(Map<String, dynamic> json) {
    return ChallengeTask(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      type: json['type'] ?? 'REFLECTION',
      duration: json['duration'] ?? 2,
      orderIndex: json['orderIndex'] ?? 0,
      habitId: json['habitId'],
    );
  }
}

class UserChallenge {
  final String id;
  final String challengeId;
  final Challenge challenge;
  final DateTime startDate;
  final String status;
  final int currentDay;
  final DateTime? completedAt;
  final String? preferredTime;
  final bool reminderEnabled;
  final String? reminderTime;
  final int missedDays;
  final DateTime lastActiveAt;
  final double completionRate;
  final double engagementScore;
  final int streakDays;
  final int adaptationLevel;
  final String? abandonReason;
  final List<UserChallengeProgress> progress;
  final DropOffRecovery? dropOff;

  UserChallenge({
    required this.id,
    required this.challengeId,
    required this.challenge,
    required this.startDate,
    this.status = 'ACTIVE',
    this.currentDay = 1,
    this.completedAt,
    this.preferredTime,
    this.reminderEnabled = true,
    this.reminderTime,
    this.missedDays = 0,
    required this.lastActiveAt,
    this.completionRate = 0.0,
    this.engagementScore = 0.0,
    this.streakDays = 0,
    this.adaptationLevel = 0,
    this.abandonReason,
    this.progress = const [],
    this.dropOff,
  });

  factory UserChallenge.fromJson(Map<String, dynamic> json) {
    DateTime? safeParse(dynamic val) {
      if (val == null || val.toString().isEmpty) return null;
      try { return DateTime.parse(val.toString()); } catch (_) { return null; }
    }

    return UserChallenge(
      id: json['id'] ?? '',
      challengeId: json['challengeId'] ?? '',
      challenge: Challenge.fromJson(json['challenge'] ?? {}),
      startDate: safeParse(json['startDate']) ?? DateTime.now(),
      status: json['status'] ?? 'ACTIVE',
      currentDay: json['currentDay'] ?? 1,
      completedAt: safeParse(json['completedAt']),
      preferredTime: json['preferredTime'],
      reminderEnabled: json['reminderEnabled'] ?? true,
      reminderTime: json['reminderTime'],
      missedDays: json['missedDays'] ?? 0,
      lastActiveAt: safeParse(json['lastActiveAt']) ?? DateTime.now(),
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
      engagementScore: (json['engagementScore'] as num?)?.toDouble() ?? 0.0,
      streakDays: json['streakDays'] ?? 0,
      adaptationLevel: json['adaptationLevel'] ?? 0,
      abandonReason: json['abandonReason'],
      progress: (json['progress'] as List?)
              ?.map((p) => UserChallengeProgress.fromJson(p))
              .toList() ??
          [],
      dropOff: json['dropOff'] != null
          ? DropOffRecovery.fromJson(json['dropOff'])
          : null,
    );
  }

  /// Get today's challenge day data
  ChallengeDay? get todayDay {
    try {
      return challenge.days.firstWhere((d) => d.dayNumber == currentDay);
    } catch (_) {
      return null;
    }
  }

  /// Check if today's challenge tasks are completed
  bool get isCompletedForToday {
    try {
      final progressToday = progress.firstWhere((p) => p.dayNumber == currentDay);
      return progressToday.completed;
    } catch (_) {
      return false;
    }
  }
}

class UserChallengeProgress {
  final String id;
  final int dayNumber;
  final bool completed;
  final DateTime? completedAt;
  final int tasksCompleted;
  final int totalTasks;
  final double completionPercentage;

  UserChallengeProgress({
    required this.id,
    required this.dayNumber,
    this.completed = false,
    this.completedAt,
    this.tasksCompleted = 0,
    this.totalTasks = 0,
    this.completionPercentage = 0.0,
  });

  factory UserChallengeProgress.fromJson(Map<String, dynamic> json) {
    DateTime? safeParse(dynamic val) {
      if (val == null || val.toString().isEmpty) return null;
      try { return DateTime.parse(val.toString()); } catch (_) { return null; }
    }

    return UserChallengeProgress(
      id: json['id'] ?? '',
      dayNumber: json['dayNumber'] ?? 1,
      completed: json['completed'] ?? false,
      completedAt: safeParse(json['completedAt']),
      tasksCompleted: json['tasksCompleted'] ?? 0,
      totalTasks: json['totalTasks'] ?? 0,
      completionPercentage:
          (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DropOffRecovery {
  final String type; // GENTLE_REMINDER, LITE_DAY, RESTART_OFFER
  final String message;
  final int daysMissed;

  DropOffRecovery({
    required this.type,
    required this.message,
    this.daysMissed = 0,
  });

  factory DropOffRecovery.fromJson(Map<String, dynamic> json) {
    return DropOffRecovery(
      type: json['type'] ?? 'GENTLE_REMINDER',
      message: json['message'] ?? '',
      daysMissed: json['daysMissed'] ?? 0,
    );
  }
}
