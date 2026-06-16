import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/community_service.dart';
import '../models/community_post_model.dart';
import '../models/community_insight_model.dart';
import '../models/community_room_model.dart';

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

final communityFeedProvider = FutureProvider<List<CommunityPost>>((ref) async {
  final service = ref.watch(communityServiceProvider);
  final tab = ref.watch(communityFeedTabProvider);
  return service.getFeed(page: 1, limit: 20, tab: tab);
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
