import 'package:dio/dio.dart';
import '../../../core/network/network_constants.dart';
import '../models/group_model.dart';

class GroupService {
  final Dio _dio;

  GroupService(this._dio);

  Future<List<GroupModel>> getRecommendedGroups() async {
    final response = await _dio.get('${NetworkConstants.baseUrl}/groups/recommended');
    return (response.data as List).map((e) => GroupModel.fromJson(e)).toList();
  }

  Future<List<GroupModel>> getAllGroups() async {
    final response = await _dio.get('${NetworkConstants.baseUrl}/groups');
    return (response.data as List).map((e) => GroupModel.fromJson(e)).toList();
  }

  Future<GroupModel> getGroupDetail(String id) async {
    final response = await _dio.get('${NetworkConstants.baseUrl}/groups/$id');
    return GroupModel.fromJson(response.data);
  }

  Future<void> joinGroup(String groupId) async {
    await _dio.post(
      '${NetworkConstants.baseUrl}/groups/join',
      data: {'groupId': groupId},
    );
  }

  Future<void> completeOnboarding(String groupId, String commitmentLevel, String goal) async {
    await _dio.post(
      '${NetworkConstants.baseUrl}/groups/$groupId/onboarding',
      data: {
        'commitmentLevel': commitmentLevel,
        'goal': goal,
      },
    );
  }

  Future<void> createPost(
    String groupId, 
    String content, 
    bool isAnonymous, {
    String? backgroundGradient,
    String? imageUrl,
    String? emotion,
  }) async {
    await _dio.post(
      '${NetworkConstants.baseUrl}/groups/$groupId/posts',
      data: {
        'content': content,
        'isAnonymous': isAnonymous,
        if (backgroundGradient != null) 'backgroundGradient': backgroundGradient,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (emotion != null) 'emotion': emotion,
      },
    );
  }

  Future<List<GroupPostModel>> getGroupFeed(String groupId, {int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      '${NetworkConstants.baseUrl}/groups/$groupId/feed',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return (response.data as List).map((e) => GroupPostModel.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getGroupChatHistory(String groupId, {int page = 1, int limit = 50}) async {
    final response = await _dio.get(
      '${NetworkConstants.baseUrl}/groups/$groupId/chat',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<GroupPostModel> getPost(String postId) async {
    final response = await _dio.get('${NetworkConstants.baseUrl}/groups/posts/$postId');
    return GroupPostModel.fromJson(response.data);
  }

  Future<void> checkIn(String groupId, String emotion, String? note, {bool isAnonymous = true}) async {
    await _dio.post(
      '${NetworkConstants.baseUrl}/groups/$groupId/checkin',
      data: {
        'emotion': emotion,
        'note': note,
        'isAnonymous': isAnonymous,
      },
    );
  }

  Future<GroupStatsModel> getGroupStats(String groupId) async {
    final response = await _dio.get('${NetworkConstants.baseUrl}/groups/$groupId/stats');
    return GroupStatsModel.fromJson(response.data);
  }

  Future<void> leaveGroup(String groupId, String reason) async {
    await _dio.delete(
      '${NetworkConstants.baseUrl}/groups/$groupId/leave',
      data: {'reason': reason},
    );
  }

  Future<String> uploadImage(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post(
      '${NetworkConstants.baseUrl}/groups/upload',
      data: formData,
    );

    // Backend returns { url: '/uploads/filename.ext' }
    // We need to prepend the baseUrl
    return '${NetworkConstants.baseUrl}${response.data['url']}';
  }

  Future<void> toggleReaction(String postId, String type) async {
    await _dio.post(
      '${NetworkConstants.baseUrl}/groups/posts/$postId/react',
      data: {'type': type},
    );
  }

  Future<void> addComment(String postId, String content, {bool isAnonymous = true, String? parentId}) async {
    await _dio.post(
      '${NetworkConstants.baseUrl}/groups/posts/$postId/comments',
      data: {
        'content': content,
        'isAnonymous': isAnonymous,
        if (parentId != null) 'parentId': parentId,
      },
    );
  }

  Future<List<GroupPostCommentModel>> getComments(String postId) async {
    final response = await _dio.get('${NetworkConstants.baseUrl}/groups/posts/$postId/comments');
    return (response.data as List).map((e) => GroupPostCommentModel.fromJson(e)).toList();
  }
}
