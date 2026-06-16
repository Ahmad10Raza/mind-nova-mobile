class GratitudeEntry {
  final String id;
  final String userId;
  final String? content;
  final String? category;
  final List<String> tags;
  final String? moodState;
  final bool isFavorite;
  final DateTime createdAt;
  final List<GratitudeMemory> memories;

  GratitudeEntry({
    required this.id,
    required this.userId,
    this.content,
    this.category,
    this.tags = const [],
    this.moodState,
    this.isFavorite = false,
    required this.createdAt,
    this.memories = const [],
  });

  factory GratitudeEntry.fromJson(Map<String, dynamic> json) {
    return GratitudeEntry(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      content: json['content'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      moodState: json['moodState'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      memories: json['memories'] != null 
        ? (json['memories'] as List).map((i) => GratitudeMemory.fromJson(i)).toList() 
        : const [],
    );
  }

  GratitudeEntry copyWith({
    String? id,
    String? userId,
    String? content,
    String? category,
    List<String>? tags,
    String? moodState,
    bool? isFavorite,
    DateTime? createdAt,
    List<GratitudeMemory>? memories,
  }) {
    return GratitudeEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      moodState: moodState ?? this.moodState,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      memories: memories ?? this.memories,
    );
  }
}

class GratitudeMemory {
  final String id;
  final String? gratitudeEntryId;
  final String type;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? emotionalLabel;
  final DateTime createdAt;
  final GratitudeEntry? entry;

  GratitudeMemory({
    required this.id,
    this.gratitudeEntryId,
    required this.type,
    this.mediaUrl,
    this.thumbnailUrl,
    this.emotionalLabel,
    required this.createdAt,
    this.entry,
  });

  factory GratitudeMemory.fromJson(Map<String, dynamic> json) {
    return GratitudeMemory(
      id: json['id'] as String? ?? '',
      gratitudeEntryId: json['gratitudeEntryId'] as String?,
      type: json['type'] as String? ?? 'TEXT',
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      emotionalLabel: json['emotionalLabel'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      entry: json['entry'] != null ? GratitudeEntry.fromJson(json['entry']) : null,
    );
  }
}

class GratitudeAnalytics {
  final int currentStreak;
  final int longestStreak;
  final int totalEntries;
  final int moodLiftScore;
  final String moodLiftMessage;

  GratitudeAnalytics({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalEntries = 0,
    this.moodLiftScore = 0,
    this.moodLiftMessage = "Keep journaling to unlock mood insights.",
  });

  factory GratitudeAnalytics.fromJson(Map<String, dynamic> json) {
    return GratitudeAnalytics(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      totalEntries: json['totalEntries'] as int? ?? 0,
      moodLiftScore: json['moodLiftScore'] as int? ?? 0,
      moodLiftMessage: json['moodLiftMessage'] as String? ?? "Keep journaling to unlock mood insights.",
    );
  }
}

class GratitudeCategoryStat {
  final String name;
  final int count;

  GratitudeCategoryStat({
    required this.name,
    required this.count,
  });

  factory GratitudeCategoryStat.fromJson(Map<String, dynamic> json) {
    return GratitudeCategoryStat(
      name: json['name'] as String? ?? 'Unknown',
      count: json['count'] as int? ?? 0,
    );
  }
}
