import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/gratitude_hero_card.dart';
import 'widgets/gratitude_quick_entry_card.dart';
import 'widgets/gratitude_category_section.dart';
import 'widgets/gratitude_timeline.dart';

class GratitudeDashboardScreen extends ConsumerWidget {
  const GratitudeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F131F),
      body: CustomScrollView(
        slivers: [
          // ─── Custom App Bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 100.0,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF0F131F),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Text(
                'Joy & Gratitude',
                style: GoogleFonts.manrope(
                  color: const Color(0xFFDFE2F3),
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.auto_awesome, color: Color(0xFFFFD700)),
                onPressed: () {
                  // Navigate to Memory Vault
                },
              ),
              const SizedBox(width: 12),
            ],
          ),

          // ─── Content ───────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                const GratitudeHeroCard(),
                
                const SizedBox(height: 32),
                Text(
                  'Quick Reflection',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: const Color(0xFFDFE2F3),
                  ),
                ),
                const SizedBox(height: 16),
                const GratitudeQuickEntryCard(),

                const SizedBox(height: 32),
                Text(
                  'Explore by Mood',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: const Color(0xFFDFE2F3),
                  ),
                ),
                const SizedBox(height: 16),
                const GratitudeCategorySection(),

                const SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Journey',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: const Color(0xFFDFE2F3),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Real implementation of the Timeline
                const GratitudeTimeline(),
                const SizedBox(height: 60),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
