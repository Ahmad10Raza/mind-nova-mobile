import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/community_providers.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  final String postId;

  const CommentsSheet({Key? key, required this.postId}) : super(key: key);

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isAnonymous = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_controller.text.trim().isEmpty) return;
    ref.read(commentSubmitProvider.notifier).submitComment(widget.postId, _controller.text.trim(), isAnonymous: _isAnonymous);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(postCommentsProvider(widget.postId));
    final submitState = ref.watch(commentSubmitProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1B1F2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag handle and header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comments',
                      style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFFDFE2F3)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFFCBC3D7)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Comments list
          Expanded(
            child: commentsAsync.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return Center(
                    child: Text(
                      'No comments yet. Be the first to share your thoughts.',
                      style: GoogleFonts.manrope(color: const Color(0xFFCBC3D7).withOpacity(0.6)),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: comments.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final hoursAgo = DateTime.now().difference(comment.createdAt).inHours;
                    final timeString = hoursAgo == 0 ? 'Just now' : '${hoursAgo}h ago';

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF262A36),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFFCBC3D7)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    comment.isAnonymous ? 'Anonymous' : (comment.aliasName ?? 'Member'),
                                    style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFDFE2F3)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    timeString,
                                    style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFFCBC3D7).withOpacity(0.5)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                comment.content,
                                style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFFCBC3D7), height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFFAFD3))),
              error: (err, stack) => Center(child: Text('Failed to load comments', style: TextStyle(color: Colors.white.withOpacity(0.5)))),
            ),
          ),
          
          // Comment input
          Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1F2C),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comment anonymously',
                      style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFFCBC3D7)),
                    ),
                    Switch(
                      value: _isAnonymous,
                      onChanged: (val) => setState(() => _isAnonymous = val),
                      activeColor: const Color(0xFF0F131F),
                      activeTrackColor: const Color(0xFFD0BCFF),
                      inactiveThumbColor: const Color(0xFFCBC3D7),
                      inactiveTrackColor: Colors.white.withOpacity(0.1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: GoogleFonts.manrope(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: GoogleFonts.manrope(color: const Color(0xFFCBC3D7).withOpacity(0.5)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: submitState.isLoading ? null : _submitComment,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFAFD3),
                          shape: BoxShape.circle,
                        ),
                        child: submitState.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: CircularProgressIndicator(color: Color(0xFF0F131F), strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded, color: Color(0xFF0F131F), size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
