import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';

class _Pathway {
  final String emoji;
  final String label;
  final int sessionCount;
  final List<Color> gradient;
  final String categoryKey;
  final bool recommended;

  const _Pathway({
    required this.emoji,
    required this.label,
    required this.sessionCount,
    required this.gradient,
    required this.categoryKey,
    this.recommended = false,
  });
}

const _pathways = [
  _Pathway(
    emoji: '😰',
    label: 'Overthinking',
    sessionCount: 12,
    gradient: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
    categoryKey: 'ANXIETY_RELIEF',
    recommended: true,
  ),
  _Pathway(
    emoji: '😴',
    label: "Can't Sleep",
    sessionCount: 24,
    gradient: [Color(0xFF1E3A8A), Color(0xFF312E81)],
    categoryKey: 'SLEEP',
  ),
  _Pathway(
    emoji: '😟',
    label: 'Anxiety Relief',
    sessionCount: 18,
    gradient: [Color(0xFF9333EA), Color(0xFFBE185D)],
    categoryKey: 'ANXIETY_RELIEF',
    recommended: true,
  ),
  _Pathway(
    emoji: '🔥',
    label: 'Burnout Recovery',
    sessionCount: 14,
    gradient: [Color(0xFFEA580C), Color(0xFFB91C1C)],
    categoryKey: 'STRESS_RECOVERY',
  ),
  _Pathway(
    emoji: '💔',
    label: 'Emotional Healing',
    sessionCount: 12,
    gradient: [Color(0xFFBE185D), Color(0xFF9333EA)],
    categoryKey: 'HEALING',
  ),
  _Pathway(
    emoji: '🧘',
    label: 'Need Calm',
    sessionCount: 20,
    gradient: [Color(0xFF0D9488), Color(0xFF0E7490)],
    categoryKey: 'DEEP_RELAXATION',
  ),
  _Pathway(
    emoji: '⚡',
    label: 'Need Energy',
    sessionCount: 8,
    gradient: [Color(0xFFD97706), Color(0xFFEA580C)],
    categoryKey: 'FOCUS',
  ),
  _Pathway(
    emoji: '🌱',
    label: 'Personal Growth',
    sessionCount: 11,
    gradient: [Color(0xFF059669), Color(0xFF0D9488)],
    categoryKey: 'GRATITUDE',
  ),
];

class RecoveryPathwaysSection extends StatelessWidget {
  const RecoveryPathwaysSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.55,
        ),
        itemCount: _pathways.length,
        itemBuilder: (context, index) {
          final p = _pathways[index];
          return _PathwayCard(pathway: p);
        },
      ),
    );
  }
}

class _PathwayCard extends StatefulWidget {
  final _Pathway pathway;
  const _PathwayCard({required this.pathway});

  @override
  State<_PathwayCard> createState() => _PathwayCardState();
}

class _PathwayCardState extends State<_PathwayCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pathway;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        context.push('/meditation/explore', extra: p.categoryKey);
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: p.gradient,
            ),
            borderRadius: AppRadius.lg,
            border: Border.all(color: Colors.white.withAlpha(20)),
            boxShadow: [
              BoxShadow(
                color: p.gradient.last.withAlpha(76),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(p.emoji, style: const TextStyle(fontSize: 24)),
                  const Spacer(),
                  if (p.recommended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(38),
                        borderRadius: AppRadius.xs,
                      ),
                      child: Text(
                        '★',
                        style: AppTypography.labelSmall
                            .copyWith(color: Colors.white, fontSize: 9),
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p.label,
                    style: AppTypography.headingSmall
                        .copyWith(color: Colors.white, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${p.sessionCount} sessions',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withAlpha(153),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
