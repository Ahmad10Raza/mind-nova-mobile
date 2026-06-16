class FeedPost {
  final String id;
  final String userId;
  final String? aliasName;
  final String? realName;
  final String content;
  final String emotion;
  final String type; // STANDARD, HELP_ME, GRATITUDE
  final String? needType;
  final List<String> tags;
  final bool isAnonymous;
  final double visibilityScore;
  final bool isFlagged;
  final DateTime createdAt;
  final int reactionCount;
  final int commentCount;
  final int bookmarkCount;
  final List<PostReactionInfo> reactions;

  FeedPost({
    required this.id,
    required this.userId,
    this.aliasName,
    this.realName,
    required this.content,
    required this.emotion,
    required this.type,
    this.needType,
    required this.tags,
    required this.isAnonymous,
    required this.visibilityScore,
    required this.isFlagged,
    required this.createdAt,
    this.reactionCount = 0,
    this.commentCount = 0,
    this.bookmarkCount = 0,
    this.reactions = const [],
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    final counts = json['_count'] as Map<String, dynamic>? ?? {};
    final reactionsList = (json['reactions'] as List<dynamic>?) ?? [];
    
    // Parse real name from user.profile
    String? realName;
    if (json['user'] != null && json['user']['profile'] != null) {
      final p = json['user']['profile'];
      realName = "${p['firstName'] ?? ''} ${p['lastName'] ?? ''}".trim();
      if (realName.isEmpty) realName = null;
    }

    return FeedPost(
      id: json['id'],
      userId: json['userId'],
      aliasName: json['aliasName'],
      realName: realName,
      content: json['content'],
      emotion: json['emotion'],
      type: json['type'] ?? 'STANDARD',
      needType: json['needType'],
      tags: List<String>.from(json['tags'] ?? []),
      isAnonymous: json['isAnonymous'] ?? true,
      visibilityScore: (json['visibilityScore'] ?? 0).toDouble(),
      isFlagged: json['isFlagged'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      reactionCount: counts['reactions'] ?? 0,
      commentCount: counts['comments'] ?? 0,
      bookmarkCount: counts['bookmarks'] ?? 0,
      reactions: reactionsList.map((r) => PostReactionInfo.fromJson(r)).toList(),
    );
  }

  String get displayName => (isAnonymous ? aliasName : realName) ?? 'Anonymous';
  String get emotionEmoji => _emotionEmojis[emotion] ?? '💭';

  static const _emotionEmojis = {
    'SAD': '😔',
    'ANXIOUS': '😰',
    'FRUSTRATED': '😡',
    'TIRED': '😴',
    'HAPPY': '😊',
    'LONELY': '😞',
    'STRESSED': '😓',
  };

  int countReaction(String type) {
    return reactions.where((r) => r.type == type).length;
  }

  bool hasUserReacted(String userId, String type) {
    return reactions.any((r) => r.userId == userId && r.type == type);
  }
}

class PostReactionInfo {
  final String type;
  final String userId;

  PostReactionInfo({required this.type, required this.userId});

  factory PostReactionInfo.fromJson(Map<String, dynamic> json) {
    return PostReactionInfo(
      type: json['type'],
      userId: json['userId'],
    );
  }
}

class PostCommentModel {
  final String id;
  final String postId;
  final String? aliasName;
  final String? realName;
  final String content;
  final bool isAnonymous;
  final DateTime createdAt;
  final List<PostCommentModel> replies;

  PostCommentModel({
    required this.id,
    required this.postId,
    this.aliasName,
    this.realName,
    required this.content,
    required this.isAnonymous,
    required this.createdAt,
    this.replies = const [],
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    // Parse real name from user.profile
    String? realName;
    if (json['user'] != null && json['user']['profile'] != null) {
      final p = json['user']['profile'];
      realName = "${p['firstName'] ?? ''} ${p['lastName'] ?? ''}".trim();
      if (realName.isEmpty) realName = null;
    }

    return PostCommentModel(
      id: json['id'],
      postId: json['postId'],
      aliasName: json['aliasName'],
      realName: realName,
      content: json['content'],
      isAnonymous: json['isAnonymous'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((r) => PostCommentModel.fromJson(r))
              .toList() ??
          [],
    );
  }

  String get displayName => (isAnonymous ? aliasName : realName) ?? 'Anonymous';
}

class CommunityInsights {
  final int totalPostsToday;
  final List<EmotionBreakdown> emotionBreakdown;

  CommunityInsights({required this.totalPostsToday, required this.emotionBreakdown});

  factory CommunityInsights.fromJson(Map<String, dynamic> json) {
    return CommunityInsights(
      totalPostsToday: json['totalPostsToday'] ?? 0,
      emotionBreakdown: (json['emotionBreakdown'] as List<dynamic>?)
              ?.map((e) => EmotionBreakdown.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class EmotionBreakdown {
  final String emotion;
  final int count;

  EmotionBreakdown({required this.emotion, required this.count});

  factory EmotionBreakdown.fromJson(Map<String, dynamic> json) {
    return EmotionBreakdown(
      emotion: json['emotion'],
      count: json['count'] ?? 0,
    );
  }
}
