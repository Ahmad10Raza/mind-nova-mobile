import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/group_provider.dart';
import '../../models/group_model.dart';
import '../widgets/group_post_card.dart';
import '../../../../features/auth/providers/auth_provider.dart';

class GroupPostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const GroupPostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<GroupPostDetailScreen> createState() => _GroupPostDetailScreenState();
}

class _GroupPostDetailScreenState extends ConsumerState<GroupPostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isSendingComment = false;
  bool _isAnonymous = true;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(groupPostDetailProvider(widget.postId));
    final commentsAsync = ref.watch(groupPostCommentsProvider(widget.postId));
    final authState = ref.watch(authProvider);
    final userId = authState.userId ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F12),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Post Discussion',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: postAsync.when(
        data: (post) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GroupPostCard(
                      post: post,
                      currentUserId: userId,
                      onTap: () {},
                      onComment: () {},
                      onBookmark: () {},
                      onReport: () {},
                      onReact: (type) async {
                        await ref.read(groupServiceProvider).toggleReaction(post.id, type);
                        ref.invalidate(groupPostDetailProvider(widget.postId));
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Comments',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    commentsAsync.when(
                      data: (comments) {
                        if (comments.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  const Icon(Icons.forum_outlined, color: Colors.white10, size: 48),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No replies yet',
                                    style: GoogleFonts.inter(color: Colors.white24, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) => _buildCommentTile(comments[index]),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error loading comments: $e')),
                    ),
                  ],
                ),
              ),
            ),
            _buildCommentInput(),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading post: $e')),
      ),
    );
  }

  Widget _buildCommentTile(GroupPostCommentModel comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white10,
                backgroundImage: comment.userAvatar != null ? NetworkImage(comment.userAvatar!) : null,
                child: comment.userAvatar == null 
                  ? Text(comment.userName[0], style: const TextStyle(fontSize: 10, color: Colors.white38)) 
                  : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  comment.userName,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
              Text(
                _timeAgo(comment.createdAt),
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white24),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment.content,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.8), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: const Color(0xFF16161A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isAnonymous = !_isAnonymous),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isAnonymous 
                        ? const Color(0xFFB388FF).withOpacity(0.1) 
                        : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: _isAnonymous 
                          ? const Color(0xFFB388FF).withOpacity(0.3) 
                          : Colors.white10,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isAnonymous ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          size: 14,
                          color: _isAnonymous ? const Color(0xFFB388FF) : Colors.white60,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isAnonymous ? 'Comment Anonymously' : 'Comment as ${ref.read(authProvider).displayName ?? 'Me'}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _isAnonymous ? const Color(0xFFB388FF) : Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: TextField(
                    controller: _commentController,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Add a helpful comment...',
                      hintStyle: GoogleFonts.inter(color: Colors.white12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _isSendingComment ? null : _sendComment,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB388FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _isSendingComment
                      ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSendingComment = true);
    try {
      await ref.read(groupServiceProvider).addComment(
        widget.postId, 
        text,
        isAnonymous: _isAnonymous,
      );
      _commentController.clear();
      ref.invalidate(groupPostCommentsProvider(widget.postId));
      ref.invalidate(groupPostDetailProvider(widget.postId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSendingComment = false);
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
