import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/group_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../voice/providers/voice_orchestrator.dart';
import '../../../voice/providers/voice_record_provider.dart';

class GroupCreatePostSheet extends ConsumerStatefulWidget {
  final String groupId;
  
  const GroupCreatePostSheet({super.key, required this.groupId});

  @override
  ConsumerState<GroupCreatePostSheet> createState() => _GroupCreatePostSheetState();
}

class _GroupCreatePostSheetState extends ConsumerState<GroupCreatePostSheet> {
  final TextEditingController _controller = TextEditingController();
  String _selectedEmotion = 'Insightful';
  bool _isAnonymous = true;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _emotions = [
    {'id': 'Insightful', 'label': 'Insightful', 'icon': Icons.lightbulb_outline_rounded, 'color': const Color(0xFF44E2CD)},
    {'id': 'Vulnerable', 'label': 'Vulnerable', 'icon': Icons.eco_outlined, 'color': const Color(0xFFD0BCFF)},
    {'id': 'Supportive', 'label': 'Supportive', 'icon': Icons.handshake_outlined, 'color': const Color(0xFFFFAFD3)},
    {'id': 'Question', 'label': 'Question', 'icon': Icons.help_outline_rounded, 'color': const Color(0xFF958EA0)},
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
      final service = ref.read(groupServiceProvider);
      await service.createPost(
        widget.groupId,
        text,
        _isAnonymous,
        emotion: _selectedEmotion,
      );

      // Refresh the feed
      ref.invalidate(groupFeedProvider(widget.groupId));
      ref.invalidate(groupStatsProvider(widget.groupId));

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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _toggleInlineRecording() async {
    final recordNotifier = ref.read(voiceRecordProvider.notifier);
    final recordState = ref.read(voiceRecordProvider);
    final orchestratorNotifier = ref.read(voiceOrchestratorProvider.notifier);

    if (recordState.state == RecordState.recording) {
      final path = await recordNotifier.stopRecording();
      if (path != null) {
        await orchestratorNotifier.processRecording(
          audioPath: path,
          mode: VoiceMode.community,
        );
        final transcript = ref.read(voiceOrchestratorProvider).transcript;
        if (transcript != null) {
          setState(() {
            _controller.text = _controller.text.isEmpty
                ? transcript
                : '${_controller.text}\n\n$transcript';
          });
        }
      }
    } else {
      orchestratorNotifier.reset();
      await recordNotifier.startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(voiceRecordProvider).state == RecordState.recording;
    final isProcessing = ref.watch(voiceOrchestratorProvider).isProcessing;
    
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
                  'Create Circle Post',
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
                      hintText: 'Share your journey...',
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
                        if (isRecording || isProcessing)
                          Expanded(
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: isProcessing ? null : _toggleInlineRecording,
                                  child: Container(
                                    width: 40, height: 40,
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isProcessing ? Colors.white.withOpacity(0.05) : const Color(0xFFFF6B6B).withOpacity(0.2),
                                    ),
                                    child: Icon(
                                      isProcessing ? Icons.hourglass_empty : Icons.stop_rounded,
                                      color: isProcessing ? const Color(0xFFCBC3D7) : const Color(0xFFFF6B6B),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isRecording)
                                  Text(
                                    'Recording... ${_formatDuration(ref.watch(voiceRecordProvider).duration)}',
                                    style: GoogleFonts.inter(color: const Color(0xFFFF6B6B), fontSize: 14, fontWeight: FontWeight.w600),
                                  )
                                else if (isProcessing)
                                  Text(
                                    'Transcribing...',
                                    style: GoogleFonts.inter(color: const Color(0xFF44E2CD), fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                              ],
                            ),
                          )
                        else
                          Row(
                            children: [
                              _buildEditorAction(Icons.image_outlined, 'Add Media', onTap: null),
                              _buildEditorAction(Icons.mic_none_rounded, 'Voice Note', onTap: _toggleInlineRecording),
                              _buildEditorAction(Icons.emoji_emotions_outlined, 'Add Emoji', onTap: null),
                              _buildEditorAction(Icons.tag_rounded, 'Add Topic', onTap: null),
                            ],
                          ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Anonymous Toggle
            Consumer(
              builder: (context, ref, child) {
                final auth = ref.watch(authProvider);
                final displayName = auth.displayName ?? 'Your Name';
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            _isAnonymous ? Icons.visibility_off_rounded : Icons.visibility_rounded, 
                            color: const Color(0xFFD0BCFF), 
                            size: 20
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Post Anonymously',
                                  style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFFDFE2F3)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isAnonymous ? 'Your identity will be hidden' : 'Posting publicly as $displayName',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12, 
                                    color: _isAnonymous ? const Color(0xFFCBC3D7) : const Color(0xFF44E2CD),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                );
              }
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

  Widget _buildEditorAction(IconData icon, String tooltip, {VoidCallback? onTap}) {
    return IconButton(
      icon: Icon(icon, color: const Color(0xFFCBC3D7), size: 24),
      tooltip: tooltip,
      onPressed: onTap ?? () {
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

void showGroupCreatePostSheet(BuildContext context, String groupId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => GroupCreatePostSheet(groupId: groupId),
  );
}
