import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/network/api_client.dart'; // To get baseUrl
import '../../auth/providers/auth_provider.dart';

class TherapistSocketService {
  IO.Socket? _socket;
  
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _presenceController = StreamController<Map<String, dynamic>>.broadcast();
  final _statusController = StreamController<Map<String, dynamic>>.broadcast();
  final _globalPresenceController = StreamController<Map<String, dynamic>>.broadcast();
  final _scheduleUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get onNewMessage => _messageController.stream;
  Stream<Map<String, dynamic>> get onTyping => _typingController.stream;
  Stream<Map<String, dynamic>> get onPresence => _presenceController.stream;
  Stream<Map<String, dynamic>> get onMessageStatus => _statusController.stream;
  Stream<Map<String, dynamic>> get onGlobalPresence => _globalPresenceController.stream;
  Stream<Map<String, dynamic>> get onScheduleUpdate => _scheduleUpdateController.stream;
  Stream<bool> get onConnectionState => _connectionController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String userId, String token) {
    if (_socket != null) return;

    // Use ApiClient baseUrl
    final baseUrl = '${ApiClient().baseUrl}/therapist-chat';

    _socket = IO.io(baseUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .setAuth({'token': token})
      .setQuery({'userId': userId})
      .build()
    );

    _socket?.onConnect((_) {
      debugPrint('TherapistSocketService connected');
      _connectionController.add(true);
    });

    _socket?.onDisconnect((_) {
      debugPrint('TherapistSocketService disconnected');
      _connectionController.add(false);
    });

    _socket?.on('new_message', (data) {
      _messageController.add(data);
    });

    _socket?.on('typing', (data) {
      _typingController.add(data);
    });

    _socket?.on('presence', (data) {
      _presenceController.add(data);
    });

    _socket?.on('message_status', (data) {
      _statusController.add(data);
    });

    _socket?.on('messages_seen', (data) {
      _statusController.add(data); // Can re-use status stream or separate
    });

    _socket?.on('presence_update', (data) {
      _globalPresenceController.add(data);
    });

    _socket?.on('schedule_update', (data) {
      _scheduleUpdateController.add(data);
    });

    _socket?.connect();
  }

  void joinThread(String threadId, String userId, {bool isTherapist = false}) {
    _socket?.emit('join_thread', {
      'threadId': threadId,
      'userId': userId,
      'isTherapist': isTherapist,
    });
  }

  void sendMessage({
    required String threadId,
    required String senderId,
    required String senderType,
    required String content,
    String messageType = 'TEXT',
    String? fileUrl,
    int? duration,
  }) {
    _socket?.emit('send_message', {
      'threadId': threadId,
      'senderId': senderId,
      'senderType': senderType,
      'content': content,
      'messageType': messageType,
      'fileUrl': fileUrl,
      'duration': duration,
    });
  }

  void startTyping(String threadId, String userId, String senderType) {
    _socket?.emit('typing_start', {
      'threadId': threadId,
      'userId': userId,
      'senderType': senderType,
    });
  }

  void stopTyping(String threadId, String userId, String senderType) {
    _socket?.emit('typing_stop', {
      'threadId': threadId,
      'userId': userId,
      'senderType': senderType,
    });
  }

  void markSeen(String threadId, String viewerSenderType) {
    _socket?.emit('mark_seen', {
      'threadId': threadId,
      'viewerSenderType': viewerSenderType,
    });
  }

  void updateStatus(String userId, String status) {
    _socket?.emit('update_status', {
      'userId': userId,
      'status': status,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connectionController.add(false);
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _presenceController.close();
    _statusController.close();
    _globalPresenceController.close();
    _connectionController.close();
  }
}
