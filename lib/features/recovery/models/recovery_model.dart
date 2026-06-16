class RecoverySession {
  final String id;
  final String title;
  final String? description;
  final int duration;
  final String type;
  final String category;
  final String? audioUrl;
  final String? imageUrl;
  final List<RecoveryStage> stages;

  RecoverySession({
    required this.id,
    required this.title,
    this.description,
    required this.duration,
    required this.type,
    required this.category,
    this.audioUrl,
    this.imageUrl,
    this.stages = const [],
  });

  factory RecoverySession.fromJson(Map<String, dynamic> json) {
    return RecoverySession(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      type: json['type'],
      category: json['category'],
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      stages: json['stages'] != null 
          ? (json['stages'] as List).map((s) => RecoveryStage.fromJson(s)).toList()
          : [],
    );
  }
}

class RecoveryStage {
  final String id;
  final String type;
  final int duration; // in seconds
  final String title;
  final String? description;
  final Map<String, dynamic>? content;
  final int order;
  final bool isSkippable;
  final int? minDuration;

  RecoveryStage({
    required this.id,
    required this.type,
    required this.duration,
    required this.title,
    this.description,
    this.content,
    required this.order,
    this.isSkippable = true,
    this.minDuration,
  });

  factory RecoveryStage.fromJson(Map<String, dynamic> json) {
    return RecoveryStage(
      id: json['id'],
      type: json['type'],
      duration: json['duration'],
      title: json['title'],
      description: json['description'],
      content: json['content'] != null ? Map<String, dynamic>.from(json['content']) : null,
      order: json['order'],
      isSkippable: json['isSkippable'] ?? true,
      minDuration: json['minDuration'],
    );
  }
}

class RecoveryScore {
  final double stressLevel;
  final double energyLevel;
  final double recoveryLevel;
  final int streakCount;

  RecoveryScore({
    required this.stressLevel,
    required this.energyLevel,
    required this.recoveryLevel,
    required this.streakCount,
  });

  factory RecoveryScore.fromJson(Map<String, dynamic> json) {
    return RecoveryScore(
      stressLevel: (json['stressLevel'] as num).toDouble(),
      energyLevel: (json['energyLevel'] as num).toDouble(),
      recoveryLevel: (json['recoveryLevel'] as num).toDouble(),
      streakCount: json['streakCount'] as int,
    );
  }
}

class RecoveryLog {
  final String id;
  final String sessionId;
  final int? beforeMood;
  final int? afterMood;
  final DateTime createdAt;
  final RecoverySession? session;

  RecoveryLog({
    required this.id,
    required this.sessionId,
    this.beforeMood,
    this.afterMood,
    required this.createdAt,
    this.session,
  });

  factory RecoveryLog.fromJson(Map<String, dynamic> json) {
    return RecoveryLog(
      id: json['id'],
      sessionId: json['sessionId'],
      beforeMood: json['beforeMood'],
      afterMood: json['afterMood'],
      createdAt: DateTime.parse(json['createdAt']),
      session: json['session'] != null ? RecoverySession.fromJson(json['session']) : null,
    );
  }
}

class RecoveryRecommendation {
  final String reason;
  final RecoverySession? recommendedSession;

  RecoveryRecommendation({
    required this.reason,
    this.recommendedSession,
  });

  factory RecoveryRecommendation.fromJson(Map<String, dynamic> json) {
    return RecoveryRecommendation(
      reason: json['reason'],
      recommendedSession: json['recommendedSession'] != null 
          ? RecoverySession.fromJson(json['recommendedSession']) 
          : null,
    );
  }
}
