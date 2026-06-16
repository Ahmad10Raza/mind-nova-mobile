// ─── Core Mood Models ─────────────────────────────────────────────────────────

class MoodLog {
  final String id;
  final String moodName;
  final String category;
  final String intensity;
  final List<String> tags;
  final String? notes;
  final bool aiSafetyFlag;
  final DateTime createdAt;

  MoodLog({
    required this.id,
    required this.moodName,
    required this.category,
    required this.intensity,
    required this.tags,
    this.notes,
    this.aiSafetyFlag = false,
    required this.createdAt,
  });

  factory MoodLog.fromJson(Map<String, dynamic> json) {
    return MoodLog(
      id: json['_id'] ?? json['id'] ?? '',
      moodName: json['moodName'] ?? '',
      category: json['category'] ?? 'neutral',
      intensity: json['intensity'] ?? 'moderate',
      tags: List<String>.from(json['tags'] ?? []),
      notes: json['notes'],
      aiSafetyFlag: json['aiSafetyFlag'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// ─── Trend Chart Data ─────────────────────────────────────────────────────────

class MoodTrend {
  final double score;
  final DateTime date;
  final String? mood;
  final String? category;
  final String? color;
  final String? emoji;

  MoodTrend({
    required this.score,
    required this.date,
    this.mood,
    this.category,
    this.color,
    this.emoji,
  });

  factory MoodTrend.fromJson(Map<String, dynamic> json) {
    return MoodTrend(
      score: (json['score'] as num?)?.toDouble() ?? 3.0,
      date: DateTime.parse(json['date']),
      mood: json['mood'],
      category: json['category'],
      color: json['color'],
      emoji: json['emoji'],
    );
  }
}

// ─── Legacy Insights (for backward compat) ────────────────────────────────────

class MoodInsights {
  final double averageScore;
  final DateTime? bestDay;
  final DateTime? worstDay;
  final int totalLogs;
  final bool isImproving;

  MoodInsights({
    required this.averageScore,
    this.bestDay,
    this.worstDay,
    required this.totalLogs,
    required this.isImproving,
  });

  factory MoodInsights.fromJson(Map<String, dynamic> json) {
    return MoodInsights(
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 3.0,
      bestDay: json['bestDay'] != null ? DateTime.parse(json['bestDay']) : null,
      worstDay: json['worstDay'] != null ? DateTime.parse(json['worstDay']) : null,
      totalLogs: json['totalLogs'] ?? 0,
      isImproving: json['isImproving'] ?? false,
    );
  }
}

// ─── Home Widget ──────────────────────────────────────────────────────────────

class MoodStreaks {
  final int dailyCheckin;
  final int longest;
  final int positiveMood;
  final int calmDay;

  const MoodStreaks({
    this.dailyCheckin = 0,
    this.longest = 0,
    this.positiveMood = 0,
    this.calmDay = 0,
  });

  factory MoodStreaks.fromJson(Map<String, dynamic> json) {
    return MoodStreaks(
      dailyCheckin: json['dailyCheckin'] ?? 0,
      longest: json['longest'] ?? 0,
      positiveMood: json['positiveMood'] ?? 0,
      calmDay: json['calmDay'] ?? 0,
    );
  }
}

class MoodHomeWidget {
  final bool hasLogs;
  final String? latestMood;
  final String? latestCategory;
  final String? latestEmoji;
  final String? latestColor;
  final DateTime? loggedAt;
  final String insightMessage;
  final List<double> sparkline;
  final MoodStreaks streaks;

  const MoodHomeWidget({
    required this.hasLogs,
    this.latestMood,
    this.latestCategory,
    this.latestEmoji,
    this.latestColor,
    this.loggedAt,
    required this.insightMessage,
    required this.sparkline,
    required this.streaks,
  });

  factory MoodHomeWidget.fromJson(Map<String, dynamic> json) {
    return MoodHomeWidget(
      hasLogs: json['hasLogs'] ?? false,
      latestMood: json['latestMood'],
      latestCategory: json['latestCategory'],
      latestEmoji: json['latestEmoji'],
      latestColor: json['latestColor'],
      loggedAt: json['loggedAt'] != null ? DateTime.tryParse(json['loggedAt']) : null,
      insightMessage: json['insightMessage'] ?? 'Start your first emotional check-in ✨',
      sparkline: (json['sparkline'] as List? ?? []).map((v) => (v as num).toDouble()).toList(),
      streaks: json['streaks'] != null
          ? MoodStreaks.fromJson(json['streaks'])
          : const MoodStreaks(),
    );
  }
}

// ─── Analytics Summary ────────────────────────────────────────────────────────

class ImportantMoment {
  final String type;
  final DateTime date;
  final String mood;
  final String emoji;
  final String color;

  const ImportantMoment({
    required this.type,
    required this.date,
    required this.mood,
    required this.emoji,
    required this.color,
  });

  factory ImportantMoment.fromJson(Map<String, dynamic> json) {
    return ImportantMoment(
      type: json['type'] ?? 'unknown',
      date: DateTime.parse(json['date']),
      mood: json['mood'] ?? '',
      emoji: json['emoji'] ?? '😐',
      color: json['color'] ?? '#9CA3AF',
    );
  }
}

class MoodAnalyticsSummary {
  final bool hasData;
  final String dominantMood;
  final String dominantEmoji;
  final String dominantColor;
  final double averageScore;
  final int totalLogs;
  final int positivePercent;
  final int neutralPercent;
  final int negativePercent;
  final int criticalPercent;
  final int positiveStreak;
  final String weeklyDelta;
  final bool improvedVsLastPeriod;
  final String trendDirection;
  final String summaryMessage;
  final List<ImportantMoment> importantMoments;

  const MoodAnalyticsSummary({
    required this.hasData,
    this.dominantMood = '',
    this.dominantEmoji = '😐',
    this.dominantColor = '#9CA3AF',
    this.averageScore = 0,
    this.totalLogs = 0,
    this.positivePercent = 0,
    this.neutralPercent = 0,
    this.negativePercent = 0,
    this.criticalPercent = 0,
    this.positiveStreak = 0,
    this.weeklyDelta = '0%',
    this.improvedVsLastPeriod = false,
    this.trendDirection = 'stable',
    this.summaryMessage = '',
    this.importantMoments = const [],
  });

  factory MoodAnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return MoodAnalyticsSummary(
      hasData: json['hasData'] ?? false,
      dominantMood: json['dominantMood'] ?? '',
      dominantEmoji: json['dominantEmoji'] ?? '😐',
      dominantColor: json['dominantColor'] ?? '#9CA3AF',
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0,
      totalLogs: json['totalLogs'] ?? 0,
      positivePercent: json['positivePercent'] ?? 0,
      neutralPercent: json['neutralPercent'] ?? 0,
      negativePercent: json['negativePercent'] ?? 0,
      criticalPercent: json['criticalPercent'] ?? 0,
      positiveStreak: json['positiveStreak'] ?? 0,
      weeklyDelta: json['weeklyDelta'] ?? '0%',
      improvedVsLastPeriod: json['improvedVsLastPeriod'] ?? false,
      trendDirection: json['trendDirection'] ?? 'stable',
      summaryMessage: json['summaryMessage'] ?? '',
      importantMoments: (json['importantMoments'] as List? ?? [])
          .map((m) => ImportantMoment.fromJson(m))
          .toList(),
    );
  }
}

// ─── Mood Distribution ────────────────────────────────────────────────────────

class MoodDistributionEntry {
  final String mood;
  final int count;
  final int percent;
  final String color;
  final String emoji;
  final String category;

  const MoodDistributionEntry({
    required this.mood,
    required this.count,
    required this.percent,
    required this.color,
    required this.emoji,
    required this.category,
  });

  factory MoodDistributionEntry.fromJson(Map<String, dynamic> json) {
    return MoodDistributionEntry(
      mood: json['mood'] ?? '',
      count: json['count'] ?? 0,
      percent: json['percent'] ?? 0,
      color: json['color'] ?? '#9CA3AF',
      emoji: json['emoji'] ?? '😐',
      category: json['category'] ?? 'neutral',
    );
  }
}

class MoodDistribution {
  final bool hasData;
  final int totalLogs;
  final int positive;
  final int neutral;
  final int negative;
  final int critical;
  final List<MoodDistributionEntry> breakdown;

  const MoodDistribution({
    required this.hasData,
    this.totalLogs = 0,
    this.positive = 0,
    this.neutral = 0,
    this.negative = 0,
    this.critical = 0,
    this.breakdown = const [],
  });

  factory MoodDistribution.fromJson(Map<String, dynamic> json) {
    return MoodDistribution(
      hasData: json['hasData'] ?? false,
      totalLogs: json['totalLogs'] ?? 0,
      positive: json['positive'] ?? 0,
      neutral: json['neutral'] ?? 0,
      negative: json['negative'] ?? 0,
      critical: json['critical'] ?? 0,
      breakdown: (json['breakdown'] as List? ?? [])
          .map((e) => MoodDistributionEntry.fromJson(e))
          .toList(),
    );
  }
}

// ─── Trigger Analysis ─────────────────────────────────────────────────────────

class TriggerInsight {
  final String tag;
  final int count;
  final List<String> linkedMoods;
  final String color;

  const TriggerInsight({
    required this.tag,
    required this.count,
    required this.linkedMoods,
    required this.color,
  });

  factory TriggerInsight.fromJson(Map<String, dynamic> json) {
    return TriggerInsight(
      tag: json['tag'] ?? '',
      count: json['count'] ?? 0,
      linkedMoods: List<String>.from(json['linkedMoods'] ?? []),
      color: json['color'] ?? '#9CA3AF',
    );
  }
}

class TriggerCorrelation {
  final List<String> tags;
  final String outcome;
  final int frequency;

  const TriggerCorrelation({
    required this.tags,
    required this.outcome,
    required this.frequency,
  });

  factory TriggerCorrelation.fromJson(Map<String, dynamic> json) {
    return TriggerCorrelation(
      tags: List<String>.from(json['tags'] ?? []),
      outcome: json['outcome'] ?? '',
      frequency: json['frequency'] ?? 0,
    );
  }
}

class TriggerAnalysis {
  final bool hasData;
  final List<TriggerInsight> topTriggers;
  final List<TriggerCorrelation> correlations;

  const TriggerAnalysis({
    required this.hasData,
    this.topTriggers = const [],
    this.correlations = const [],
  });

  factory TriggerAnalysis.fromJson(Map<String, dynamic> json) {
    return TriggerAnalysis(
      hasData: json['hasData'] ?? false,
      topTriggers: (json['topTriggers'] as List? ?? [])
          .map((t) => TriggerInsight.fromJson(t))
          .toList(),
      correlations: (json['correlations'] as List? ?? [])
          .map((c) => TriggerCorrelation.fromJson(c))
          .toList(),
    );
  }
}

// ─── Recovery Effectiveness ───────────────────────────────────────────────────

class RecoveryToolStat {
  final String name;
  final int usageCount;
  final int helpedPercent;

  const RecoveryToolStat({
    required this.name,
    required this.usageCount,
    required this.helpedPercent,
  });

  factory RecoveryToolStat.fromJson(Map<String, dynamic> json) {
    return RecoveryToolStat(
      name: json['name'] ?? '',
      usageCount: json['usageCount'] ?? 0,
      helpedPercent: json['helpedPercent'] ?? 0,
    );
  }
}

class RecoveryEffectiveness {
  final bool hasData;
  final List<RecoveryToolStat> tools;
  final String? bestTool;

  const RecoveryEffectiveness({
    required this.hasData,
    this.tools = const [],
    this.bestTool,
  });

  factory RecoveryEffectiveness.fromJson(Map<String, dynamic> json) {
    return RecoveryEffectiveness(
      hasData: json['hasData'] ?? false,
      tools: (json['tools'] as List? ?? [])
          .map((t) => RecoveryToolStat.fromJson(t))
          .toList(),
      bestTool: json['bestTool'],
    );
  }
}

// ─── Weekly Insights ──────────────────────────────────────────────────────────

class WeeklyInsightItem {
  final String type;
  final String icon;
  final String title;
  final String subtitle;

  const WeeklyInsightItem({
    required this.type,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  factory WeeklyInsightItem.fromJson(Map<String, dynamic> json) {
    return WeeklyInsightItem(
      type: json['type'] ?? 'info',
      icon: json['icon'] ?? 'auto_awesome',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
    );
  }
}

class WeeklyInsights {
  final List<WeeklyInsightItem> insights;
  final DateTime? generatedAt;

  const WeeklyInsights({this.insights = const [], this.generatedAt});

  factory WeeklyInsights.fromJson(Map<String, dynamic> json) {
    return WeeklyInsights(
      insights: (json['insights'] as List?)?.map((i) => WeeklyInsightItem.fromJson(i)).toList() ?? [],
      generatedAt: json['generatedAt'] != null ? DateTime.tryParse(json['generatedAt']) : null,
    );
  }
}

class ReflectionHighlight {
  final String category;
  final String quote;
  final String color;

  const ReflectionHighlight({required this.category, required this.quote, required this.color});

  factory ReflectionHighlight.fromJson(Map<String, dynamic> json) {
    return ReflectionHighlight(
      category: json['category'] ?? 'Reflection',
      quote: json['quote'] ?? '',
      color: json['color'] ?? '#938EA1',
    );
  }
}

class ReflectionHighlightsData {
  final bool hasData;
  final List<ReflectionHighlight> highlights;

  const ReflectionHighlightsData({required this.hasData, this.highlights = const []});

  factory ReflectionHighlightsData.fromJson(Map<String, dynamic> json) {
    return ReflectionHighlightsData(
      hasData: json['hasData'] ?? false,
      highlights: (json['highlights'] as List?)?.map((i) => ReflectionHighlight.fromJson(i)).toList() ?? [],
    );
  }
}

class NovaSuggestion {
  final String title;
  final String body;
  final String actionLabel;
  final String actionRoute;

  const NovaSuggestion({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.actionRoute,
  });

  factory NovaSuggestion.fromJson(Map<String, dynamic> json) {
    return NovaSuggestion(
      title: json['title'] ?? 'Nova Suggests',
      body: json['body'] ?? '',
      actionLabel: json['actionLabel'] ?? 'Continue',
      actionRoute: json['actionRoute'] ?? '/',
    );
  }
}

// ─── History Timeline Entry ───────────────────────────────────────────────────

class MoodHistoryEntry {
  final String id;
  final String moodName;
  final String category;
  final String intensity;
  final List<String> tags;
  final String? notes;
  final bool aiSafetyFlag;
  final List<Map<String, dynamic>> followUpAnswers;
  final DateTime createdAt;
  final String emoji;
  final String color;

  const MoodHistoryEntry({
    required this.id,
    required this.moodName,
    required this.category,
    required this.intensity,
    required this.tags,
    this.notes,
    required this.aiSafetyFlag,
    required this.followUpAnswers,
    required this.createdAt,
    required this.emoji,
    required this.color,
  });

  factory MoodHistoryEntry.fromJson(Map<String, dynamic> json) {
    return MoodHistoryEntry(
      id: json['id'] ?? json['_id'] ?? '',
      moodName: json['moodName'] ?? '',
      category: json['category'] ?? 'neutral',
      intensity: json['intensity'] ?? 'moderate',
      tags: List<String>.from(json['tags'] ?? []),
      notes: json['notes'],
      aiSafetyFlag: json['aiSafetyFlag'] ?? false,
      followUpAnswers: List<Map<String, dynamic>>.from(json['followUpAnswers'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      emoji: json['emoji'] ?? '😐',
      color: json['color'] ?? '#9CA3AF',
    );
  }
}

class PagedMoodHistory {
  final List<MoodHistoryEntry> data;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  const PagedMoodHistory({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory PagedMoodHistory.fromJson(Map<String, dynamic> json) {
    return PagedMoodHistory(
      data: (json['data'] as List? ?? [])
          .map((e) => MoodHistoryEntry.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      hasMore: json['hasMore'] ?? false,
    );
  }
}
