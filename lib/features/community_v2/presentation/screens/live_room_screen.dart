import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../community/data/community_socket_service.dart';
import '../../providers/community_providers.dart';

class LiveRoomScreen extends ConsumerStatefulWidget {
  final String roomId;

  const LiveRoomScreen({super.key, required this.roomId});

  @override
  ConsumerState<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends ConsumerState<LiveRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final JitsiMeet _jitsiMeet = JitsiMeet();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isConnected = false;
  String _userId = '';
  
  StreamSubscription? _msgSub;
  StreamSubscription? _joinSub;
  StreamSubscription? _leaveSub;
  Timer? _timer;
  bool _hasShownWarning = false;
  DateTime? _endsAt;

  @override
  void initState() {
    super.initState();
    _initRoom();
  }

  Future<void> _initRoom() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? 'anonymous';
    final token = prefs.getString('token') ?? '';
    
    final socketService = ref.read(communitySocketProvider);
    socketService.connect(widget.roomId, token, alias: _userId);
    
    _msgSub = socketService.messageStream.listen((data) {
      if (mounted) {
        setState(() {
          _messages.add({
            'content': data['text'],
            'isUser': data['userId'] == _userId,
            'alias': data['alias'],
            'timestamp': DateTime.now(),
          });
        });
        _scrollToBottom();
      }
    });

    _joinSub = socketService.participantJoinedStream.listen((data) {
       if (mounted) {
         setState(() {
            _messages.add({
              'isSystem': true,
              'content': '${data['alias']} joined the circle',
            });
         });
         _scrollToBottom();
       }
    });

    _leaveSub = socketService.participantLeftStream.listen((data) {
       if (mounted) {
         setState(() {
            _messages.add({
              'isSystem': true,
              'content': '${data['alias']} left the circle',
            });
         });
         _scrollToBottom();
       }
    });

    setState(() {
      _isConnected = true;
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_endsAt == null) return;
      
      final now = DateTime.now();
      final difference = _endsAt!.difference(now);
      
      // 5 minute warning
      if (difference.inMinutes == 5 && !_hasShownWarning && difference.inSeconds < 300 && difference.inSeconds > 290) {
        _hasShownWarning = true;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Warning: The circle will end in 5 minutes.'),
              backgroundColor: AppColors.warmSupport,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }

      // Finish call
      if (difference.isNegative) {
        timer.cancel();
        _endCall();
      }
    });
  }

  void _endCall() {
    _jitsiMeet.hangUp();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('The circle has ended. Thank you for being present.'),
          backgroundColor: AppColors.calmTeal,
          duration: const Duration(seconds: 4),
        ),
      );
      if (GoRouter.of(context).canPop()) {
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _joinSub?.cancel();
    _leaveSub?.cancel();
    _timer?.cancel();
    if (_isConnected) {
      final socketService = ref.read(communitySocketProvider);
      socketService.leaveRoom(widget.roomId);
    }
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _joinLiveCall() async {
    var options = JitsiMeetConferenceOptions(
      serverURL: "https://meet.jit.si",
      room: widget.roomId,
      configOverrides: {
        "startWithAudioMuted": true,
        "startWithVideoMuted": true,
        "subject" : "Live Community Circle"
      },
      featureFlags: {
        "unsaferoomwarning.enabled": false,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: "Community Member",
        email: "member@mindnova.app",
      ),
    );
    
    try {
      await _jitsiMeet.join(options);
    } catch (error) {
      debugPrint("Jitsi error: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not join live call. Please ensure permissions are granted.')),
        );
      }
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    
    final socketService = ref.read(communitySocketProvider);
    socketService.sendMessage(widget.roomId, text);
    // Note: the message will be added to the UI via the _msgSub listener

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch room details to get endsAt time
    ref.listen(liveRoomDetailProvider(widget.roomId), (prev, next) {
      if (next is AsyncData) {
        if (mounted && next.value != null && next.value!.endsAt != null) {
          _endsAt = next.value!.endsAt;
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Live Space',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header / Call Info
          Container(
            margin: const EdgeInsets.all(AppSpacing.s16),
            padding: const EdgeInsets.all(AppSpacing.s20),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: AppRadius.lg,
              border: Border.all(color: AppColors.novaPurpleLight.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.error.withOpacity(0.5), blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'THERAPIST LED CALL IN PROGRESS',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _joinLiveCall,
                  icon: const Icon(Icons.headphones_rounded),
                  label: Text('Join Full Screen Audio/Video', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.novaPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
          
          // Chat Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFFCBC3D7), size: 16),
                const SizedBox(width: 8),
                Text(
                  'Community Chat',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFCBC3D7),
                  ),
                ),
              ],
            ),
          ),
          
          // Chat Messages Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isSystem = msg['isSystem'] == true;
                
                if (isSystem) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['content'] as String,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final isUser = msg['isUser'] == true;
                final alias = msg['alias'] as String? ?? 'Unknown';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          Text(
                            alias,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isUser ? AppColors.novaPurple.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg['content'] as String,
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Message Input
          _buildBottomArea(),
        ],
      ),
    );
  }

  Widget _buildBottomArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 
        16, 
        16, 
        MediaQuery.of(context).viewInsets.bottom > 0 
            ? MediaQuery.of(context).viewInsets.bottom + 16 
            : 32,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onSubmitted: (_) => _sendMessage(),
                style: GoogleFonts.manrope(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Share a thought...',
                  hintStyle: GoogleFonts.manrope(color: Colors.white.withOpacity(0.3)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.novaPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
