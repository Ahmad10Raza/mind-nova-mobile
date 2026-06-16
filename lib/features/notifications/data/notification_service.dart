import '../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  // ══════════════════════════════════════════════════
  //  INBOX
  // ══════════════════════════════════════════════════

  Future<Map<String, dynamic>> getNotifications({int page = 1, int limit = 20}) async {
    final response = await _apiClient.get(
      '/notifications',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data;
    final notifications = (data['notifications'] as List)
        .map((n) => AppNotification.fromJson(n))
        .toList();
    return {
      'notifications': notifications,
      'total': data['total'],
      'unreadCount': data['unreadCount'],
    };
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(
      '/notifications',
      queryParameters: {'page': 1, 'limit': 1},
    );
    return response.data['unreadCount'] as int? ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.patch('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.patch('/notifications/read-all');
  }

  Future<void> deleteNotification(String id) async {
    await _apiClient.dio.delete('/notifications/$id');
  }

  // ══════════════════════════════════════════════════
  //  PREFERENCES
  // ══════════════════════════════════════════════════

  Future<NotificationPreference> getPreferences() async {
    final response = await _apiClient.get('/notifications/preferences');
    return NotificationPreference.fromJson(response.data);
  }

  Future<NotificationPreference> updatePreferences(Map<String, dynamic> updates) async {
    final response = await _apiClient.patch('/notifications/preferences', data: updates);
    return NotificationPreference.fromJson(response.data);
  }
}
