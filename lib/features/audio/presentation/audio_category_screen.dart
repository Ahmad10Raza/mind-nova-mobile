import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../domain/audio_model.dart';
import '../providers/audio_provider.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/audio_track_card.dart';
import '../widgets/audio_empty_state.dart';

class AudioCategoryScreen extends ConsumerWidget {
  final AudioCategoryMeta category;
  const AudioCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(audioTracksProvider(category.id));
    final startColor = _hexToColor(category.gradientStart);
    final endColor = _hexToColor(category.gradientEnd);

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Hero App Bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            backgroundColor: Colors.transparent,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [startColor, endColor, const Color(0xFF050B18)],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(category.emoji, style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: 12),
                      Text(
                        category.label,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        category.moodBenefit,
                        style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Tracks List ───────────────────────────────────────────────
          tracksAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
            ),
            error: (_, __) => const SliverFillRemaining(
              child: Center(child: Text('Failed to load tracks', style: TextStyle(color: Colors.white54))),
            ),
            data: (tracks) {
              if (tracks.isEmpty) {
                return const SliverFillRemaining(
                  child: AudioEmptyState(type: AudioEmptyType.search),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => AudioTrackCard(
                      track: tracks[i],
                      onTap: () {
                        ref.read(audioPlayerProvider.notifier).setQueue(tracks, startIndex: i);
                        context.push('/audio/player', extra: tracks[i]);
                      },
                      onFavorite: () => ref.read(audioDataServiceProvider).toggleFavorite(tracks[i].id),
                      onDownload: () {},
                    ),
                    childCount: tracks.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    final c = hex.replaceAll('#', '');
    return Color(int.parse('FF$c', radix: 16));
  }
}
