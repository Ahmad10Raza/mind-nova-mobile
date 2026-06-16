import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/group_model.dart';

class GroupPostCard extends StatelessWidget {
  final GroupPostModel post;
  final String? currentUserId;
  final VoidCallback onTap;
  final VoidCallback onComment;
  final VoidCallback onBookmark;
  final VoidCallback onReport;
  final Function(String type) onReact;

  const GroupPostCard({
    super.key,
    required this.post,
    this.currentUserId,
    required this.onTap,
    required this.onComment,
    required this.onBookmark,
    required this.onReport,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasGradient = post.backgroundGradient != null && post.backgroundGradient != 'none';
    final bool hasImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;
    final String timeAgo = _getTimeAgo(post.createdAt);
    final String uid = currentUserId ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: hasGradient ? null : const Color(0xFF16161A),
        gradient: hasGradient ? _getGradient(post.backgroundGradient!) : null,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: post.priority > 0 
              ? const Color(0xFFB388FF).withOpacity(0.3) 
              : Colors.white.withOpacity(0.03),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    post.imageUrl!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 100,
                      color: Colors.white10,
                      child: const Icon(Icons.broken_image_rounded, color: Colors.white24),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: post.isAnonymous 
                              ? const Color(0xFFB388FF).withOpacity(0.1) 
                              : Colors.white10,
                          backgroundImage: post.userAvatar != null 
                              ? NetworkImage(post.userAvatar!) 
                              : null,
                          child: post.userAvatar == null 
                              ? Text(
                                  _getEmojiForUser(post.userName),
                                  style: const TextStyle(fontSize: 18),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.userName,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                timeAgo,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white38,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (post.emotion != null)
                          _buildBadge(
                            label: post.emotion!,
                            emoji: _getEmojiForMood(post.emotion!),
                            color: _getColorForMood(post.emotion!),
                          ),
                      ],
                    ),
                    if (post.priority > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _buildBadge(
                          label: 'Needs Help',
                          emoji: '✋',
                          color: const Color(0xFFFF5252),
                          isSolid: false,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      post.content,
                      textAlign: hasGradient ? TextAlign.center : TextAlign.start,
                      style: GoogleFonts.inter(
                        fontSize: hasGradient ? 22 : 14,
                        height: 1.5,
                        fontWeight: hasGradient ? FontWeight.w700 : FontWeight.w400,
                        color: Colors.white.withOpacity(hasGradient ? 1.0 : 0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!hasGradient) _buildHashtags(['healing', 'support', 'journey']),
                    const SizedBox(height: 20),
                    _buildReactionGrid(uid),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withOpacity(0.05), height: 1),
                    const SizedBox(height: 12),
                    _buildActionRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({required String label, required String emoji, required Color color, bool isSolid = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isSolid ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHashtags(List<String> tags) {
    return Wrap(
      spacing: 8,
      children: tags.map((tag) => Text(
        '#$tag',
        style: GoogleFonts.inter(
          color: const Color(0xFFB388FF).withOpacity(0.6),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      )).toList(),
    );
  }

  Widget _buildReactionGrid(String userId) {
    return Row(
      children: [
        _buildReactionItem('🤍', 'SUPPORT', post.countReaction('SUPPORT'), post.hasUserReacted(userId, 'SUPPORT')),
        const SizedBox(width: 8),
        _buildReactionItem('🤗', 'HUG', post.countReaction('HUG'), post.hasUserReacted(userId, 'HUG')),
        const SizedBox(width: 8),
        _buildReactionItem('🙌', 'STAY_STRONG', post.countReaction('STAY_STRONG'), post.hasUserReacted(userId, 'STAY_STRONG')),
        const SizedBox(width: 8),
        _buildReactionItem('✨', 'FEEL_SAME', post.countReaction('FEEL_SAME'), post.hasUserReacted(userId, 'FEEL_SAME')),
      ],
    );
  }

  Widget _buildReactionItem(String emoji, String type, int count, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onReact(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF7C4DFF).withOpacity(0.2) : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? const Color(0xFF7C4DFF).withOpacity(0.4) : Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                count > 0 ? count.toString() : _getLabelForType(type),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: isActive ? Colors.white : Colors.white38,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLabelForType(String type) {
    switch (type) {
      case 'SUPPORT': return 'Support';
      case 'HUG': return 'Hug';
      case 'STAY_STRONG': return 'Strong';
      case 'FEEL_SAME': return 'Same';
      default: return '';
    }
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        _buildActionIcon(Icons.chat_bubble_outline_rounded, post.commentCount > 0 ? '${post.commentCount} replies' : 'Reply', onComment),
        const Spacer(),
        _buildActionIcon(Icons.bookmark_outline_rounded, null, onBookmark),
        const SizedBox(width: 16),
        _buildActionIcon(Icons.more_horiz_rounded, null, onReport),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, String? label, VoidCallback onTapAction) {
    return GestureDetector(
      onTap: onTapAction,
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 20),
          if (label != null) ...[
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String _getEmojiForUser(String name) {
    if (name.contains('Anonymous')) return '👤';
    final emojis = ['😊', '😇', '🦊', '🦉', '🐱', '🐶'];
    return emojis[name.hashCode % emojis.length];
  }

  String _getEmojiForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'anxious': return '😰';
      case 'supportive': return '🤝';
      case 'vulnerable': return '🌱';
      case 'happy': return '😊';
      default: return '✨';
    }
  }

  Color _getColorForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'anxious': return const Color(0xFFFF8A65);
      case 'supportive': return const Color(0xFFB388FF);
      case 'vulnerable': return const Color(0xFF81C784);
      case 'happy': return const Color(0xFFFFD54F);
      default: return const Color(0xFFB388FF);
    }
  }

  LinearGradient? _getGradient(String name) {
    switch (name) {
      case 'dusk': return const LinearGradient(colors: [Color(0xFF2C3E50), Color(0xFF000000)]);
      case 'ocean': return const LinearGradient(colors: [Color(0xFF1CB5E0), Color(0xFF000851)]);
      case 'forest': return const LinearGradient(colors: [Color(0xFF11998e), Color(0xFF38ef7d)]);
      case 'sunset': return const LinearGradient(colors: [Color(0xFFff9966), Color(0xFFff5e62)]);
      case 'lavender': return const LinearGradient(colors: [Color(0xFFB388FF), Color(0xFF7C4DFF)]);
      default: return null;
    }
  }
}
