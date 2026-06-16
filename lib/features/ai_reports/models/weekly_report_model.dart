class WeeklyReport {
  final String id;
  final String userId;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final bool isStarter;

  // ── Mood Analytics ──
  final double avgMoodScore;
  final String? bestMoodDay;
  final String? worstMoodDay;
  final String moodTrend;
  final int moodLogCount;

  // ── Sleep ──
  final double? avgSleepHours;
  final double? sleepConsistency;

  // ── Predictions ──
  final double? stressAvg;
  final double? burnoutRisk;
  final double? anxietyTrend;
  final double? depressionTrend;

  // ── Engagement Metrics ──
  final int gratitudeCount;
  final int journalCount;
  final int meditationMinutes;
  final int groundingSessions;
  final int audioMinutes;

  // ── Composite Scores ──
  final double? emotionalVolatility;
  final double? recoveryScore;
  final double? wellnessScore;
  final double? engagementScore;
  final double? cmhiWeeklyScore;
  final int streakScore;

  // ── AI Derived ──
  final String aiSummary;
  final String? aiTitle;
  final String? aiWhatHelped;
  final String? aiChallenges;
  final String? aiComparison;
  final List<String> aiRecommendations;
  final String? aiEncouragement;

  // ── Previous Week Comparison ──
  final double? previousWellnessScore;
  final double? previousMoodScore;
  final double? weekDelta;
  final bool? improved;

  // ── Safety ──
  final String crisisRiskLevel;

  // ── Confidence & Metadata ──
  final double dataCompleteness;
  final String dataConfidence;
  final String reportVersion;
  final bool isShared;
  final bool isExported;
  final DateTime createdAt;

  WeeklyReport({
    required this.id,
    required this.userId,
    required this.weekStartDate,
    required this.weekEndDate,
    this.isStarter = false,
    required this.avgMoodScore,
    this.bestMoodDay,
    this.worstMoodDay,
    this.moodTrend = 'FLAT',
    this.moodLogCount = 0,
    this.avgSleepHours,
    this.sleepConsistency,
    this.stressAvg,
    this.burnoutRisk,
    this.anxietyTrend,
    this.depressionTrend,
    this.gratitudeCount = 0,
    this.journalCount = 0,
    this.meditationMinutes = 0,
    this.groundingSessions = 0,
    this.audioMinutes = 0,
    this.emotionalVolatility,
    this.recoveryScore,
    this.wellnessScore,
    this.engagementScore,
    this.cmhiWeeklyScore,
    this.streakScore = 0,
    required this.aiSummary,
    this.aiTitle,
    this.aiWhatHelped,
    this.aiChallenges,
    this.aiComparison,
    this.aiRecommendations = const [],
    this.aiEncouragement,
    this.previousWellnessScore,
    this.previousMoodScore,
    this.weekDelta,
    this.improved,
    this.crisisRiskLevel = 'LOW',
    this.dataCompleteness = 0,
    this.dataConfidence = 'STARTER',
    this.reportVersion = '2.0',
    this.isShared = false,
    this.isExported = false,
    required this.createdAt,
  });

  factory WeeklyReport.fromJson(Map<String, dynamic> json) {
    return WeeklyReport(
      id: json['id'] as String,
      userId: json['userId'] as String,
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      weekEndDate: DateTime.parse(json['weekEndDate'] as String),
      isStarter: json['isStarter'] as bool? ?? false,
      avgMoodScore: (json['avgMoodScore'] as num).toDouble(),
      bestMoodDay: json['bestMoodDay'] as String?,
      worstMoodDay: json['worstMoodDay'] as String?,
      moodTrend: json['moodTrend'] as String? ?? 'FLAT',
      moodLogCount: json['moodLogCount'] as int? ?? 0,
      avgSleepHours: json['avgSleepHours'] != null ? (json['avgSleepHours'] as num).toDouble() : null,
      sleepConsistency: json['sleepConsistency'] != null ? (json['sleepConsistency'] as num).toDouble() : null,
      stressAvg: json['stressAvg'] != null ? (json['stressAvg'] as num).toDouble() : null,
      burnoutRisk: json['burnoutRisk'] != null ? (json['burnoutRisk'] as num).toDouble() : null,
      anxietyTrend: json['anxietyTrend'] != null ? (json['anxietyTrend'] as num).toDouble() : null,
      depressionTrend: json['depressionTrend'] != null ? (json['depressionTrend'] as num).toDouble() : null,
      gratitudeCount: json['gratitudeCount'] as int? ?? 0,
      journalCount: json['journalCount'] as int? ?? 0,
      meditationMinutes: json['meditationMinutes'] as int? ?? 0,
      groundingSessions: json['groundingSessions'] as int? ?? 0,
      audioMinutes: json['audioMinutes'] as int? ?? 0,
      emotionalVolatility: json['emotionalVolatility'] != null ? (json['emotionalVolatility'] as num).toDouble() : null,
      recoveryScore: json['recoveryScore'] != null ? (json['recoveryScore'] as num).toDouble() : null,
      wellnessScore: json['wellnessScore'] != null ? (json['wellnessScore'] as num).toDouble() : null,
      engagementScore: json['engagementScore'] != null ? (json['engagementScore'] as num).toDouble() : null,
      cmhiWeeklyScore: json['cmhiWeeklyScore'] != null ? (json['cmhiWeeklyScore'] as num).toDouble() : null,
      streakScore: json['streakScore'] as int? ?? 0,
      aiSummary: json['aiSummary'] as String,
      aiTitle: json['aiTitle'] as String?,
      aiWhatHelped: json['aiWhatHelped'] as String?,
      aiChallenges: json['aiChallenges'] as String?,
      aiComparison: json['aiComparison'] as String?,
      aiRecommendations: json['aiRecommendations'] != null
          ? List<String>.from(json['aiRecommendations'] as List)
          : [],
      aiEncouragement: json['aiEncouragement'] as String?,
      previousWellnessScore: json['previousWellnessScore'] != null ? (json['previousWellnessScore'] as num).toDouble() : null,
      previousMoodScore: json['previousMoodScore'] != null ? (json['previousMoodScore'] as num).toDouble() : null,
      weekDelta: json['weekDelta'] != null ? (json['weekDelta'] as num).toDouble() : null,
      improved: json['improved'] as bool?,
      crisisRiskLevel: json['crisisRiskLevel'] as String? ?? 'LOW',
      dataCompleteness: json['dataCompleteness'] != null ? (json['dataCompleteness'] as num).toDouble() : 0,
      dataConfidence: json['dataConfidence'] as String? ?? 'STARTER',
      reportVersion: json['reportVersion'] as String? ?? '2.0',
      isShared: json['isShared'] as bool? ?? false,
      isExported: json['isExported'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
