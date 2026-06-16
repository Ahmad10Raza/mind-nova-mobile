import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'widgets/grounding_tool_card.dart';

class GroundingHubScreen extends StatelessWidget {
  const GroundingHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F101A), // Dark navy theme
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Header ──────────────────────────────────────────
            SliverAppBar(
              backgroundColor: const Color(0xFF0F101A),
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Grounding',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.history_rounded, color: Colors.white70),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white70),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),

            // ─── Your Badges ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Badges',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildBadge(
                            icon: Icons.eco_rounded,
                            label: 'First Calm',
                            color: const Color(0xFF81C784),
                          ),
                          const SizedBox(width: 12),
                          _buildBadge(
                            icon: Icons.shield_rounded,
                            label: 'Panic Reset Hero',
                            color: const Color(0xFF90CAF9),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Grounding Exercises Grid ────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Text(
                  'Grounding Exercises',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  GroundingToolCard(
                    title: '5-4-3-2-1',
                    subtitle: 'Sensory anchoring',
                    icon: Icons.visibility_rounded,
                    color: const Color(0xFF00897B),
                    onTap: () {},
                  ),
                  GroundingToolCard(
                    title: 'Panic Reset',
                    subtitle: 'Immediate relief',
                    icon: Icons.ac_unit_rounded, // Asterisk-like
                    color: const Color(0xFF5E35B1),
                    onTap: () {},
                  ),
                  GroundingToolCard(
                    title: 'Touch & Hold',
                    subtitle: 'Feel the present',
                    icon: Icons.touch_app_rounded,
                    color: const Color(0xFF1565C0),
                    onTap: () {},
                  ),
                  GroundingToolCard(
                    title: 'Safe Place',
                    subtitle: 'Visualize calm',
                    icon: Icons.landscape_rounded,
                    color: const Color(0xFF00695C),
                    onTap: () {},
                  ),
                  GroundingToolCard(
                    title: 'Body Scan',
                    subtitle: 'Release tension',
                    icon: Icons.accessibility_new_rounded,
                    color: const Color(0xFFE65100),
                    onTap: () {}, // Will route to real body scan when built
                  ),
                  GroundingToolCard(
                    title: 'Color Breathing',
                    subtitle: 'Breathe with color',
                    icon: Icons.language_rounded,
                    color: const Color(0xFF0277BD),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 120), // Bottom padding for Nav Bar
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
