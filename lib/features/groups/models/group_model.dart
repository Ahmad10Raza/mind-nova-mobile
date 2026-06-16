import 'package:flutter/foundation.dart';

enum GroupRole { admin, moderator, member }
enum OnboardingStatus { pending, completed }

class GroupModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String type;
  final int maxMembers;
  final String? imageUrl;
  final bool isPrivate;
  final bool isApprovalRequired;
  final String? rules;
  final String? welcomeMessage;
  final double healthScore;
  final bool slowModeEnabled;
  final int slowModeSeconds;
  final int memberCount;
  final bool isMember;
  final String onboardingStatus; // PENDING, COMPLETED
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.maxMembers,
    this.imageUrl,
    required this.isPrivate,
    required this.isApprovalRequired,
    this.rules,
    this.welcomeMessage,
    required this.healthScore,
    required this.slowModeEnabled,
    required this.slowModeSeconds,
    required this.memberCount,
    required this.isMember,
    required this.onboardingStatus,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      type: json['type'] ?? 'PEER',
      maxMembers: json['maxMembers'] ?? 50,
      imageUrl: json['imageUrl'],
      isPrivate: json['isPrivate'] ?? false,
      isApprovalRequired: json['isApprovalRequired'] ?? false,
      rules: json['rules'],
      welcomeMessage: json['welcomeMessage'],
      healthScore: (json['healthScore'] ?? 100.0).toDouble(),
      slowModeEnabled: json['slowModeEnabled'] ?? true,
      slowModeSeconds: json['slowModeSeconds'] ?? 30,
      memberCount: json['_count']?['members'] ?? 0,
      isMember: json['isMember'] ?? false,
      onboardingStatus: json['onboardingStatus'] ?? 'PENDING',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class GroupMemberModel {
  final String id;
  final String groupId;
  final String userId;
  final GroupRole role;
  final OnboardingStatus onboardingStatus;
  final String? commitmentLevel;
  final DateTime lastActivityAt;
  final DateTime joinedAt;

  GroupMemberModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.onboardingStatus,
    this.commitmentLevel,
    required this.lastActivityAt,
    required this.joinedAt,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      id: json['id'],
      groupId: json['groupId'],
      userId: json['userId'],
      role: _parseRole(json['role']),
      onboardingStatus: _parseOnboardingStatus(json['onboardingStatus']),
      commitmentLevel: json['commitmentLevel'],
      lastActivityAt: DateTime.parse(json['lastActivityAt']),
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }

  static GroupRole _parseRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN': return GroupRole.admin;
      case 'MODERATOR': return GroupRole.moderator;
      default: return GroupRole.member;
    }
  }

  static OnboardingStatus _parseOnboardingStatus(String status) {
    return status.toUpperCase() == 'COMPLETED' 
      ? OnboardingStatus.completed 
      : OnboardingStatus.pending;
  }
}

class GroupPostModel {
  final String id;
  final String groupId;
  final String userId;
  final String content;
  final String? emotion;
  final bool isAnonymous;
  final int priority;
  final String userName;
  final String? userAvatar;
  final String? backgroundGradient;
  final String? imageUrl;
  final DateTime createdAt;
  final int reactionCount;
  final int commentCount;
  final List<GroupPostReactionInfo> reactions;

  GroupPostModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.content,
    this.emotion,
    required this.isAnonymous,
    required this.priority,
    required this.userName,
    this.userAvatar,
    this.backgroundGradient,
    this.imageUrl,
    required this.createdAt,
    this.reactionCount = 0,
    this.commentCount = 0,
    this.reactions = const [],
  });

  factory GroupPostModel.fromJson(Map<String, dynamic> json) {
    final userProfile = json['user']?['profile'];
    final counts = json['_count'] as Map<String, dynamic>? ?? {};
    final reactionsList = (json['reactions'] as List<dynamic>?) ?? [];

    return GroupPostModel(
      id: json['id'],
      groupId: json['groupId'],
      userId: json['userId'],
      content: json['content'],
      emotion: json['emotion'],
      isAnonymous: json['isAnonymous'] ?? true,
      priority: json['priority'] ?? 0,
      userName: (json['isAnonymous'] ?? true) 
          ? 'Anonymous Member' 
          : (userProfile?['firstName'] ?? 'Member'),
      userAvatar: (json['isAnonymous'] ?? true) ? null : userProfile?['avatarUrl'],
      backgroundGradient: json['backgroundGradient'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      reactionCount: counts['reactions'] ?? 0,
      commentCount: counts['comments'] ?? 0,
      reactions: reactionsList.map((r) => GroupPostReactionInfo.fromJson(r)).toList(),
    );
  }

  int countReaction(String type) {
    return reactions.where((r) => r.type == type).length;
  }

  bool hasUserReacted(String userId, String type) {
    return reactions.any((r) => r.userId == userId && r.type == type);
  }
}

class GroupPostReactionInfo {
  final String type;
  final String userId;

  GroupPostReactionInfo({required this.type, required this.userId});

  factory GroupPostReactionInfo.fromJson(Map<String, dynamic> json) {
    return GroupPostReactionInfo(
      type: json['type'],
      userId: json['userId'],
    );
  }
}

class GroupPostCommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String userName;
  final String? userAvatar;
  final bool isAnonymous;
  final DateTime createdAt;
  final List<GroupPostCommentModel> replies;

  GroupPostCommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.userName,
    this.userAvatar,
    required this.isAnonymous,
    required this.createdAt,
    this.replies = const [],
  });

  factory GroupPostCommentModel.fromJson(Map<String, dynamic> json) {
    final userProfile = json['user']?['profile'];
    return GroupPostCommentModel(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      content: json['content'],
      userName: (json['isAnonymous'] ?? true) 
          ? 'Anonymous' 
          : (userProfile?['firstName'] ?? 'Member'),
      userAvatar: (json['isAnonymous'] ?? true) ? null : userProfile?['avatarUrl'],
      isAnonymous: json['isAnonymous'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((r) => GroupPostCommentModel.fromJson(r))
              .toList() ??
          [],
    );
  }
}

class GroupStatsModel {
  final double participationRate;
  final double healthScore;
  final String? summaryText;
  final int memberCount;
  final int activeToday;

  GroupStatsModel({
    required this.participationRate,
    required this.healthScore,
    this.summaryText,
    required this.memberCount,
    required this.activeToday,
  });

  factory GroupStatsModel.fromJson(Map<String, dynamic> json) {
    return GroupStatsModel(
      participationRate: (json['participationRate'] ?? 0.0).toDouble(),
      healthScore: (json['healthScore'] ?? 100.0).toDouble(),
      summaryText: json['summaryText'],
      memberCount: json['memberCount'] ?? 0,
      activeToday: json['activeToday'] ?? 0,
    );
  }
}
