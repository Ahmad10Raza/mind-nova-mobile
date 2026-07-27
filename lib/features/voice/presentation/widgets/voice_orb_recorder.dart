import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../providers/voice_record_provider.dart';
import '../../providers/voice_orchestrator.dart';
import '../../../../core/design/colors/app_colors.dart';

class VoiceOrbRecorder extends ConsumerStatefulWidget {
  final VoiceMode mode;
  final String? appointmentId;
  final String? therapistId;
  final Function(String transcript)? onComplete;

  const VoiceOrbRecorder({
    Key? key,
    required this.mode,
    this.appointmentId,
    this.therapistId,
    this.onComplete,
  }) : super(key: key);

  @override
  ConsumerState<VoiceOrbRecorder> createState() => _VoiceOrbRecorderState();
}

class _VoiceOrbRecorderState extends ConsumerState<VoiceOrbRecorder> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleRecordPress(VoiceRecordState recordState) async {
    final recordNotifier = ref.read(voiceRecordProvider.notifier);
    final orchestratorNotifier = ref.read(voiceOrchestratorProvider.notifier);

    if (recordState.state == RecordState.recording) {
      _pulseController.stop();
      final path = await recordNotifier.stopRecording();
      if (path != null) {
        await orchestratorNotifier.processRecording(
          audioPath: path,
          mode: widget.mode,
          appointmentId: widget.appointmentId,
          therapistId: widget.therapistId,
        );
        final transcript = ref.read(voiceOrchestratorProvider).transcript;
        if (transcript != null && widget.onComplete != null) {
          widget.onComplete!(transcript);
        }
      }
    } else {
      orchestratorNotifier.reset();
      await recordNotifier.startRecording();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordState = ref.watch(voiceRecordProvider);
    final orchestratorState = ref.watch(voiceOrchestratorProvider);
    final isRecording = recordState.state == RecordState.recording;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (orchestratorState.isProcessing)
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        else
          GestureDetector(
            onTap: () => _handleRecordPress(recordState),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = isRecording ? 1.0 + (_pulseController.value * 0.2) : 1.0;
                final shadowOpacity = isRecording ? 0.6 + (_pulseController.value * 0.4) : 0.3;
                
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(shadowOpacity),
                          blurRadius: 20 * scale,
                          spreadRadius: 5 * scale,
                        ),
                      ],
                    ),
                    child: Icon(
                      isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 24),
        if (isRecording)
          Text(
            _formatDuration(recordState.duration),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          )
        else if (orchestratorState.isProcessing)
          const Text(
            "Analyzing Voice...",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          )
        else
          const Text(
            "Tap to speak",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          
        if (orchestratorState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              width: 150,
              child: Text(
                orchestratorState.errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
