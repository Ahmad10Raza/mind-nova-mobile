import 'package:flutter/material.dart';

class ChallengeProgressBar extends StatelessWidget {
  final int currentDay;
  final int totalDays;
  final Color? activeColor;
  final Color? inactiveColor;

  const ChallengeProgressBar({
    super.key,
    required this.currentDay,
    required this.totalDays,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? const Color(0xFF9147FF);
    final inactive = inactiveColor ?? Colors.white.withOpacity(0.15);
    final progress = totalDays > 0 ? (currentDay - 1) / totalDays : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: inactive,
                valueColor: AlwaysStoppedAnimation(active),
                minHeight: 8,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Day markers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalDays, (i) {
            final dayNum = i + 1;
            final isCompleted = dayNum < currentDay;
            final isCurrent = dayNum == currentDay;

            return Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? active
                        : isCurrent
                            ? active.withOpacity(0.5)
                            : inactive,
                    border: isCurrent
                        ? Border.all(color: active, width: 2)
                        : null,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : Center(
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isCurrent
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
