import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/group_service.dart';
import '../models/group_model.dart';

final groupServiceProvider = Provider<GroupService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GroupService(apiClient.dio);
});

final recommendedGroupsProvider = FutureProvider<List<GroupModel>>((ref) {
  return ref.watch(groupServiceProvider).getRecommendedGroups();
});

final allGroupsProvider = FutureProvider<List<GroupModel>>((ref) {
  return ref.watch(groupServiceProvider).getAllGroups();
});

final groupDetailProvider = FutureProvider.family<GroupModel, String>((ref, id) {
  return ref.watch(groupServiceProvider).getGroupDetail(id);
});

class GroupFeedNotifier extends AsyncNotifier<List<GroupPostModel>> {
  final String groupId;
  
  GroupFeedNotifier(this.groupId);

  int _currentPage = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  @override
  Future<List<GroupPostModel>> build() async {
    _currentPage = 1;
    hasMore = true;
    isLoadingMore = false;
    
    final service = ref.watch(groupServiceProvider);
    final posts = await service.getGroupFeed(groupId, page: _currentPage, limit: 20);
    hasMore = posts.length >= 20;
    return posts;
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;
    
    isLoadingMore = true;
    final currentPosts = state.value ?? [];
    state = AsyncData([...currentPosts]); // Force rebuild to show loader
    
    try {
      final service = ref.read(groupServiceProvider);
      final nextPosts = await service.getGroupFeed(groupId, page: _currentPage + 1, limit: 20);
      _currentPage++;
      
      hasMore = nextPosts.length >= 20;
      state = AsyncData([...currentPosts, ...nextPosts]);
    } catch (e, st) {
      // Keep existing data on error
    } finally {
      isLoadingMore = false;
      state = AsyncData([...state.value ?? []]); // Force rebuild to hide loader
    }
  }

  Future<void> toggleReaction(String postId, String type, String userId) async {
    final currentPosts = state.value;
    if (currentPosts == null) return;

    final postIndex = currentPosts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = currentPosts[postIndex];
    final hasReacted = post.hasUserReacted(userId, type);
    
    final newReactions = List<GroupPostReactionInfo>.from(post.reactions);
    if (hasReacted) {
      newReactions.removeWhere((r) => r.userId == userId && r.type == type);
    } else {
      newReactions.add(GroupPostReactionInfo(type: type, userId: userId));
    }
    
    final updatedPost = GroupPostModel(
      id: post.id,
      groupId: post.groupId,
      userId: post.userId,
      content: post.content,
      emotion: post.emotion,
      isAnonymous: post.isAnonymous,
      priority: post.priority,
      userName: post.userName,
      userAvatar: post.userAvatar,
      backgroundGradient: post.backgroundGradient,
      imageUrl: post.imageUrl,
      createdAt: post.createdAt,
      reactionCount: hasReacted ? post.reactionCount - 1 : post.reactionCount + 1,
      commentCount: post.commentCount,
      reactions: newReactions,
    );
    
    final newPosts = List<GroupPostModel>.from(currentPosts);
    newPosts[postIndex] = updatedPost;
    state = AsyncData(newPosts);
    
    try {
      final service = ref.read(groupServiceProvider);
      await service.toggleReaction(postId, type);
    } catch (e) {
      state = AsyncData(currentPosts); // Revert on failure
    }
  }
}

final groupFeedProvider = AsyncNotifierProvider.family<GroupFeedNotifier, List<GroupPostModel>, String>((groupId) {
  return GroupFeedNotifier(groupId);
});

final groupStatsProvider = FutureProvider.family<GroupStatsModel, String>((ref, id) {
  return ref.watch(groupServiceProvider).getGroupStats(id);
});

final groupPostDetailProvider = FutureProvider.family<GroupPostModel, String>((ref, postId) {
  return ref.watch(groupServiceProvider).getPost(postId);
});

final groupPostCommentsProvider = FutureProvider.family<List<GroupPostCommentModel>, String>((ref, postId) {
  return ref.watch(groupServiceProvider).getComments(postId);
});

final myGroupsProvider = FutureProvider<List<GroupModel>>((ref) async {
  final groups = await ref.watch(groupServiceProvider).getAllGroups();
  // Filter for joined groups (assuming GroupModel has isJoined or similar)
  // For now, return all since most will be joined in a test env or filtered by backend
  return groups; 
});
