import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/post_model.dart';

class CommunityFeedService {
  final ApiClient _apiClient;

  CommunityFeedService(this._apiClient);

  Dio get _dio => _apiClient.dio;

  // ─── Feed ──────────────────────────────────────────────────────────────────

  Future<List<FeedPost>> getFeed({
    String tab = 'FOR_YOU',
    String? emotion,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{
        'tab': tab,
        'page': page,
        'limit': limit,
      };
      if (emotion != null) params['emotion'] = emotion;

      final response = await _dio.get('/community/feed', queryParameters: params);
      return (response.data as List).map((json) => FeedPost.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load feed');
    }
  }

  Future<List<FeedPost>> getPersonalizedFeed({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/community/feed/personalized', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return (response.data as List).map((json) => FeedPost.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load personalized feed');
    }
  }

  // ─── Create Post ───────────────────────────────────────────────────────────

  Future<FeedPost> createPost({
    required String content,
    required String emotion,
    String type = 'STANDARD',
    String? needType,
    List<String>? tags,
    bool isAnonymous = true,
  }) async {
    final response = await _dio.post('/community/post/create', data: {
      'content': content,
      'emotion': emotion,
      'type': type,
      if (needType != null) 'needType': needType,
      if (tags != null) 'tags': tags,
      'isAnonymous': isAnonymous,
    });
    return FeedPost.fromJson(response.data);
  }

  // ─── Post Detail ───────────────────────────────────────────────────────────

  Future<FeedPost> getPost(String postId) async {
    final response = await _dio.get('/community/post/$postId');
    return FeedPost.fromJson(response.data);
  }

  // ─── Reactions ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> toggleReaction(String postId, String type) async {
    final response = await _dio.post('/community/post/react', data: {
      'postId': postId,
      'type': type,
    });
    return Map<String, dynamic>.from(response.data);
  }

  // ─── Comments ──────────────────────────────────────────────────────────────

  Future<PostCommentModel> addComment(String postId, String content, {String? parentId, bool isAnonymous = true}) async {
    final response = await _dio.post('/community/post/comment', data: {
      'postId': postId,
      'content': content,
      if (parentId != null) 'parentId': parentId,
      'isAnonymous': isAnonymous,
    });
    return PostCommentModel.fromJson(response.data);
  }

  Future<List<PostCommentModel>> getComments(String postId) async {
    final response = await _dio.get('/community/post/$postId/comments');
    return (response.data as List).map((json) => PostCommentModel.fromJson(json)).toList();
  }

  // ─── Bookmark ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> toggleBookmark(String postId) async {
    final response = await _dio.post('/community/post/bookmark', data: {'postId': postId});
    return Map<String, dynamic>.from(response.data);
  }

  // ─── Report ────────────────────────────────────────────────────────────────

  Future<void> reportPost(String postId, String reason) async {
    await _dio.post('/community/post/report', data: {
      'postId': postId,
      'reason': reason,
    });
  }

  // ─── Insights ──────────────────────────────────────────────────────────────

  Future<CommunityInsights> getInsights() async {
    final response = await _dio.get('/community/feed/insights');
    return CommunityInsights.fromJson(response.data);
  }

  Future<Map<String, dynamic>> getDailyPrompt() async {
    final response = await _dio.get('/community/feed/daily-prompt');
    return Map<String, dynamic>.from(response.data);
  }
}
