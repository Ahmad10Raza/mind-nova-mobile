import '../../../core/network/api_client.dart';
import '../models/community_post_model.dart';
import '../models/community_comment_model.dart';
import '../models/community_insight_model.dart';
import '../models/community_room_model.dart';

class CommunityService {
  final ApiClient _apiClient;

  CommunityService(this._apiClient);

  Future<List<CommunityComment>> getComments(String postId) async {
    try {
      final response = await _apiClient.get('/community/post/$postId/comments');
      if (response.data is List) {
        return (response.data as List).map((json) => CommunityComment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  Future<void> addComment(String postId, String content, {bool isAnonymous = true}) async {
    try {
      await _apiClient.post('/community/post/comment', data: {
        'postId': postId,
        'content': content,
        'isAnonymous': isAnonymous,
      });
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<List<CommunityPost>> getFeed({int page = 1, int limit = 20, String tab = 'FOR_YOU'}) async {
    try {
      final response = await _apiClient.get('/community/feed', queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        'tab': tab,
      });
      if (response.data is List) {
        return (response.data as List).map((json) => CommunityPost.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load community feed: $e');
    }
  }

  Future<CommunityInsight> getInsights() async {
    try {
      final response = await _apiClient.get('/community/feed/insights');
      return CommunityInsight.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load community insights: $e');
    }
  }

  Future<List<CommunityRoom>> getLiveRooms() async {
    try {
      final response = await _apiClient.get('/community/rooms/live');
      if (response.data is List) {
        return (response.data as List).map((json) => CommunityRoom.fromJson(json)).toList();
      } else if (response.data is Map && response.data['data'] is List) {
        return (response.data['data'] as List).map((json) => CommunityRoom.fromJson(json)).toList();
      } else if (response.data is Map && response.data['success'] == true) {
        // Just in case data is directly inside the object
        return [];
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load live rooms: $e');
    }
  }

  Future<List<CommunityRoom>> getUpcomingRooms() async {
    try {
      final response = await _apiClient.get('/community/rooms/upcoming');
      if (response.data is List) {
        return (response.data as List).map((json) => CommunityRoom.fromJson(json)).toList();
      } else if (response.data is Map && response.data['data'] is List) {
        return (response.data['data'] as List).map((json) => CommunityRoom.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load upcoming rooms: $e');
    }
  }

  Future<void> toggleReaction(String postId, String type) async {
    try {
      await _apiClient.post('/community/post/react', data: {
        'postId': postId,
        'type': type,
      });
    } catch (e) {
      throw Exception('Failed to toggle reaction: $e');
    }
  }

  Future<void> createPost({
    required String content,
    required String emotion,
    String type = 'STANDARD',
    bool isAnonymous = true,
  }) async {
    try {
      await _apiClient.post('/community/post/create', data: {
        'content': content,
        'emotion': emotion,
        'type': type,
        'isAnonymous': isAnonymous,
      });
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  Future<Map<String, dynamic>> joinRoom(String roomId, {bool isAnonymous = true}) async {
    try {
      final response = await _apiClient.post('/community/rooms/join', data: {
        'roomId': roomId,
        'isAnonymous': isAnonymous,
      });
      return response.data is Map<String, dynamic> ? response.data : {};
    } catch (e) {
      throw Exception('Failed to join room: $e');
    }
  }

  Future<Map<String, dynamic>> setReminder(String roomId) async {
    try {
      final response = await _apiClient.post('/community/rooms/reminder', data: {
        'roomId': roomId,
      });
      return response.data is Map<String, dynamic> ? response.data : {};
    } catch (e) {
      throw Exception('Failed to set reminder: $e');
    }
  }

  Future<CommunityRoom> getRoom(String roomId) async {
    try {
      final response = await _apiClient.get('/community/rooms/$roomId');
      return CommunityRoom.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get room: $e');
    }
  }
}
