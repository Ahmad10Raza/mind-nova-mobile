import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/journal_provider.dart';
import '../models/journal_model.dart';
import 'package:go_router/go_router.dart';

class JournalEditorScreen extends ConsumerStatefulWidget {
  final JournalEntry? initialEntry;
  const JournalEditorScreen({super.key, this.initialEntry});

  @override
  ConsumerState<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends ConsumerState<JournalEditorScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isFocusMode = false;
  String _currentMood = 'Neutral';
  final List<String> _tags = [];
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  static const _bg = Color(0xFF0F131F);
  static const _surface = Color(0xFF1B1F2C);
  static const _primary = Color(0xFFCABEFF);
  static const _secondary = Color(0xFF44E2CD);
  static const _onSurface = Color(0xFFDFE2F3);
  static const _onSurfaceVariant = Color(0xFFC9C4D8);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialEntry?.title);
    _contentController = TextEditingController(text: widget.initialEntry?.content);
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    Future.microtask(() {
      ref.read(journalEditorProvider.notifier).initiateDraft(widget.initialEntry);
    });
    _contentController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    setState(() {});
    ref.read(journalEditorProvider.notifier).triggerAutoSave(
      content: _contentController.text,
      title: _titleController.text,
      moodState: _currentMood,
      tags: _tags,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  int get _wordCount => _contentController.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(journalEditorProvider);
    final isSaving = editorState?.isDraft ?? false;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Atmospheric bg glow top-left
          Positioned(
            top: -80, left: -80,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Transform.scale(
                scale: _pulse.value,
                child: Container(
                  width: 320, height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      _primary.withValues(alpha: 0.12),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60, right: -80,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _secondary.withValues(alpha: 0.08),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Main editor
          SafeArea(
            child: Column(
              children: [
                // Top bar
                if (!_isFocusMode) _buildTopBar(context, isSaving),
                // Writing area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const SizedBox(height: 28),
                        // Journal type badge if available
                        if (widget.initialEntry?.journalType != null &&
                            widget.initialEntry!.journalType != 'FREE_WRITE')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: _primary.withValues(alpha: 0.15),
                                  border: Border.all(color: _primary.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  widget.initialEntry!.journalType.replaceAll('_', ' '),
                                  style: GoogleFonts.inter(color: _primary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
                                ),
                              ),
                            ]),
                          ),
                        // Title field
                        TextField(
                          controller: _titleController,
                          style: GoogleFonts.manrope(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _onSurface,
                            height: 1.25,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Untitled Story',
                            hintStyle: GoogleFonts.manrope(
                              color: _onSurfaceVariant.withValues(alpha: 0.3),
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          cursorColor: _primary,
                        ),
                        const SizedBox(height: 20),
                        // Content field
                        TextField(
                          controller: _contentController,
                          maxLines: null,
                          autofocus: widget.initialEntry == null,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            color: _onSurface.withValues(alpha: 0.85),
                            height: 1.7,
                          ),
                          decoration: InputDecoration(
                            hintText: "It's a safe space. Breathe, and write...",
                            hintStyle: GoogleFonts.inter(
                              color: _onSurfaceVariant.withValues(alpha: 0.3),
                              fontSize: 17,
                              height: 1.7,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          cursorColor: _primary,
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
                // Bottom toolbar
                _buildBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isSaving) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _bg.withValues(alpha: 0.8),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _surface.withValues(alpha: 0.6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(Icons.close_rounded, color: _onSurface, size: 18),
          ),
        ),
        const Spacer(),
        if (isSaving)
          Row(children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: _secondary)),
            const SizedBox(width: 6),
            Text('Saving...', style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 12)),
            const SizedBox(width: 16),
          ]),
        GestureDetector(
          onTap: () async {
            try {
              await ref.read(journalEditorProvider.notifier).publishFinal(
                content: _contentController.text,
                title: _titleController.text,
                moodState: _currentMood,
                tags: _tags,
              );
              if (context.mounted) context.pop();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to publish: $e'),
                    backgroundColor: const Color(0xFF93000A),
                  ),
                );
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(colors: [_primary, Color(0xFF937DFF)]),
              boxShadow: [BoxShadow(color: _primary.withValues(alpha: 0.3), blurRadius: 12)],
            ),
            child: Text('Publish', style: GoogleFonts.inter(color: const Color(0xFF1C0062), fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
      ]),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: _surface.withValues(alpha: 0.7),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                _toolBtn(Icons.image_outlined, 'Add Image', onTap: () {}),
                _toolBtn(Icons.mic_none_rounded, 'Voice Note', onTap: () {}),
                _toolBtn(Icons.mood_rounded, 'Mood', onTap: _showMoodPicker),
                _toolBtn(Icons.tag_rounded, 'Tags', onTap: () {}),
              ]),
              Text(
                '$_wordCount words',
                style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [
            GestureDetector(
              onTap: () => setState(() => _isFocusMode = !_isFocusMode),
              child: Icon(
                _isFocusMode ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                color: _onSurfaceVariant,
                size: 20,
              ),
            ),
            const Spacer(),
            const Icon(Icons.fingerprint_rounded, color: _secondary, size: 16),
            const SizedBox(width: 5),
            Text('Encrypted Vault', style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          ]),
        ],
      ),
    );
  }

  Widget _toolBtn(IconData icon, String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Tooltip(
          message: label,
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.transparent,
            ),
            child: Icon(icon, color: _onSurfaceVariant, size: 22),
          ),
        ),
      ),
    );
  }

  void _showMoodPicker() {
    final moods = ['Calm', 'Happy', 'Neutral', 'Anxious', 'Sad', 'Angry', 'Grateful'];
    final colors = [
      _secondary, const Color(0xFFFFD700), _onSurfaceVariant,
      const Color(0xFFFFB4AB), const Color(0xFF80BDFF),
      const Color(0xFFFF6B6B), _primary,
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How are you feeling?', style: GoogleFonts.manrope(color: _onSurface, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(moods.length, (i) => GestureDetector(
                onTap: () {
                  setState(() => _currentMood = moods[i]);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: _currentMood == moods[i] ? colors[i].withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                    border: Border.all(color: _currentMood == moods[i] ? colors[i] : Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: colors[i])),
                    const SizedBox(width: 8),
                    Text(moods[i], style: GoogleFonts.inter(color: _onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
                  ]),
                ),
              )),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
