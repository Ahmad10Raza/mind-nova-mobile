import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../models/group_model.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final bool isRecommended;

  const GroupCard({
    super.key,
    required this.group,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/groups/${group.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isRecommended 
                ? const Color(0xFFB388FF).withOpacity(0.3) 
                : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
          boxShadow: [
            if (isRecommended)
              BoxShadow(
                color: const Color(0xFFB388FF).withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(group.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    group.category,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _getCategoryColor(group.category),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.people_alt_rounded, 
                        color: Colors.white38, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${group.memberCount}/${group.maxMembers}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              group.title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              group.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.4,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildMetric(
                  Icons.favorite_rounded, 
                  '${group.healthScore.toInt()}% Health', 
                  const Color(0xFF81C784),
                ),
                const SizedBox(width: 16),
                _buildMetric(
                  Icons.speed_rounded, 
                  'Safe Mode', 
                  const Color(0xFF64B5F6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color.withOpacity(0.7), size: 14),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'ANXIETY': return const Color(0xFF90CAF9);
      case 'BURNOUT': return const Color(0xFFFFAB91);
      case 'LONELINESS': return const Color(0xFFCE93D8);
      case 'OVERTHINKING': return const Color(0xFFA5D6A7);
      case 'DISCIPLINE': return const Color(0xFFFFF59D);
      default: return const Color(0xFFB0BEC5);
    }
  }
}
