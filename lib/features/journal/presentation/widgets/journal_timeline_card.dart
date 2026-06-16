import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/journal_model.dart';
import 'package:intl/intl.dart';

class JournalTimelineCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  static const _surface = Color(0xFF1B1F2C);
  static const _primary = Color(0xFFCABEFF);
  static const _secondary = Color(0xFF44E2CD);
  static const _onSurface = Color(0xFFDFE2F3);
  static const _onSurfaceVariant = Color(0xFFC9C4D8);

  const JournalTimelineCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  String _formatTime(DateTime date) {
    return DateFormat('jm').format(date);
  }

  Color _moodColor(String? mood) {
    switch (mood?.toLowerCase()) {
      case 'calm': return _secondary;
      case 'happy': return const Color(0xFFFFD700);
      case 'anxious': return const Color(0xFFFFB4AB);
      case 'sad': return const Color(0xFF80BDFF);
      default: return _onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surface.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        entry.journalType.replaceAll('_', ' '),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (entry.isDraft)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "DRAFT",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _primary,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  _formatTime(entry.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entry.title ?? (entry.content.isNotEmpty ? entry.content.substring(0, entry.content.length > 50 ? 50 : entry.content.length) : 'Untitled'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              entry.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            if (entry.aiInsights.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 14, color: _primary),
                        const SizedBox(width: 6),
                        Text(
                          "Nova Insight: ${entry.aiInsights.first.tone}",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                    if (entry.aiInsights.first.summary != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry.aiInsights.first.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (entry.moodState != null)
                      _buildChip(entry.moodState!, Icons.circle, color: _moodColor(entry.moodState)),
                    const SizedBox(width: 8),
                    _buildChip("${entry.wordCount} words", Icons.text_fields_rounded),
                  ],
                ),
                if (entry.isLocked)
                  Icon(Icons.lock_rounded, color: _onSurfaceVariant.withValues(alpha: 0.5), size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 10, color: color ?? _onSurfaceVariant.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: _onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
