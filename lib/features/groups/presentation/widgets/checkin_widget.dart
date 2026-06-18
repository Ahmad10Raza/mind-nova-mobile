import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/group_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class CheckInWidget extends ConsumerStatefulWidget {
  final String groupId;
  final VoidCallback? onCompleted;

  const CheckInWidget({super.key, required this.groupId, this.onCompleted});

  @override
  ConsumerState<CheckInWidget> createState() => _CheckInWidgetState();
}

class _CheckInWidgetState extends ConsumerState<CheckInWidget> {
  String? _selectedEmotion;
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;
  bool _isAnonymous = true;

  final List<Map<String, dynamic>> _emotions = [
    {'label': 'Anxious', 'icon': '😰'},
    {'label': 'Calm', 'icon': '😌'},
    {'label': 'Stressed', 'icon': '😫'},
    {'label': 'Hopeful', 'icon': '✨'},
    {'label': 'Lonely', 'icon': '☁️'},
    {'label': 'Tired', 'icon': '😴'},
    {'label': 'Sad', 'icon': '😢'},
    {'label': 'Peaceful', 'icon': '🧘'},
    {'label': 'Overwhelmed', 'icon': '🌊'},
    {'label': 'Angry', 'icon': '😡'},
    {'label': 'Grateful', 'icon': '🙏'},
    {'label': 'Excited', 'icon': '🥳'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Check-In',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How are you feeling today?',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _emotions.map((e) {
              final isSelected = _selectedEmotion == e['label'];
              return GestureDetector(
                onTap: () => setState(() => _selectedEmotion = e['label']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFFB388FF).withOpacity(0.1) 
                        : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFFB388FF) 
                          : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e['icon'], style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        e['label'],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Add a small note (optional)...',
              hintStyle: GoogleFonts.inter(color: Colors.white10),
              filled: true,
              fillColor: Colors.black.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
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
                          color: const Color(0xFFB388FF), 
                          size: 20
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Post Anonymously',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isAnonymous ? 'Your identity will be hidden' : 'Posting publicly as $displayName',
                                style: GoogleFonts.inter(
                                  fontSize: 12, 
                                  color: _isAnonymous ? Colors.white38 : const Color(0xFF44E2CD),
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
                    activeTrackColor: const Color(0xFFB388FF),
                    inactiveThumbColor: Colors.white38,
                    inactiveTrackColor: Colors.white.withOpacity(0.1),
                  ),
                ],
              );
            }
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (_selectedEmotion == null || _isSubmitting) 
                  ? null 
                  : _handleCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB388FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSubmitting 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Complete Check-In',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCheckIn() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(groupServiceProvider).checkIn(
        widget.groupId,
        _selectedEmotion!,
        _noteController.text,
        isAnonymous: _isAnonymous,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Great job showing up today! ✨')),
        );
        // Refresh feed and stats
        ref.invalidate(groupFeedProvider(widget.groupId));
        ref.invalidate(groupStatsProvider(widget.groupId));
        
        if (widget.onCompleted != null) {
          widget.onCompleted!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
