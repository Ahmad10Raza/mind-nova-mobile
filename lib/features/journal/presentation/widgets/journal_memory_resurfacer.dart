import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JournalMemoryResurfacer extends StatelessWidget {
  const JournalMemoryResurfacer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF4), // Soft mint
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFC6F6D5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.history_rounded, color: Color(0xFF38A169), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Memory Resurfacing",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "One year ago, you felt much calmer after writing about your morning routine.",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF4A5568),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF38A169)),
        ],
      ),
    );
  }
}
