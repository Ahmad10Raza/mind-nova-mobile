import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../therapist/providers/therapist_provider.dart';
import '../../therapist/models/therapist_model.dart';
import '../../auth/providers/auth_provider.dart';

const _backgroundDeep = Color(0xFF0F131F);
const _primaryColor = Color(0xFFE6DEFF);
const _secondaryColor = Color(0xFF40E0CB);
const _glassBorder = Color.fromRGBO(53, 57, 70, 0.3);

final userMessagesProvider = FutureProvider.autoDispose<List<MessageThread>>((ref) async {
  final userId = ref.watch(authProvider).userId;
  if (userId == null) return [];
  return ref.read(therapistProvider.notifier).getMessageThreads(userId);
});

class UserMessagesScreen extends ConsumerWidget {
  const UserMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(userMessagesProvider);

    return Scaffold(
      backgroundColor: _backgroundDeep,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1F2C).withValues(alpha: 0.9),
        elevation: 0,
        centerTitle: true,
        title: Text('My Messages', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: messagesAsync.when(
        data: (threads) {
          if (threads.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: threads.length,
            itemBuilder: (context, index) {
              final thread = threads[index];
              return _buildMessageCard(context, thread);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: _primaryColor)),
        error: (err, stack) => Center(child: Text('Error loading messages: $err', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: _primaryColor.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No messages yet', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Reach out to a therapist to start a conversation.', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context, MessageThread thread) {
    final therapist = thread.therapist;
    final name = therapist?.name ?? 'Unknown Therapist';
    final imageUrl = therapist?.imageUrl;
    final lastMessage = thread.messages.isNotEmpty ? thread.messages.first.content : 'No messages';
    
    return GestureDetector(
      onTap: () {
        if (therapist == null) return;
        context.push('/therapist/profile/chat', extra: therapist);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _glassBorder),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _secondaryColor.withValues(alpha: 0.2),
              backgroundImage: imageUrl != null && imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl == null || imageUrl.isEmpty
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(color: _secondaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(name, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC9C4D0)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFFC9C4D0)),
          ],
        ),
      ),
    );
  }
}
