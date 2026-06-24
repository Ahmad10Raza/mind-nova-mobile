import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/voice_record_provider.dart';
import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';

class VoiceRecordButton extends ConsumerWidget {
  final Function(String audioPath) onRecordingComplete;

  const VoiceRecordButton({
    super.key,
    required this.onRecordingComplete,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<VoiceRecordState>(voiceRecordProvider, (previous, next) {
      if (next.state == RecordState.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: AppColors.error),
        );
      }
    });

    final recordState = ref.watch(voiceRecordProvider);
    final notifier = ref.read(voiceRecordProvider.notifier);

    final isRecording = recordState.state == RecordState.recording;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isRecording)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              _formatDuration(recordState.duration),
              style: AppTypography.headingMedium.copyWith(color: AppColors.novaPurple),
            ),
          ),
        GestureDetector(
          onTap: () async {
            if (isRecording) {
              final path = await notifier.stopRecording();
              if (path != null) {
                onRecordingComplete(path);
              }
            } else {
              await notifier.startRecording();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isRecording ? 80 : 64,
            height: isRecording ? 80 : 64,
            decoration: BoxDecoration(
              color: isRecording ? AppColors.emotionalDangerMuted.withValues(alpha: 0.2) : AppColors.novaPurple,
              shape: BoxShape.circle,
              border: Border.all(
                color: isRecording ? AppColors.error : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                if (isRecording)
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                else
                  BoxShadow(
                    color: AppColors.novaPurple.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
              ],
            ),
            child: Icon(
              isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              color: isRecording ? AppColors.error : Colors.white,
              size: isRecording ? 36 : 28,
            ),
          ),
        ),
      ],
    );
  }
}
