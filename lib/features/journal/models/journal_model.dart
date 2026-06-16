class JournalEntry {
  final String id;
  final String userId;
  final String? title;
  final String content;
  final String? moodState;
  final String journalType;
  final int wordCount;
  
  final bool isFavorite;
  final bool isPinned;
  final bool isDraft;
  final bool isLocked;
  final DateTime? draftUpdatedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final List<JournalTag> tags;
  final List<JournalMedia> media;
  final List<JournalAiInsight> aiInsights;
  final List<JournalEntry>? relatedEntries;

  JournalEntry({
    required this.id,
    required this.userId,
    this.title,
    required this.content,
    this.moodState,
    this.journalType = 'FREE_WRITE',
    this.wordCount = 0,
    this.isFavorite = false,
    this.isPinned = false,
    this.isDraft = false,
    this.isLocked = false,
    this.draftUpdatedAt,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.media = const [],
    this.aiInsights = const [],
    this.relatedEntries,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'],
      content: json['content'] ?? '',
      moodState: json['moodState'],
      journalType: json['journalType'] ?? 'FREE_WRITE',
      wordCount: json['wordCount'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      isPinned: json['isPinned'] ?? false,
      isDraft: json['isDraft'] ?? false,
      isLocked: json['isLocked'] ?? false,
      draftUpdatedAt: json['draftUpdatedAt'] != null ? DateTime.parse(json['draftUpdatedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      tags: (json['tags'] as List?)?.map((e) => JournalTag.fromJson(e)).toList() ?? [],
      media: (json['media'] as List?)?.map((e) => JournalMedia.fromJson(e)).toList() ?? [],
      aiInsights: (json['aiInsights'] as List?)?.map((e) => JournalAiInsight.fromJson(e)).toList() ?? [],
      relatedEntries: (json['relatedEntries'] as List?)?.map((e) => JournalEntry.fromJson(e)).toList(),
    );
  }

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? moodState,
    String? journalType,
    int? wordCount,
    bool? isFavorite,
    bool? isPinned,
    bool? isDraft,
    bool? isLocked,
    DateTime? draftUpdatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<JournalTag>? tags,
    List<JournalMedia>? media,
    List<JournalAiInsight>? aiInsights,
    List<JournalEntry>? relatedEntries,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      moodState: moodState ?? this.moodState,
      journalType: journalType ?? this.journalType,
      wordCount: wordCount ?? this.wordCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      isDraft: isDraft ?? this.isDraft,
      isLocked: isLocked ?? this.isLocked,
      draftUpdatedAt: draftUpdatedAt ?? this.draftUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      media: media ?? this.media,
      aiInsights: aiInsights ?? this.aiInsights,
      relatedEntries: relatedEntries ?? this.relatedEntries,
    );
  }
}

class JournalTag {
  final String id;
  final String name;

  JournalTag({required this.id, required this.name});

  factory JournalTag.fromJson(Map<String, dynamic> json) {
    return JournalTag(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class JournalMedia {
  final String id;
  final String type;
  final String url;
  final int? duration;

  JournalMedia({required this.id, required this.type, required this.url, this.duration});

  factory JournalMedia.fromJson(Map<String, dynamic> json) {
    return JournalMedia(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      duration: json['duration'],
    );
  }
}

class JournalAiInsight {
  final String id;
  final String tone;
  final double? emotionalScore;
  final String? summary;
  final List<String> detectedTriggers;
  final String? suggestedAction;

  JournalAiInsight({
    required this.id,
    required this.tone,
    this.emotionalScore,
    this.summary,
    this.detectedTriggers = const [],
    this.suggestedAction,
  });

  factory JournalAiInsight.fromJson(Map<String, dynamic> json) {
    return JournalAiInsight(
      id: json['id'] ?? '',
      tone: json['tone'] ?? '',
      emotionalScore: json['emotionalScore']?.toDouble(),
      summary: json['summary'],
      detectedTriggers: (json['detectedTriggers'] as List?)?.map((e) => e.toString()).toList() ?? [],
      suggestedAction: json['suggestedAction'],
    );
  }
}

class JournalAnalytics {
  final int currentStreak;
  final int longestStreak;
  final int totalEntries;
  final String mostCommonMood;
  final double emotionalTrendScore;

  JournalAnalytics({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalEntries = 0,
    this.mostCommonMood = 'Neutral',
    this.emotionalTrendScore = 3.0,
  });

  factory JournalAnalytics.fromJson(Map<String, dynamic> json) {
    return JournalAnalytics(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalEntries: json['totalEntries'] ?? 0,
      mostCommonMood: json['mostCommonMood'] ?? 'Neutral',
      emotionalTrendScore: json['emotionalTrendScore']?.toDouble() ?? 3.0,
    );
  }
}
