import 'package:flutter/material.dart';
import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/surfaces/app_surfaces.dart';

class TranscriptEditor extends StatefulWidget {
  final String initialTranscript;
  final String detectedLanguage;
  final Function(String updatedTranscript) onSave;
  final VoidCallback onCancel;

  const TranscriptEditor({
    super.key,
    required this.initialTranscript,
    required this.detectedLanguage,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<TranscriptEditor> createState() => _TranscriptEditorState();
}

class _TranscriptEditorState extends State<TranscriptEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTranscript);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppSurfaces.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.textDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Review Transcript',
                  style: AppTypography.headingLarge.copyWith(fontSize: 20, color: AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.novaPurpleLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.detectedLanguage,
                    style: AppTypography.body.copyWith(fontSize: 12, color: AppColors.novaPurple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Please review and edit any inaccuracies before saving.',
              style: AppTypography.body.copyWith(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 8,
              minLines: 4,
              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppSurfaces.primary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Edit your transcript here...',
                hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.textDisabled),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Discard', style: AppTypography.button.copyWith(color: AppColors.textPrimary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onSave(_controller.text),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.novaPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Save Entry', style: AppTypography.button.copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
