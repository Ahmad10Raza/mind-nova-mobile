import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/gratitude_provider.dart';
import '../../../voice/providers/voice_orchestrator.dart';
import '../../../voice/providers/voice_record_provider.dart';

class GratitudeQuickEntryCard extends ConsumerStatefulWidget {
  const GratitudeQuickEntryCard({super.key});

  @override
  ConsumerState<GratitudeQuickEntryCard> createState() => _GratitudeQuickEntryCardState();
}

class _GratitudeQuickEntryCardState extends ConsumerState<GratitudeQuickEntryCard> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _selectedChips = [];

  final List<String> _quickChips = [
    'Family',
    'Friends',
    'Health',
    'Work',
    'Nature',
    'Sleep',
    'Small Wins',
    'Pets',
    'Partner',
    'Home',
    'Exercise',
    'Food',
    'Coffee',
    'Music',
    'Hobbies',
    'Learning',
  ];

  void _toggleChip(String chip) {
    setState(() {
      if (_selectedChips.contains(chip)) {
        _selectedChips.remove(chip);
      } else {
        _selectedChips.add(chip);
      }
    });
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
          mode: VoiceMode.gratitude,
        );
        
        final orchestratorState = ref.read(voiceOrchestratorProvider);
        if (orchestratorState.errorMessage != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Transcription failed: ${orchestratorState.errorMessage}'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        } else if (orchestratorState.transcript != null) {
          setState(() {
            _controller.text = _controller.text.isEmpty
                ? orchestratorState.transcript!
                : '${_controller.text} ${orchestratorState.transcript}';
          });
        }
      }
    } else {
      orchestratorNotifier.reset();
      await recordNotifier.startRecording();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(voiceRecordProvider).state == RecordState.recording;
    final isProcessing = ref.watch(voiceOrchestratorProvider).isProcessing;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C), // Dark surface
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Input Field ─────────────────────────────────────
          TextField(
            controller: _controller,
            maxLines: 4,
            minLines: 1,
            textInputAction: TextInputAction.done,
            style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFDFE2F3)),
            decoration: InputDecoration(
              hintText: 'I am grateful for...',
              hintStyle: GoogleFonts.inter(color: const Color(0xFFC9C4D8).withOpacity(0.6)),
              border: InputBorder.none,
              fillColor: Colors.transparent,
              filled: true,
            ),
          ),
          
          Divider(height: 24, color: Colors.white.withOpacity(0.1)),

          // ─── Quick Chips ──────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _quickChips.map((chip) {
              final isSelected = _selectedChips.contains(chip);
              return GestureDetector(
                onTap: () => _toggleChip(chip),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFB74D).withOpacity(0.15) : const Color(0xFF0F131F),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFFB74D).withOpacity(0.5) : Colors.white.withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    chip,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? const Color(0xFFFFB74D) : const Color(0xFFC9C4D8),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // ─── Action Row ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isRecording || isProcessing)
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: isProcessing ? null : _toggleInlineRecording,
                        child: Container(
                          width: 44, height: 44,
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
                      const SizedBox(width: 12),
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
                GestureDetector(
                  onTap: _toggleInlineRecording,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE94057).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.mic_rounded, color: Colors.white, size: 24),
                  ),
                ),
              if (!isRecording && !isProcessing)
                ElevatedButton(
                onPressed: () async {
                  final text = _controller.text.trim();
                  if (text.isEmpty && _selectedChips.isEmpty) return; // Ignore empty saves
                  
                  try {
                    await ref.read(gratitudeHistoryProvider.notifier).createEntry(
                      content: text.isNotEmpty ? text : null,
                      tags: _selectedChips.isNotEmpty ? List.from(_selectedChips) : null,
                    );
                    
                    _controller.clear();
                    setState(() => _selectedChips.clear());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gratitude Saved! 🎉')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Oops, failed to save: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700), // Gold Button
                  foregroundColor: const Color(0xFF1B1F2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Log Gratitude',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
