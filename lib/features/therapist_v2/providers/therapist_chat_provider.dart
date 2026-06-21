import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_constants.dart';

class ChatState {
  final bool isLoading;
  final String? error;
  final String? threadId;
  final List<dynamic> messages;
  final bool isConnected;

  ChatState({
    this.isLoading = false,
    this.error,
    this.threadId,
    this.messages = const [],
    this.isConnected = false,
  });

  ChatState copyWith({
    bool? isLoading,
    String? error,
    String? threadId,
    List<dynamic>? messages,
    bool? isConnected,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      threadId: threadId ?? this.threadId,
      messages: messages ?? this.messages,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class ChatManager extends ValueNotifier<ChatState> {
  final Ref ref;
  final String targetProfileId;
  io.Socket? _socket;

  ChatManager(this.ref, this.targetProfileId) : super(ChatState(isLoading: true)) {
    _initChat();
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    final dio = ref.read(apiClientProvider).dio;
    final token = await ref.read(apiClientProvider).getAuthToken();
    final authState = ref.read(authProvider);
    final currentUserId = authState.userId;
    final isTherapist = authState.role == 'THERAPIST';

    if (token == null || currentUserId == null) {
      value = value.copyWith(error: 'Not authenticated', isLoading: false);
      return;
    }

    String? threadId;
    List<dynamic> initialMessages = [];

    try {
      final threadsRes = await dio.get('/therapists/messages/$currentUserId');
      if (threadsRes.statusCode == 200) {
        final List threads = threadsRes.data;
        for (var t in threads) {
          if ((isTherapist && t['userId'] == targetProfileId) || 
              (!isTherapist && t['therapistId'] == targetProfileId)) {
            threadId = t['id'];
            break;
          }
        }
      }

      if (threadId != null) {
        final msgRes = await dio.get('/therapists/messages/thread/$threadId?viewerId=$currentUserId');
        if (msgRes.statusCode == 200 && msgRes.data != null) {
          initialMessages = List.from(msgRes.data['messages'] ?? []);
          initialMessages.sort((a, b) => DateTime.parse(a['createdAt']).compareTo(DateTime.parse(b['createdAt'])));
        }
      }

      _connectSocket(token, threadId, isTherapist);

      value = ChatState(
        isLoading: false,
        threadId: threadId,
        messages: initialMessages,
      );
    } catch (e) {
      value = value.copyWith(error: 'Failed to load chat: $e', isLoading: false);
    }
  }

  void _connectSocket(String token, String? currentThreadId, bool isTherapist) {
    _socket = io.io(
      '${NetworkConstants.baseUrl}/therapist-chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      print('[Socket] Connected to therapist-chat');
      value = value.copyWith(isConnected: true);

      if (currentThreadId != null) {
        _socket!.emit('join_thread', {
          'threadId': currentThreadId,
          'isTherapist': isTherapist,
        });
      }
    });

    _socket!.onDisconnect((_) {
      print('[Socket] Disconnected from therapist-chat');
      value = value.copyWith(isConnected: false);
    });

    _socket!.on('new_message', (data) {
      print('[Socket] New message: $data');
      // Prevent duplicate if optimistic update already added it
      final exists = value.messages.any((m) => m['id'] == data['id'] || (m['id'].toString().startsWith('temp_') && m['content'] == data['content']));
      if (!exists) {
        value = value.copyWith(messages: List.from(value.messages)..add(data));
      }
    });

    _socket!.connect();
  }

  Future<void> sendMessage(String text, String targetId) async {
    final authState = ref.read(authProvider);
    final currentUserId = authState.userId;
    final isTherapistRole = authState.role == 'THERAPIST';
    final senderType = isTherapistRole ? 'THERAPIST' : 'USER';

    if (currentUserId == null) return;

    try {
      if (value.threadId == null) {
        final dio = ref.read(apiClientProvider).dio;
        final res = await dio.post('/therapists/message', data: {
          'userId': isTherapistRole ? targetId : currentUserId,
          'therapistId': isTherapistRole ? currentUserId : targetId,
          'content': text,
        });

        if (res.statusCode == 201) {
          final newThreadId = res.data['thread']['id'];
          final firstMessage = res.data['message'];
          
          value = value.copyWith(
            threadId: newThreadId,
            messages: [firstMessage],
          );

          _socket?.emit('join_thread', {
            'threadId': newThreadId,
            'isTherapist': isTherapistRole,
          });
        }
      } else {
        // Optimistic UI Update
        final tempMessage = {
          'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
          'content': text,
          'senderId': currentUserId,
          'createdAt': DateTime.now().toIso8601String(),
          'messageType': 'TEXT',
        };
        value = value.copyWith(messages: List.from(value.messages)..add(tempMessage));

        _socket?.emit('send_message', {
          'threadId': value.threadId,
          'senderId': currentUserId,
          'senderType': senderType,
          'content': text,
          'messageType': 'TEXT',
        });
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}

final therapistChatManagerProvider = Provider.autoDispose.family<ChatManager, String>((ref, targetProfileId) {
  final manager = ChatManager(ref, targetProfileId);
  ref.onDispose(manager.dispose);
  return manager;
});
