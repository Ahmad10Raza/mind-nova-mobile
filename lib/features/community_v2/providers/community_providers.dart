import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/community_service.dart';
import '../models/community_post_model.dart';
import '../models/community_insight_model.dart';
import '../models/community_room_model.dart';
import '../models/community_comment_model.dart';

final communityServiceProvider = Provider<CommunityService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CommunityService(apiClient);
});

class CommunityFeedTabNotifier extends Notifier<String> {
  @override
  String build() => 'FOR_YOU';

  void setTab(String tab) {
    state = tab;
  }
}

final communityFeedTabProvider = NotifierProvider<CommunityFeedTabNotifier, String>(() {
  return CommunityFeedTabNotifier();
});

class CommunityFeedNotifier extends AsyncNotifier<List<CommunityPost>> {
  int _currentPage = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  @override
  Future<List<CommunityPost>> build() async {
    _currentPage = 1;
    hasMore = true;
    isLoadingMore = false;
    final tab = ref.watch(communityFeedTabProvider);
    final service = ref.watch(communityServiceProvider);
    
    final posts = await service.getFeed(page: _currentPage, limit: 20, tab: tab);
    hasMore = posts.length >= 20;
    return posts;
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;
    
    isLoadingMore = true;
    final currentPosts = state.value ?? [];
    state = AsyncData([...currentPosts]); // Force rebuild to show loader
    
    try {
      final service = ref.read(communityServiceProvider);
      final tab = ref.read(communityFeedTabProvider);
      
      final nextPosts = await service.getFeed(page: _currentPage + 1, limit: 20, tab: tab);
      _currentPage++;
      
      hasMore = nextPosts.length >= 20;
      
      state = AsyncData([...currentPosts, ...nextPosts]);
    } catch (e, st) {
      // In production, we'd log the error or show a toast. For now, keep existing data.
    } finally {
      isLoadingMore = false;
      state = AsyncData([...state.value ?? []]); // Force rebuild to hide loader
    }
  }
}

final communityFeedProvider = AsyncNotifierProvider<CommunityFeedNotifier, List<CommunityPost>>(() {
  return CommunityFeedNotifier();
});

final communityInsightsProvider = FutureProvider<CommunityInsight>((ref) async {
  final service = ref.watch(communityServiceProvider);
  return service.getInsights();
});

final liveCirclesProvider = FutureProvider.autoDispose<List<CommunityRoom>>((ref) async {
  final service = ref.watch(communityServiceProvider);
  return service.getLiveRooms();
});

final upcomingCirclesProvider = FutureProvider.autoDispose<List<CommunityRoom>>((ref) async {
  final service = ref.watch(communityServiceProvider);
  return service.getUpcomingRooms();
});

final liveRoomDetailProvider = FutureProvider.family.autoDispose<CommunityRoom, String>((ref, roomId) async {
  final service = ref.watch(communityServiceProvider);
  return service.getRoom(roomId);
});

// A simple notifier for toggling reactions locally immediately
class PostReactionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> toggleReaction(String postId, String type) async {
    final service = ref.read(communityServiceProvider);
    try {
      state = const AsyncLoading();
      await service.toggleReaction(postId, type);
      // Refresh the feed quietly to get new counts
      ref.invalidate(communityFeedProvider);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final postReactionProvider = NotifierProvider<PostReactionNotifier, AsyncValue<void>>(() {
  return PostReactionNotifier();
});

final postCommentsProvider = FutureProvider.family<List<CommunityComment>, String>((ref, postId) async {
  final service = ref.watch(communityServiceProvider);
  return service.getComments(postId);
});

class CommentSubmitNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> submitComment(String postId, String content, {bool isAnonymous = true}) async {
    final service = ref.read(communityServiceProvider);
    try {
      state = const AsyncLoading();
      await service.addComment(postId, content, isAnonymous: isAnonymous);
      ref.invalidate(postCommentsProvider(postId));
      ref.invalidate(communityFeedProvider);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final commentSubmitProvider = NotifierProvider<CommentSubmitNotifier, AsyncValue<void>>(() {
  return CommentSubmitNotifier();
});
