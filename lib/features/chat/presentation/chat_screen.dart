import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/design/colors/app_colors.dart';
import '../../dashboard/presentation/widgets/ambient_background.dart';
import '../data/chat_socket_service.dart';
import '../models/chat_model.dart';
import '../../safety/providers/safety_provider.dart';
import '../../safety/models/crisis_model.dart';

final chatServiceProvider = NotifierProvider<ChatSocketService, ChatSocketState>(
  ChatSocketService.new,
);

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  late final AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _initChat();
    
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  Future<void> _initChat() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? 'anonymous';
    final chatState = ref.read(chatServiceProvider);
    
    if (!chatState.isConnected) {
      ref.read(chatServiceProvider.notifier).connect(
        userId,
        onCrisis: (analysisJson) {
          final analysis = AppCrisisAnalysis.fromJson(analysisJson);
          if (analysis.triggerScreen) {
            ref.read(safetyProvider.notifier).triggerCrisis(analysis);
          }
        },
      );
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _sendMessage([String? prefilledText]) {
    final text = prefilledText ?? _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    
    SharedPreferences.getInstance().then((prefs) {
      final userId = prefs.getString('userId') ?? 'anonymous';
      ref.read(chatServiceProvider.notifier).sendMessage(userId, text);
    });

    _scrollToBottom();
  }
  
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatServiceProvider);
    final messages = chatState.messages;
    final isThinking = chatState.isThinking;
    
    final ambientState = isThinking ? EmotionalState.calm : EmotionalState.night;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                final scale = 1.0 + (isThinking ? (_breathingController.value * 0.02) : 0);
                return Transform.scale(
                  scale: scale,
                  child: AmbientBackground(currentState: ambientState),
                );
              },
            ),
          ),
          
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: _buildDeepConversation(messages, isThinking),
            ),
          ),
          
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomArea(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leadingWidth: 120,
      leading: Padding(
        padding: const EdgeInsets.only(left: 24.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.novaPurple, AppColors.novaPurpleLight],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/images/nova_ai.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Nova',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white70),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildDeepConversation(List<ChatMessage> messages, bool isThinking) {
    if (messages.isEmpty && !isThinking) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            "I'm here whenever you're ready.\nTalk freely to Nova.",
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 160),
      itemCount: messages.length + (isThinking ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isThinking) {
          return _buildThinkingIndicator();
        }
        return _buildConversationBubble(messages[index]);
      },
    );
  }
  
  Widget _buildConversationBubble(ChatMessage message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            decoration: BoxDecoration(
              color: isUser 
                  ? AppColors.novaPurpleLight.withValues(alpha: 0.15)
                  : AppColors.backgroundSecondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft: isUser ? const Radius.circular(24) : const Radius.circular(8),
                bottomRight: isUser ? const Radius.circular(8) : const Radius.circular(24),
              ),
              border: Border.all(
                color: isUser 
                    ? AppColors.novaPurpleLight.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Text(
              message.content,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                height: 1.6,
                letterSpacing: 0.3,
                color: Colors.white.withValues(alpha: isUser ? 0.9 : 0.95),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              isUser ? 'YOU' : 'NOVA',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(0),
              const SizedBox(width: 8),
              _buildDot(1),
              const SizedBox(width: 8),
              _buildDot(2),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.2, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeInOutSine,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.calmTeal.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24, 
        16, 
        24, 
        // Always sit above the bottom nav bar. When keyboard is open, sit above keyboard.
        MediaQuery.of(context).viewInsets.bottom > 0 
            ? MediaQuery.of(context).viewInsets.bottom + 16 
            : 100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onSubmitted: (_) => _sendMessage(),
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type your thoughts...',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w300,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.novaPurple, AppColors.novaPurpleLight],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.novaPurpleLight.withValues(alpha: 0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
