import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/network/network_constants.dart';

final communitySocketProvider = Provider<CommunitySocketService>((ref) {
  final service = CommunitySocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

class CommunitySocketService {
  IO.Socket? _socket;
  String _myAlias = 'You';
  bool _isConnected = false;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _reactionController = StreamController<Map<String, dynamic>>.broadcast();
  final _handRaisedController = StreamController<Map<String, dynamic>>.broadcast();
  final _roomStateController = StreamController<Map<String, dynamic>>.broadcast();
  final _participantJoinedController = StreamController<Map<String, dynamic>>.broadcast();
  final _participantLeftController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get reactionStream => _reactionController.stream;
  Stream<Map<String, dynamic>> get handRaisedStream => _handRaisedController.stream;
  Stream<Map<String, dynamic>> get roomStateStream => _roomStateController.stream;
  Stream<Map<String, dynamic>> get participantJoinedStream => _participantJoinedController.stream;
  Stream<Map<String, dynamic>> get participantLeftStream => _participantLeftController.stream;

  String get myAlias => _myAlias;
  bool get isConnected => _isConnected;

  /// Base URL — matches the ApiClient logic
  String get _baseUrl => NetworkConstants.baseUrl;

  void connect(String roomId, String token, {String? alias}) {
    // Disconnect previous socket if exists
    _socket?.dispose();

    _myAlias = alias ?? 'User_${DateTime.now().millisecondsSinceEpoch % 1000}';

    _socket = IO.io('$_baseUrl/community-chat', IO.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': token})
      .setQuery({'roomId': roomId})
      .enableReconnection()
      .build());

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('✅ Connected to Community Chat Socket');

      // Join the room with alias
      _socket!.emit('join_room', {
        'roomId': roomId,
        'alias': _myAlias,
      });

      // Request current room state
      _socket!.emit('get_room_state', {
        'roomId': roomId,
      });
    });

    // ─── Event Listeners ──────────────────────────────────────

    _socket!.on('new_message', (data) {
      if (data is Map<String, dynamic>) {
        _messageController.add(data);
      } else if (data is Map) {
        _messageController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('new_reaction', (data) {
      if (data is Map<String, dynamic>) {
        _reactionController.add(data);
      } else if (data is Map) {
        _reactionController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('hand_raised', (data) {
      if (data is Map<String, dynamic>) {
        _handRaisedController.add(data);
      } else if (data is Map) {
        _handRaisedController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('room_state', (data) {
      debugPrint('📊 Room State: $data');
      if (data is Map<String, dynamic>) {
        _roomStateController.add(data);
      } else if (data is Map) {
        _roomStateController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('participant_joined', (data) {
      debugPrint('👤 Participant joined: $data');
      if (data is Map<String, dynamic>) {
        _participantJoinedController.add(data);
      } else if (data is Map) {
        _participantJoinedController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('participant_left', (data) {
      debugPrint('👋 Participant left: $data');
      if (data is Map<String, dynamic>) {
        _participantLeftController.add(data);
      } else if (data is Map) {
        _participantLeftController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('🔌 Disconnected from Community Chat Socket');
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
      debugPrint('❌ Community Chat Socket error: $err');
    });

    _socket!.onReconnect((_) {
      debugPrint('🔄 Reconnected to Community Chat Socket');
      _socket!.emit('join_room', {
        'roomId': roomId,
        'alias': _myAlias,
      });
      _socket!.emit('get_room_state', {
        'roomId': roomId,
      });
    });
  }

  void sendMessage(String roomId, String text) {
    _socket?.emit('send_message', {
      'roomId': roomId,
      'text': text,
      'alias': _myAlias,
    });
  }

  void sendReaction(String roomId, String emoji) {
    _socket?.emit('send_reaction', {
      'roomId': roomId,
      'emoji': emoji,
      'alias': _myAlias,
    });
  }

  void raiseHand(String roomId) {
    _socket?.emit('raise_hand', {
      'roomId': roomId,
      'alias': _myAlias,
      'isRaised': true,
    });
  }

  void leaveRoom(String roomId) {
    _socket?.emit('leave_room', {
      'roomId': roomId,
    });
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _messageController.close();
    _reactionController.close();
    _handRaisedController.close();
    _roomStateController.close();
    _participantJoinedController.close();
    _participantLeftController.close();
  }
}
