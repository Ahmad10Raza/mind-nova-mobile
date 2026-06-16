import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/gratitude_provider.dart';

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);
  
  if (difference.inDays == 0) {
    if (difference.inHours == 0) {
      if (difference.inMinutes == 0) return 'Just now';
      return '${difference.inMinutes}m ago';
    }
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class GratitudeTimeline extends ConsumerWidget {
  const GratitudeTimeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gratitudeHistoryProvider);

    if (state.isLoading && state.entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.auto_awesome, color: const Color(0xFFC9C4D8).withOpacity(0.5), size: 48),
              const SizedBox(height: 16),
              Text(
                'Your gratitude journey starts here.',
                style: GoogleFonts.inter(color: const Color(0xFFC9C4D8)),
              )
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.entries.length + (state.hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index >= state.entries.length) {
          ref.read(gratitudeHistoryProvider.notifier).fetchMore();
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final entry = state.entries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1F2C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(entry.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFC9C4D8),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(gratitudeHistoryProvider.notifier).toggleFavorite(entry.id),
                      child: Icon(
                        entry.isFavorite ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                        color: entry.isFavorite ? const Color(0xFFFFD700) : const Color(0xFFC9C4D8),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  entry.content ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFFDFE2F3),
                    height: 1.5,
                  ),
                ),
                if (entry.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: entry.tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
