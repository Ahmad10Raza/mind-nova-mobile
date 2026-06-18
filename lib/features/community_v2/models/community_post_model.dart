class CommunityPost {
  final String id;
  final String content;
  final String emotion;
  final String type;
  final String? aliasName;
  final bool isAnonymous;
  final DateTime createdAt;
  final int commentsCount;
  final int reactionsCount;
  final List<PostReaction> reactions;
  final Map<String, int> reactionCounts;

  CommunityPost({
    required this.id,
    required this.content,
    required this.emotion,
    required this.type,
    this.aliasName,
    required this.isAnonymous,
    required this.createdAt,
    this.commentsCount = 0,
    this.reactionsCount = 0,
    this.reactions = const [],
    this.reactionCounts = const {},
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final rawReactions = json['reactions'] as List<dynamic>? ?? [];
    final List<PostReaction> parsedReactions = rawReactions
        .map((e) => PostReaction.fromJson(e as Map<String, dynamic>))
        .toList();

    // Group reaction counts
    final Map<String, int> counts = {};
    for (var reaction in parsedReactions) {
      counts[reaction.type] = (counts[reaction.type] ?? 0) + 1;
    }

    final bool isAnonymous = json['isAnonymous'] ?? true;
    String? displayName = json['aliasName'];

    if (!isAnonymous && json['user'] != null && json['user']['profile'] != null) {
      final profile = json['user']['profile'];
      final firstName = profile['firstName'] ?? '';
      final lastName = profile['lastName'] ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        displayName = '$firstName $lastName'.trim();
      }
    }

    return CommunityPost(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      emotion: json['emotion'] ?? 'UNKNOWN',
      type: json['type'] ?? 'STANDARD',
      aliasName: displayName,
      isAnonymous: isAnonymous,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      commentsCount: json['_count']?['comments'] ?? 0,
      reactionsCount: json['_count']?['reactions'] ?? 0,
      reactions: parsedReactions,
      reactionCounts: counts,
    );
  }

  bool hasReacted(String type, String currentUserId) {
    return reactions.any((r) => r.type == type && r.userId == currentUserId);
  }
}

class PostReaction {
  final String type;
  final String userId;

  PostReaction({required this.type, required this.userId});

  factory PostReaction.fromJson(Map<String, dynamic> json) {
    return PostReaction(
      type: json['type'] ?? '',
      userId: json['userId'] ?? '',
    );
  }
}
