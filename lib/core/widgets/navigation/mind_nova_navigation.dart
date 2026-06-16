import 'package:flutter/material.dart';
import '../../design/colors/app_colors.dart';
import '../../design/radius/app_radius.dart';
import '../../design/shadows/app_shadows.dart';
import '../../design/spacing/app_spacing.dart';

class EmotionalBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const EmotionalBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.radiusLG)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.radiusLG)),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: AppColors.backgroundSecondary,
          selectedItemColor: AppColors.novaPurple,
          unselectedItemColor: AppColors.textMuted,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: items,
        ),
      ),
    );
  }
}

class FloatingQuickActions extends StatelessWidget {
  final VoidCallback onBreathe;
  final VoidCallback onJournal;

  const FloatingQuickActions({
    Key? key,
    required this.onBreathe,
    required this.onJournal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAction(Icons.air_rounded, AppColors.recoveryBlue, onBreathe),
        AppSpacing.h16,
        _buildAction(Icons.edit_rounded, AppColors.novaPurple, onJournal),
      ],
    );
  }

  Widget _buildAction(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5)),
          boxShadow: AppShadows.shadowFloating,
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}
