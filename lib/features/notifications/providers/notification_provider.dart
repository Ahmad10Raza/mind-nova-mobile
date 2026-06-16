import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/notification_service.dart';
import '../models/notification_model.dart';

// Service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationService(apiClient);
});

// Badge count provider (lightweight, for the bell icon)
final unreadCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  try {
    return await service.getUnreadCount();
  } catch (_) {
    return 0;
  }
});

// Full inbox state
class NotificationInboxState {
  final List<AppNotification> notifications;
  final int total;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  NotificationInboxState({
    this.notifications = const [],
    this.total = 0,
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationInboxState copyWith({
    List<AppNotification>? notifications,
    int? total,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationInboxState(
      notifications: notifications ?? this.notifications,
      total: total ?? this.total,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationInboxNotifier extends Notifier<NotificationInboxState> {
  @override
  NotificationInboxState build() {
    // Auto-fetch on creation
    Future.microtask(() => fetchNotifications());
    return NotificationInboxState(isLoading: true);
  }

  Future<void> fetchNotifications({int page = 1}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(notificationServiceProvider);
      final result = await service.getNotifications(page: page);
      state = state.copyWith(
        notifications: result['notifications'] as List<AppNotification>,
        total: result['total'] as int,
        unreadCount: result['unreadCount'] as int,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final service = ref.read(notificationServiceProvider);
      await service.markAsRead(id);
      final updated = state.notifications.map((n) {
        if (n.id == id) {
          return AppNotification(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            category: n.category,
            priority: n.priority,
            deepLink: n.deepLink,
            scheduledAt: n.scheduledAt,
            readAt: DateTime.now(),
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      state = state.copyWith(
        notifications: updated,
        unreadCount: (state.unreadCount - 1).clamp(0, state.total),
      );
      ref.invalidate(unreadCountProvider);
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final service = ref.read(notificationServiceProvider);
      await service.markAllAsRead();
      final updated = state.notifications.map((n) {
        return AppNotification(
          id: n.id,
          type: n.type,
          title: n.title,
          body: n.body,
          category: n.category,
          priority: n.priority,
          deepLink: n.deepLink,
          scheduledAt: n.scheduledAt,
          readAt: n.readAt ?? DateTime.now(),
          createdAt: n.createdAt,
        );
      }).toList();
      state = state.copyWith(notifications: updated, unreadCount: 0);
      ref.invalidate(unreadCountProvider);
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    try {
      final service = ref.read(notificationServiceProvider);
      await service.deleteNotification(id);
      final updated = state.notifications.where((n) => n.id != id).toList();
      state = state.copyWith(
        notifications: updated,
        total: state.total - 1,
      );
    } catch (_) {}
  }
}

final notificationInboxProvider =
    NotifierProvider<NotificationInboxNotifier, NotificationInboxState>(() {
  return NotificationInboxNotifier();
});

// Preferences provider
final notificationPreferencesProvider = FutureProvider<NotificationPreference>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getPreferences();
});
