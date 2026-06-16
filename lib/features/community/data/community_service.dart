import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/room_model.dart';

class CommunityService {
  final ApiClient _apiClient;

  CommunityService(this._apiClient);

  Dio get _dio => _apiClient.dio;

  Future<List<CommunityRoom>> getLiveRooms() async {
    try {
      final response = await _dio.get('/community/rooms/live');
      return (response.data as List)
          .map((json) => CommunityRoom.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load live rooms');
    }
  }

  Future<List<CommunityRoom>> getUpcomingRooms() async {
    try {
      final response = await _dio.get('/community/rooms/upcoming');
      return (response.data as List)
          .map((json) => CommunityRoom.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load upcoming rooms');
    }
  }

  Future<void> joinRoom(String roomId, {bool isAnonymous = true}) async {
    await _dio.post('/community/rooms/join', data: {
      'roomId': roomId,
      'isAnonymous': isAnonymous,
    });
  }

  Future<void> leaveRoom(String roomId) async {
    await _dio.post('/community/rooms/leave', data: {
      'roomId': roomId,
    });
  }

  Future<List<Map<String, dynamic>>> getRoomSeries() async {
    final response = await _apiClient.get('/community/rooms/series');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> setReminder(String roomId) async {
    await _dio.post('/community/rooms/reminder', data: {
      'roomId': roomId,
    });
  }

  Future<void> submitFeedback(String roomId, String feeling, {String? notes}) async {
    await _dio.post('/community/rooms/feedback', data: {
      'roomId': roomId,
      'feeling': feeling,
      if (notes != null) 'notes': notes,
    });
  }

  Future<Map<String, dynamic>> getRoomDetails(String roomId) async {
    try {
      final response = await _dio.get('/community/rooms/$roomId');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Failed to load room details');
    }
  }

  Future<void> endRoom(String roomId) async {
    await _dio.post('/community/rooms/end', data: {
      'roomId': roomId,
    });
  }

  Future<void> postAnnouncement(String roomId, String message) async {
    await _dio.post('/community/rooms/announce', data: {
      'roomId': roomId,
      'message': message,
    });
  }

  Future<void> toggleMuteChat(String roomId, bool muted) async {
    await _dio.post('/community/rooms/mute-chat', data: {
      'roomId': roomId,
      'muted': muted,
    });
  }

  Future<void> removeParticipant(String roomId, String participantId) async {
    await _dio.post('/community/rooms/remove-participant', data: {
      'roomId': roomId,
      'participantId': participantId,
    });
  }
}
