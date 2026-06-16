import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../mood/models/mood_model.dart';
import '../../mood/providers/analytics_provider.dart';

class MoodHistoryScreen extends ConsumerStatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  ConsumerState<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends ConsumerState<MoodHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final history = ref.watch(moodHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F131F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFDFE2F3)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Mood History',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFDFE2F3),
          ),
        ),
        centerTitle: true,
      ),
      body: history.isLoading && history.entries.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF44E2CD)))
          : history.error != null && history.entries.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Error: ${history.error}',
                      style: GoogleFonts.inter(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : history.entries.isEmpty
                  ? Center(
                      child: Text(
                        'No moods logged yet.',
                        style: GoogleFonts.inter(color: const Color(0xFF938EA1)),
                      ),
                    )
                  : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: history.entries.length + (history.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == history.entries.length) {
                      return Center(
                        child: TextButton(
                          onPressed: () => ref.read(moodHistoryProvider.notifier).fetchNextPage(),
                          child: Text(
                            'Load More',
                            style: GoogleFonts.inter(color: const Color(0xFF44E2CD)),
                          ),
                        ),
                      );
                    }
                    return _buildTimelineCard(history.entries[index]);
                  },
                ),
    );
  }

  Widget _buildGlassCard({required Widget child, required EdgeInsets padding}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF171B28).withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTimelineCard(MoodHistoryEntry entry) {
    Color primaryColor = const Color(0xFF938EA1); // default fallback
    try {
      primaryColor = Color(int.parse(entry.color.replaceFirst('#', '0xFF')));
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildGlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(entry.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.moodName,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFDFE2F3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimelineDate(entry.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF938EA1),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    entry.intensity.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262A37),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Text(tag, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFC9C4D8))),
                )).toList(),
              ),
            ],
            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF171B28).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.notes!,
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFDFE2F3)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimelineDate(DateTime date) {
    final now = DateTime.now();
    final isToday = now.year == date.year && now.month == date.month && now.day == date.day;
    final isYesterday = now.subtract(const Duration(days: 1)).day == date.day && now.month == date.month && now.year == date.year;
    
    String prefix = '';
    if (isToday) prefix = 'Today, ';
    else if (isYesterday) prefix = 'Yesterday, ';
    else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      prefix = '${months[date.month - 1]} ${date.day}, ';
    }
    
    int hour = date.hour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final min = date.minute.toString().padLeft(2, '0');
    
    return '$prefix$hour:$min $ampm';
  }
}
