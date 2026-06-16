import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/community_providers.dart';

class CreatePostSheet extends ConsumerStatefulWidget {
  const CreatePostSheet({super.key});

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  final TextEditingController _controller = TextEditingController();
  String _selectedEmotion = 'CALM';
  bool _isAnonymous = true;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _emotions = [
    {'id': 'HAPPY', 'label': 'Hopeful', 'icon': Icons.flare_rounded, 'color': const Color(0xFF44E2CD)},
    {'id': 'CALM', 'label': 'Supported', 'icon': Icons.diversity_1_rounded, 'color': const Color(0xFFD0BCFF)},
    {'id': 'STRESSED', 'label': 'Growing', 'icon': Icons.psychology_rounded, 'color': const Color(0xFFFFAFD3)},
    {'id': 'SAD', 'label': 'Struggling', 'icon': Icons.water_drop_rounded, 'color': const Color(0xFF958EA0)},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final service = ref.read(communityServiceProvider);
      await service.createPost(
        content: text,
        emotion: _selectedEmotion,
        type: 'STANDARD', // Defaulting to standard reflection
        isAnonymous: _isAnonymous,
      );

      // Refresh the feed
      ref.invalidate(communityFeedProvider);
      ref.invalidate(communityInsightsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reflection shared securely.', style: GoogleFonts.manrope(color: const Color(0xFF0F131F))),
            backgroundColor: const Color(0xFFD0BCFF),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post. Please try again.', style: GoogleFonts.manrope(color: Colors.white)),
            backgroundColor: const Color(0xFFFFB4AB),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handling keyboard padding so it pushes up
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
        decoration: BoxDecoration(
          color: const Color(0xFF171B28).withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.edit_note_rounded, color: Color(0xFFD0BCFF), size: 28),
                const SizedBox(width: 12),
                Text(
                  'Share Reflection',
                  style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFDFE2F3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Share what\'s on your mind. You can choose to post anonymously.',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: const Color(0xFFCBC3D7),
              ),
            ),
            const SizedBox(height: 24),
            
            // Emotion Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _emotions.map((e) {
                  final isSelected = _selectedEmotion == e['id'];
                  final color = e['color'] as Color;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedEmotion = e['id'] as String),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.15) : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(e['icon'] as IconData, size: 16, color: isSelected ? color : const Color(0xFFCBC3D7)),
                            const SizedBox(width: 6),
                            Text(
                              e['label'] as String,
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? color : const Color(0xFFCBC3D7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Editor Area
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: 6,
                    minLines: 4,
                    style: GoogleFonts.manrope(color: const Color(0xFFDFE2F3), fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'What do you want to talk about?',
                      hintStyle: GoogleFonts.manrope(color: const Color(0xFFCBC3D7).withOpacity(0.5), fontSize: 16),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                  Divider(color: Colors.white.withOpacity(0.05), height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        _buildEditorAction(Icons.image_outlined, 'Add Media'),
                        _buildEditorAction(Icons.emoji_emotions_outlined, 'Add Emoji'),
                        _buildEditorAction(Icons.tag_rounded, 'Add Topic'),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Anonymous Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isAnonymous ? Icons.visibility_off_rounded : Icons.visibility_rounded, 
                      color: const Color(0xFFD0BCFF), 
                      size: 20
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Post Anonymously',
                      style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFFDFE2F3)),
                    ),
                  ],
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
            
            const SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD0BCFF),
                  foregroundColor: const Color(0xFF0F131F),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F131F)),
                      )
                    : Text(
                        'Share with Community',
                        style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorAction(IconData icon, String tooltip) {
    return IconButton(
      icon: Icon(icon, color: const Color(0xFFCBC3D7), size: 24),
      tooltip: tooltip,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$tooltip coming soon!', style: GoogleFonts.manrope(color: Colors.white)),
            backgroundColor: const Color(0xFF262A36),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}

void showCreatePostSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CreatePostSheet(),
  );
}
