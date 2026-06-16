import 'package:flutter/material.dart';
import '../design/colors/app_colors.dart';
import '../design/typography/app_typography.dart';
import '../design/spacing/app_spacing.dart';
import '../design/surfaces/app_surfaces.dart';
import '../widgets/buttons/mind_nova_buttons.dart';
import '../widgets/buttons/mind_nova_floating_button.dart';
import '../widgets/cards/mind_nova_cards.dart';
import '../widgets/states/mind_nova_empty_state.dart';
import '../widgets/inputs/mind_nova_inputs.dart';
import '../widgets/chips/mind_nova_chips.dart';
import '../widgets/avatars/mind_nova_avatars.dart';
import '../widgets/loading/mind_nova_loading.dart';
import '../widgets/progress/mind_nova_progress.dart';
import '../widgets/feedback/mind_nova_toast.dart';
import '../widgets/sections/mind_nova_sections.dart';

class DesignPlaygroundScreen extends StatelessWidget {
  const DesignPlaygroundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      appBar: AppBar(
        title: Text('MindNova UI Laboratory', style: AppTypography.headingMedium),
        backgroundColor: AppSurfaces.elevated,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        children: [
          _buildSectionTitle('Inputs & Forms'),
          const MindNovaTextField(hintText: 'How are you feeling today?'),
          AppSpacing.v16,
          const MindNovaSearchField(hintText: 'Search past journal entries...'),
          
          AppSpacing.v40,
          _buildSectionTitle('Chips & Tags'),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: [
              EmotionChip(label: 'Anxious', isSelected: true, activeColor: AppColors.warmSupport, onTap: () {}),
              EmotionChip(label: 'Calm', isSelected: false, onTap: () {}),
              EmotionChip(label: 'Focused', isSelected: false, onTap: () {}),
            ],
          ),

          AppSpacing.v40,
          _buildSectionTitle('Avatars & Mascots'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              NovaAvatar(size: 64),
              EmotionalSpirit(doodleAssetPath: '', size: 80),
            ],
          ),

          AppSpacing.v40,
          _buildSectionTitle('Progress & Data'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ProgressRing(
                progress: 0.75,
                centerChild: Text('75%', style: AppTypography.headingLarge),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: AppSpacing.s24),
                  child: RecoveryMeter(recoveryLevel: 0.6, label: 'Emotional Stabilization'),
                ),
              ),
            ],
          ),

          AppSpacing.v40,
          _buildSectionTitle('Loading States'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              BreathingLoader(size: 64),
              MindNovaSkeleton(width: 120, height: 80),
            ],
          ),

          AppSpacing.v40,
          _buildSectionTitle('Cards Expansion'),
          MindNovaRecoveryCard(onTap: () {}),
          AppSpacing.v16,
          MindNovaCompactCard(
            title: 'Daily Reflection',
            trailing: const Icon(Icons.check_circle, color: AppColors.successSoft),
            onTap: () {},
          ),

          AppSpacing.v40,
          _buildSectionTitle('Empty States'),
          MindNovaRecoveryEmptyState(onBreathePressed: () {}),
          AppSpacing.v32,
          MindNovaTherapyEmptyState(onHelpPressed: () {}),

          AppSpacing.v40,
          _buildSectionTitle('Feedback'),
          MindNovaPrimaryButton(
            text: 'Show Soft Toast',
            onPressed: () => MindNovaToast.show(context, message: 'Your reflection was saved safely.', icon: Icons.lock_rounded),
          ),
          
          AppSpacing.v64,
        ],
      ),
      floatingActionButton: MindNovaFloatingButton(
        icon: Icons.add_rounded,
        onPressed: () {},
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s24),
      child: Text(
        title,
        style: AppTypography.headingMedium.copyWith(color: AppColors.calmTeal),
      ),
    );
  }
}
