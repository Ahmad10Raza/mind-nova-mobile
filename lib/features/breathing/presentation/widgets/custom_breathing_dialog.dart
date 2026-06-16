import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/breathing_model.dart';
import '../../providers/breathing_persistence_provider.dart';
import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';

class CustomBreathingDialog extends ConsumerStatefulWidget {
  const CustomBreathingDialog({super.key});

  @override
  ConsumerState<CustomBreathingDialog> createState() => _CustomBreathingDialogState();
}

class _CustomBreathingDialogState extends ConsumerState<CustomBreathingDialog> {
  final TextEditingController _nameController = TextEditingController();
  int inhale = 4;
  int holdIn = 4;
  int exhale = 4;
  int holdOut = 4;
  int cycles = 10;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceHighest,
      title: Text('Custom Rhythm', style: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Technique Name',
                labelStyle: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                hintText: 'e.g. Morning Flow',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted.withOpacity(0.5)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.novaPurple)),
              ),
            ),
            AppSpacing.v24,
            _buildSlider('Inhale', inhale, 's', 1, 15, (v) => setState(() => inhale = v.toInt())),
            _buildSlider('Hold In', holdIn, 's', 0, 15, (v) => setState(() => holdIn = v.toInt())),
            _buildSlider('Exhale', exhale, 's', 1, 15, (v) => setState(() => exhale = v.toInt())),
            _buildSlider('Hold Out', holdOut, 's', 0, 15, (v) => setState(() => holdOut = v.toInt())),
            const Divider(color: Colors.white12),
            _buildSlider('Repetitions', cycles, 'x', 1, 50, (v) => setState(() => cycles = v.toInt())),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: Text('Cancel', style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.novaPurple,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            final name = _nameController.text.trim();
            final technique = BreathingTechnique(
              id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
              name: name.isEmpty ? 'Custom Session' : name,
              description: 'Personalized interval session.',
              inhale: inhale,
              holdIn: holdIn,
              exhale: exhale,
              holdOut: holdOut,
              targetCycles: cycles,
            );
            
            // Persist to local storage
            await ref.read(customBreathingProvider.notifier).add(technique);

            if (context.mounted) {
              Navigator.pop(context);
              context.push('/breathing/exercise', extra: technique);
            }
          },
          child: const Text('Start'),
        ),
      ],
    );
  }

  Widget _buildSlider(String label, int value, String suffix, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
            Text('$value$suffix', style: AppTypography.labelMedium.copyWith(color: AppColors.novaPurple)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          activeColor: AppColors.novaPurple,
          inactiveColor: AppColors.novaPurple.withOpacity(0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

