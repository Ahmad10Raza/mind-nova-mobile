import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/design/colors/app_colors.dart';
import '../../../core/design/typography/app_typography.dart';
import '../../../core/design/spacing/app_spacing.dart';
import '../../../core/design/surfaces/app_surfaces.dart';
import '../../../core/design/radius/app_radius.dart';
import '../../../core/widgets/appbars/mind_nova_appbars.dart';

import '../../chat/data/chat_socket_service.dart';
import '../../chat/models/chat_model.dart';
import '../../safety/providers/safety_provider.dart';
import '../../safety/models/crisis_model.dart';

import 'widgets/nova_avatar_widget.dart';
import 'widgets/nova_chat_bubble.dart';
import 'widgets/nova_thinking_indicator.dart';
import 'widgets/nova_message_input.dart';
import 'widgets/nova_empty_state.dart';

/// Riverpod provider for the ChatSocketService singleton (reused from chat feature)
final novaChatServiceProvider = NotifierProvider<ChatSocketService, ChatSocketState>(
  ChatSocketService.new,
);

/// The redesigned Nova AI conversation screen.
/// Built on the MindNova design system with emotional tokens.
class NovaChatScreen extends ConsumerStatefulWidget {
  const NovaChatScreen({super.key});

  @override
  ConsumerState<NovaChatScreen> createState() => _NovaChatScreenState();
}

class _NovaChatScreenState extends ConsumerState<NovaChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? 'anonymous';
    final chatState = ref.read(novaChatServiceProvider);

    if (!chatState.isConnected) {
      ref.read(novaChatServiceProvider.notifier).connect(
        userId,
        onCrisis: (analysisJson) {
          final analysis = AppCrisisAnalysis.fromJson(analysisJson);
          if (analysis.triggerScreen) {
            ref.read(safetyProvider.notifier).triggerCrisis(analysis);
          }
        },
      );
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? prefilledText]) {
    final text = prefilledText ?? _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    SharedPreferences.getInstance().then((prefs) {
      final userId = prefs.getString('userId') ?? 'anonymous';
      ref.read(novaChatServiceProvider.notifier).sendMessage(userId, text);
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(novaChatServiceProvider);
    final messages = chatState.messages;
    final isThinking = chatState.isThinking;
    final isConnected = chatState.isConnected;

    // Auto-scroll on new messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      appBar: _buildAppBar(isConnected),
      body: Column(
        children: [
          // Messages or empty state
          Expanded(
            child: messages.isEmpty && !isThinking
                ? NovaEmptyState(
                    onSuggestionTap: (text) => _sendMessage(text),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, AppSpacing.s8,
                    ),
                    itemCount: messages.length + (isThinking ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && isThinking) {
                        return const NovaThinkingIndicator();
                      }
                      return NovaChatBubble(message: messages[index]);
                    },
                  ),
          ),

          // Message input
          NovaMessageInput(
            controller: _controller,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isConnected) {
    return AppBar(
      backgroundColor: AppSurfaces.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textSecondary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          const NovaAvatarWidget(size: 32, isActive: false),
          AppSpacing.h12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nova', style: AppTypography.headingMedium.copyWith(fontSize: 16)),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isConnected ? AppColors.successSoft : AppColors.emotionalDangerMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    isConnected ? 'Here for you' : 'Connecting...',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
