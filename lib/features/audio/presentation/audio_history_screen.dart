import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../providers/audio_provider.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/audio_track_card.dart';

class AudioHistoryScreen extends ConsumerWidget {
  const AudioHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(audioHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Listening History',
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
        error: (err, _) => Center(child: Text('Failed to load history', style: TextStyle(color: Colors.white54))),
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_rounded, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text('No recent tracks found', style: GoogleFonts.inter(color: Colors.white54)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final h = history[index];
              if (h.track == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AudioTrackCard(
                  track: h.track!,
                  onTap: () {
                    ref.read(audioPlayerProvider.notifier).setQueue([h.track!]);
                    context.push('/audio/player');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
