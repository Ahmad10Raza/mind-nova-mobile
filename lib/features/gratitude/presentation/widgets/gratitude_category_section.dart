import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GratitudeCategory {
  final String name;
  final IconData icon;
  final Color baseColor;

  GratitudeCategory(this.name, this.icon, this.baseColor);
}

class GratitudeCategorySection extends StatelessWidget {
  const GratitudeCategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      GratitudeCategory('Family', Icons.family_restroom_rounded, const Color(0xFFF6AD55)),
      GratitudeCategory('Career', Icons.work_outline_rounded, const Color(0xFF63B3ED)),
      GratitudeCategory('Health', Icons.favorite_border_rounded, const Color(0xFFFC8181)),
      GratitudeCategory('Nature', Icons.park_outlined, const Color(0xFF68D391)),
      GratitudeCategory('Growth', Icons.trending_up_rounded, const Color(0xFFB794F4)),
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Container(
            width: 100,
            decoration: BoxDecoration(
              color: cat.baseColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cat.baseColor.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat.icon, color: cat.baseColor.withOpacity(0.9), size: 32),
                const SizedBox(height: 8),
                Text(
                  cat.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: const Color(0xFFDFE2F3),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
