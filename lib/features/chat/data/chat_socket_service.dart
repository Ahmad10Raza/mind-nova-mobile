import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_model.dart';
import '../../../core/network/network_constants.dart';

class ChatSocketState {
  final List<ChatMessage> messages;
  final bool isThinking;
  final bool isConnected;

  ChatSocketState({
    this.messages = const [],
    this.isThinking = false,
    this.isConnected = false,
  });

  ChatSocketState copyWith({
    List<ChatMessage>? messages,
    bool? isThinking,
    bool? isConnected,
  }) {
    return ChatSocketState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class ChatSocketService extends Notifier<ChatSocketState> {
  IO.Socket? _socket;
  void Function(Map<String, dynamic>)? onCrisisDetected;

  @override
  ChatSocketState build() {
    ref.onDispose(() {
      _socket?.dispose();
    });
    return ChatSocketState();
  }

  /// Dynamically determine the backend URL based on the platform.
  String get _baseUrl => NetworkConstants.baseUrl;

  void connect(String userId, {void Function(Map<String, dynamic>)? onCrisis}) {
    onCrisisDetected = onCrisis;
    _socket = IO.io('$_baseUrl/chat', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('✅ Connected to Chat Socket');
      state = state.copyWith(isConnected: true);
      _socket!.emit('get_history', {'userId': userId});
    });

    _socket!.onConnectError((err) {
      debugPrint('❌ Chat Socket connection error: $err');
      state = state.copyWith(isConnected: false);
    });

    _socket!.on('chat_history', (data) {
      final List history = data as List;
      final msgs = history.map((m) => ChatMessage.fromJson(m)).toList();
      state = state.copyWith(messages: msgs);
    });

    _socket!.on('ai_reply', (data) {
      final newMsg = ChatMessage(
        content: data['content'],
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      if (data['crisisAnalysis'] != null && onCrisisDetected != null) {
        onCrisisDetected!(data['crisisAnalysis'] as Map<String, dynamic>);
      }

      state = state.copyWith(
        messages: [...state.messages, newMsg],
        isThinking: false,
      );
    });

    _socket!.on('ai_state', (data) {
      state = state.copyWith(isThinking: data['state'] == 'thinking');
    });

    _socket!.onDisconnect((_) {
      debugPrint('🔌 Disconnected from Chat Socket');
      state = state.copyWith(isConnected: false);
    });
  }

  void sendMessage(String userId, String content) {
    final newMsg = ChatMessage(
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, newMsg]);
    _socket?.emit('send_message', {'userId': userId, 'content': content});
  }
}

