import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/community_feed_service.dart';
import '../models/post_model.dart';

final communityFeedServiceProvider = Provider<CommunityFeedService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CommunityFeedService(apiClient);
});

final feedProvider = FutureProvider.autoDispose.family<List<FeedPost>, String>((ref, tab) async {
  final service = ref.watch(communityFeedServiceProvider);
  return service.getFeed(tab: tab);
});

final personalizedFeedProvider = FutureProvider.autoDispose<List<FeedPost>>((ref) async {
  final service = ref.watch(communityFeedServiceProvider);
  return service.getPersonalizedFeed();
});

final postDetailProvider = FutureProvider.autoDispose.family<FeedPost, String>((ref, postId) async {
  final service = ref.watch(communityFeedServiceProvider);
  return service.getPost(postId);
});

final postCommentsProvider = FutureProvider.autoDispose.family<List<PostCommentModel>, String>((ref, postId) async {
  final service = ref.watch(communityFeedServiceProvider);
  return service.getComments(postId);
});

final communityInsightsProvider = FutureProvider.autoDispose<CommunityInsights>((ref) async {
  final service = ref.watch(communityFeedServiceProvider);
  return service.getInsights();
});

final dailyPromptProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final service = ref.watch(communityFeedServiceProvider);
  return service.getDailyPrompt();
});
