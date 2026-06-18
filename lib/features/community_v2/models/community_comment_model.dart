class CommunityComment {
  final String id;
  final String postId;
  final String content;
  final String? aliasName;
  final bool isAnonymous;
  final DateTime createdAt;

  CommunityComment({
    required this.id,
    required this.postId,
    required this.content,
    this.aliasName,
    required this.isAnonymous,
    required this.createdAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
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

    return CommunityComment(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      content: json['content'] ?? '',
      aliasName: displayName,
      isAnonymous: isAnonymous,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
