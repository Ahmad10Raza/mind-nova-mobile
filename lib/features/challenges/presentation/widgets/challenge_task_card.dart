import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../models/challenge_model.dart';

class ChallengeTaskCard extends StatelessWidget {
  final ChallengeTask task;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const ChallengeTaskCard({
    super.key,
    required this.task,
    required this.isChecked,
    required this.onChanged,
  });

  IconData _typeIcon() {
    switch (task.type) {
      case 'BREATHING':
        return Icons.air_rounded;
      case 'AUDIO':
        return Icons.headphones_rounded;
      case 'HABIT':
        return Icons.self_improvement_rounded;
      case 'REFLECTION':
        return Icons.edit_note_rounded;
      default:
        return Icons.check_circle_outline;
    }
  }

  String _typeEmoji() {
    switch (task.type) {
      case 'BREATHING':
        return '🌬️';
      case 'AUDIO':
        return '🎧';
      case 'HABIT':
        return '🧘';
      case 'REFLECTION':
        return '📝';
      default:
        return '✅';
    }
  }

  Color _typeColor() {
    switch (task.type) {
      case 'BREATHING':
        return const Color(0xFF4FC3F7);
      case 'AUDIO':
        return const Color(0xFFBA68C8);
      case 'HABIT':
        return const Color(0xFF81C784);
      case 'REFLECTION':
        return const Color(0xFFFFB74D);
      default:
        return const Color(0xFF9147FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isChecked
            ? color.withOpacity(0.15)
            : const Color(0xFF1B1F2C).withOpacity(0.6),
        border: Border.all(
          color: isChecked ? color.withOpacity(0.4) : Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (isChecked) {
              onChanged(false);
              return;
            }
            
            String? route;
            final title = task.title.toLowerCase();

            // Keyword-based routing
            if (title.contains('body scan')) {
              route = '/grounding/body-scan';
            } else if (title.contains('5-4-3-2-1') || title.contains('sensory')) {
              route = '/grounding/sensory';
            } else if (title.contains('screen curfew') || title.contains('focus block') || title.contains('deep focus')) {
              route = '/focus';
            } else if (title.contains('panic') || title.contains('crisis')) {
              route = '/grounding/panic';
            } else if (title.contains('safe place')) {
              route = '/grounding/safe-place';
            } else if (title.contains('color breathing')) {
              route = '/grounding/color-breathing';
            } else if (title.contains('touch') || title.contains('hold')) {
              route = '/grounding/touch-hold';
            } else {
              // Type-based fallback
              switch (task.type) {
                case 'BREATHING':
                  route = '/sleep/breathing';
                  break;
                case 'AUDIO':
                  route = '/audio';
                  break;
                case 'REFLECTION':
                  route = '/journal/editor';
                  break;
                case 'HABIT':
                  route = null;
                  break;
              }
            }

            if (route != null) {
              // Navigate to the respective tool
              await GoRouter.of(context).push(route);
              // Automatically mark as complete when they return
              onChanged(true);
            } else {
              onChanged(true);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isChecked ? color : Colors.transparent,
                    border: Border.all(
                      color: isChecked ? color : Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _typeEmoji(),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              task.title,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isChecked
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.white,
                                decoration: isChecked
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (task.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.4),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Duration badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${task.duration}m',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                // Habit link indicator
                if (task.habitId != null) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.link_rounded,
                    size: 14,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
