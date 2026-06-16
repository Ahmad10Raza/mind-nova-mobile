import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../models/journal_model.dart';

class JournalType {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  JournalType({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });
}

class JournalTypeCard extends StatelessWidget {
  final JournalType type;
  final VoidCallback onTap;

  const JournalTypeCard({
    super.key,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: type.colors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: type.colors.last.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(type.icon, color: Colors.white, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  type.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white70,
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

class JournalTypeSection extends StatelessWidget {
  JournalTypeSection({super.key});

  final List<JournalType> _types = [
    JournalType(
      title: "Daily Focus",
      subtitle: "Reflect on today",
      icon: Icons.wb_sunny_rounded,
      colors: [const Color(0xFFF6AD55), const Color(0xFFED8936)],
    ),
    JournalType(
      title: "Gratitude",
      subtitle: "Find the joy",
      icon: Icons.favorite_rounded,
      colors: [const Color(0xFFF687B3), const Color(0xFFD53F8C)],
    ),
    JournalType(
      title: "Anxiety Dump",
      subtitle: "Let it all out",
      icon: Icons.cloud_off_rounded,
      colors: [const Color(0xFF718096), const Color(0xFF2D3748)],
    ),
    JournalType(
      title: "Dream",
      subtitle: "Night memories",
      icon: Icons.nightlight_round,
      colors: [const Color(0xFF7F9CF5), const Color(0xFF4C51BF)],
    ),
    JournalType(
      title: "Free Write",
      subtitle: "No rules",
      icon: Icons.edit_note_rounded,
      colors: [const Color(0xFF4FD1C5), const Color(0xFF319795)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Journal Modes",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: _types.length,
            itemBuilder: (context, index) {
              final type = _types[index];
              return JournalTypeCard(
                type: type,
                onTap: () {
                  context.push(
                    '/journal/editor',
                    extra: JournalEntry(
                      id: '',
                      userId: '',
                      content: '',
                      journalType: type.title.toUpperCase().replaceAll(' ', '_'),
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
