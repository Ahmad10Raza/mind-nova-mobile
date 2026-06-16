import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../therapist/models/therapist_model.dart';
import '../providers/therapist_chat_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/api_client.dart';
// Colors & Constants
const _backgroundDeep = Color(0xFF0F131F);
const _primaryColor = Color(0xFFE6DEFF);
const _secondaryColor = Color(0xFF40E0CB);
const _errorColor = Color(0xFFFFB4AB);
const _glassBorder = Color.fromRGBO(53, 57, 70, 0.3);

class TherapistChatScreen extends ConsumerStatefulWidget {
  final TherapistProfile profile;
  
  const TherapistChatScreen({super.key, required this.profile});

  @override
  ConsumerState<TherapistChatScreen> createState() => _TherapistChatScreenState();
}

class _TherapistChatScreenState extends ConsumerState<TherapistChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    
    _msgController.clear();
    await ref.read(therapistChatManagerProvider(widget.profile.id)).sendMessage(text, widget.profile.id);
    
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundDeep,
      body: Stack(
        children: [
          // Background Glows
          Positioned(top: -50, right: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120), child: const SizedBox()))),
          
          Column(
            children: [
              _buildAppBar(),
              _buildSessionBanner(),
              Expanded(
                child: ValueListenableBuilder<ChatState>(
                  valueListenable: ref.watch(therapistChatManagerProvider(widget.profile.id)),
                  builder: (context, chatState, child) {
                    if (chatState.isLoading) {
                      return const Center(child: CircularProgressIndicator(color: _primaryColor));
                    }
                    
                    if (chatState.error != null) {
                      return Center(child: Text('Error: ${chatState.error}', style: const TextStyle(color: _errorColor)));
                    }

                    final currentUserId = ref.read(authProvider).userId;
                    
                    // Auto-scroll on new data if at bottom
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                      }
                    });

                    if (chatState.messages.isEmpty) {
                      return const Center(child: Text('No messages yet. Say hello!', style: TextStyle(color: Color(0xFFC9C4D0))));
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: chatState.messages.length,
                      itemBuilder: (context, index) {
                        final msg = chatState.messages[index];
                        final isMe = msg['senderId'] == currentUserId;
                        final time = DateFormat('h:mm a').format(DateTime.parse(msg['createdAt'] ?? DateTime.now().toIso8601String()).toLocal());
                        return _buildMessageBubble(msg['content'] ?? '', isMe, time);
                      },
                    );
                  },
                ),
              ),
              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 16, left: 8, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: _glassBorder)),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: _primaryColor), onPressed: () => context.pop()),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(widget.profile.imageUrl ?? '', width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width: 40, height: 40, color: Colors.grey)),
              ),
              Positioned(right: 0, bottom: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle, border: Border.all(color: _backgroundDeep, width: 2)))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.profile.name, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Online', style: GoogleFonts.inter(fontSize: 12, color: Colors.greenAccent)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: _primaryColor), 
            onPressed: () {
              final currentUserId = ref.read(authProvider).userId ?? 'unknown';
              final roomId = 'room_${currentUserId}_${widget.profile.id}';
              context.push('/therapist/session/live', extra: {
                'isTherapistRole': false,
                'remoteName': widget.profile.name,
                'remoteImageUrl': widget.profile.imageUrl,
                'roomId': roomId,
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.call, color: _primaryColor), 
            onPressed: () {
              final currentUserId = ref.read(authProvider).userId ?? 'unknown';
              final roomId = 'room_${currentUserId}_${widget.profile.id}';
              context.push('/therapist/session/live', extra: {
                'isTherapistRole': false,
                'remoteName': widget.profile.name,
                'remoteImageUrl': widget.profile.imageUrl,
                'roomId': roomId,
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSessionBanner() {
    final authState = ref.read(authProvider);
    final userId = authState.userId;
    if (userId == null) return const SizedBox.shrink();

    return FutureBuilder(
      future: ref.read(apiClientProvider).dio.get('/therapists/my-sessions/$userId'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: _secondaryColor.withValues(alpha: 0.05),
            child: Row(
              children: [
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: _secondaryColor)),
                const SizedBox(width: 12),
                Text('Loading session info...', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC9C4D0))),
              ],
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          try {
            final sessions = snapshot.data!.data as List? ?? [];
            // Find upcoming session with this therapist
            final now = DateTime.now();
            Map<String, dynamic>? nextSession;
            for (var s in sessions) {
              final dateStr = s['scheduledStartTime'] ?? s['date'];
              if (dateStr == null) continue;
              final dt = DateTime.parse(dateStr);
              if (dt.isAfter(now) && (s['therapistId'] == widget.profile.id || s['status'] == 'ACCEPTED')) {
                nextSession = s;
                break;
              }
            }

            if (nextSession == null) return const SizedBox.shrink();

            final dt = DateTime.parse(nextSession['scheduledStartTime'] ?? nextSession['date']).toLocal();
            final formatted = DateFormat('EEEE \'at\' h:mm a').format(dt);

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: _secondaryColor.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.event, color: _secondaryColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Upcoming Session: $formatted', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _secondaryColor))),
                  TextButton(
                    onPressed: () => context.push('/therapist/profile/prep', extra: widget.profile),
                    style: TextButton.styleFrom(foregroundColor: _secondaryColor, padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                    child: Text('Prepare', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          } catch (_) {
            return const SizedBox.shrink();
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(widget.profile.imageUrl ?? '', width: 24, height: 24, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width: 24, height: 24, color: Colors.grey))),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? _primaryColor : const Color(0xFF1B1F2C).withValues(alpha: 0.8),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: Border.all(color: isMe ? _primaryColor : _glassBorder),
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(text, style: GoogleFonts.inter(fontSize: 15, color: isMe ? const Color(0xFF0F131F) : Colors.white, height: 1.4)),
                  const SizedBox(height: 4),
                  Text(time, style: GoogleFonts.inter(fontSize: 10, color: isMe ? const Color(0xFF0F131F).withValues(alpha: 0.6) : const Color(0xFFC9C4D0))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8, top: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.9),
        border: const Border(top: BorderSide(color: _glassBorder)),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.attach_file, color: Color(0xFFC9C4D0)), onPressed: () {}),
          Expanded(
            child: TextField(
              controller: _msgController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: const TextStyle(color: Color(0xFFC9C4D0)),
                filled: true,
                fillColor: const Color(0xFF353946).withValues(alpha: 0.3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(color: _primaryColor, shape: BoxShape.circle),
            child: IconButton(icon: const Icon(Icons.send, color: Color(0xFF32285E), size: 20), onPressed: _sendMessage),
          ),
        ],
      ),
    );
  }
}
