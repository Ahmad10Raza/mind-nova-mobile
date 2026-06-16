import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/network_constants.dart';

class GroupChatService {
  late IO.Socket _socket;
  final String groupId;
  final Function(Map<String, dynamic>) onMessageReceived;
  final Function(String) onError;
  final Function()? onFeedUpdate;
  final Function(String postId)? onReactionUpdate;
  final Function(String postId)? onCommentUpdate;

  GroupChatService({
    required this.groupId,
    required this.onMessageReceived,
    required this.onError,
    this.onFeedUpdate,
    this.onReactionUpdate,
    this.onCommentUpdate,
  }) {
    _initSocket();
  }

  void _initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    _socket = IO.io('${NetworkConstants.baseUrl}/groups', 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setAuth({'token': token})
        .build()
    );

    _socket.onConnect((_) {
      debugPrint('🟢 [GroupChatService] Connected to socket!');
      _socket.emit('join_room', {'groupId': groupId});
      debugPrint('🟢 [GroupChatService] Emitted join_room for $groupId');
    });

    _socket.onConnectError((err) {
      debugPrint('🔴 [GroupChatService] Connection Error: $err');
    });

    _socket.on('new_group_message', (data) {
      debugPrint('🔵 [GroupChatService] Received message: $data');
      onMessageReceived(Map<String, dynamic>.from(data));
    });

    _socket.on('group_feed_update', (_) {
      onFeedUpdate?.call();
    });

    _socket.on('group_post_reaction_update', (data) {
      onReactionUpdate?.call(data['postId']);
    });

    _socket.on('group_post_comment_update', (data) {
      onCommentUpdate?.call(data['postId']);
    });

    _socket.on('error', (data) {
      debugPrint('🔴 [GroupChatService] Server Error: $data');
      onError(data['message'] ?? 'An error occurred');
    });

    _socket.connect();
  }

  void sendMessage(String userId, String content) {
    debugPrint('🟡 [GroupChatService] Sending message: $content');
    _socket.emit('send_group_message', {
      'userId': userId,
      'groupId': groupId,
      'content': content,
    });
  }

  void dispose() {
    _socket.disconnect();
    _socket.dispose();
  }
}

final groupChatServiceProvider = Provider.family<GroupChatService, GroupChatConfig>((ref, config) {
  final service = GroupChatService(
    groupId: config.groupId,
    onMessageReceived: config.onMessage,
    onError: config.onError,
    onFeedUpdate: config.onFeedUpdate,
    onReactionUpdate: config.onReactionUpdate,
    onCommentUpdate: config.onCommentUpdate,
  );
  ref.onDispose(() => service.dispose());
  return service;
});

class GroupChatConfig {
  final String groupId;
  final Function(Map<String, dynamic>) onMessage;
  final Function(String) onError;
  final Function()? onFeedUpdate;
  final Function(String postId)? onReactionUpdate;
  final Function(String postId)? onCommentUpdate;

  GroupChatConfig({
    required this.groupId,
    required this.onMessage,
    required this.onError,
    this.onFeedUpdate,
    this.onReactionUpdate,
    this.onCommentUpdate,
  });
}
