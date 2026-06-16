import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';

class NotificationInboxScreen extends ConsumerWidget {
  const NotificationInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(notificationInboxProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1C1E),
          ),
        ),
        actions: [
          if (inbox.unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationInboxProvider.notifier).markAllAsRead(),
              child: Text(
                'Read All',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5E4B8B),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Color(0xFF8E8E93), size: 22),
            onPressed: () => context.push('/notification-settings'),
          ),
        ],
      ),
      body: inbox.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5E4B8B)))
          : inbox.error != null
              ? _buildErrorState(ref, inbox.error!)
              : inbox.notifications.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: const Color(0xFF5E4B8B),
                      onRefresh: () => ref.read(notificationInboxProvider.notifier).fetchNotifications(),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: inbox.notifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationTile(context, ref, inbox.notifications[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, WidgetRef ref, AppNotification notification) {
    final timeAgo = _formatTimeAgo(notification.createdAt);
    final iconData = _categoryIcon(notification.category);
    final iconColor = _categoryColor(notification.category);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(notificationInboxProvider.notifier).deleteNotification(notification.id);
      },
      child: GestureDetector(
        onTap: () {
          // Mark as read
          if (!notification.isRead) {
            ref.read(notificationInboxProvider.notifier).markAsRead(notification.id);
          }
          // Navigate via deep link
          if (notification.deepLink != null && notification.deepLink!.isNotEmpty) {
            context.push(notification.deepLink!);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.shade100
                  : const Color(0xFF5E4B8B).withOpacity(0.15),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                              color: const Color(0xFF1C1C1E),
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF5E4B8B),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF8E8E93),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeAgo,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no notifications right now.',
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text('Could not load notifications', style: GoogleFonts.inter(fontSize: 14)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.read(notificationInboxProvider.notifier).fetchNotifications(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'MOOD': return Icons.emoji_emotions_rounded;
      case 'SLEEP': return Icons.bedtime_rounded;
      case 'ASSESSMENT': return Icons.assignment_rounded;
      case 'REPORT': return Icons.auto_awesome_rounded;
      case 'CRISIS': return Icons.emergency_rounded;
      case 'THERAPY': return Icons.person_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'MOOD': return const Color(0xFFF57F17);
      case 'SLEEP': return const Color(0xFF7C4DFF);
      case 'ASSESSMENT': return const Color(0xFF4CAF50);
      case 'REPORT': return const Color(0xFF00D2FF);
      case 'CRISIS': return const Color(0xFFFF1744);
      case 'THERAPY': return const Color(0xFF5E4B8B);
      default: return const Color(0xFF8E8E93);
    }
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }
}
