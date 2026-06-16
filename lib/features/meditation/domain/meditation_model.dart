class MeditationContent {
  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final String category;
  final int durationMinutes;
  final String difficulty;
  final String? bestTimeOfDay;
  final String? coverImageUrl;
  final String audioUrl;
  final String? backgroundTheme;
  final String? voiceType;
  final String? ambientSoundType;
  final List<String> tags;
  final bool isFeatured;
  final bool isPremium;

  MeditationContent({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    required this.category,
    required this.durationMinutes,
    required this.difficulty,
    this.bestTimeOfDay,
    this.coverImageUrl,
    required this.audioUrl,
    this.backgroundTheme,
    this.voiceType,
    this.ambientSoundType,
    this.tags = const [],
    this.isFeatured = false,
    this.isPremium = false,
  });

  factory MeditationContent.fromJson(Map<String, dynamic> json) {
    return MeditationContent(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String,
      durationMinutes: json['durationMinutes'] as int,
      difficulty: json['difficulty'] as String,
      bestTimeOfDay: json['bestTimeOfDay'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      audioUrl: json['audioUrl'] as String,
      backgroundTheme: json['backgroundTheme'] as String?,
      voiceType: json['voiceType'] as String?,
      ambientSoundType: json['ambientSoundType'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      isFeatured: json['isFeatured'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }
}

class MeditationDashboardStats {
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final int totalMinutes;
  final List<String> badges;
  final String? mostEffectiveCategory;
  final String? favoriteCategory;
  final double averageCalmImprovement;
  final List<MeditationSession> recentSessions;

  MeditationDashboardStats({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.badges = const [],
    this.mostEffectiveCategory,
    this.favoriteCategory,
    this.averageCalmImprovement = 0.0,
    this.recentSessions = const [],
  });

  factory MeditationDashboardStats.fromJson(Map<String, dynamic> json) {
    return MeditationDashboardStats(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      totalSessions: json['totalSessions'] as int? ?? 0,
      totalMinutes: json['totalMinutes'] as int? ?? 0,
      badges: json['badges'] != null ? List<String>.from(json['badges']) : const [],
      mostEffectiveCategory: json['mostEffectiveCategory'] as String?,
      favoriteCategory: json['favoriteCategory'] as String?,
      averageCalmImprovement: (json['averageCalmImprovement'] as num?)?.toDouble() ?? 0.0,
      recentSessions: json['recentSessions'] != null
          ? (json['recentSessions'] as List).map((e) => MeditationSession.fromJson(e)).toList()
          : const [],
    );
  }
}

class MeditationSession {
  final String id;
  final String userId;
  final String contentId;
  final int durationSecs;
  final int? calmBefore;
  final int? calmAfter;
  final bool completedFull;
  final DateTime completedAt;
  final MeditationContent? content;

  MeditationSession({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.durationSecs,
    this.calmBefore,
    this.calmAfter,
    this.completedFull = true,
    required this.completedAt,
    this.content,
  });

  factory MeditationSession.fromJson(Map<String, dynamic> json) {
    return MeditationSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      contentId: json['contentId'] as String,
      durationSecs: json['durationSecs'] as int,
      calmBefore: json['calmBefore'] as int?,
      calmAfter: json['calmAfter'] as int?,
      completedFull: json['completedFull'] as bool? ?? true,
      completedAt: DateTime.parse(json['completedAt'] as String),
      content: json['content'] != null ? MeditationContent.fromJson(json['content']) : null,
    );
  }
}
