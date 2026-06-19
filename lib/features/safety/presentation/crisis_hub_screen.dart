import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/colors/app_colors.dart';
import '../../../core/design/typography/app_typography.dart';
import '../../../core/design/spacing/app_spacing.dart';
import '../../../core/design/radius/app_radius.dart';

class CrisisHubScreen extends StatelessWidget {
  const CrisisHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withOpacity(0.08),
              borderRadius: AppRadius.md,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textSecondary, size: 18),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Crisis Support',
          style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How can we help?',
                style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary, fontSize: 28),
              ),
              AppSpacing.v8,
              Text(
                'Choose an option below to get the support you need right now.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              AppSpacing.v32,
              
              _buildOptionCard(
                context: context,
                title: 'Immediate SOS',
                description: 'Get grounding help and call 988 or trusted contacts instantly.',
                icon: Icons.health_and_safety_rounded,
                color: AppColors.error,
                route: '/sos-mode',
                isPrimary: true,
              ),
              
              AppSpacing.v16,
              
              _buildOptionCard(
                context: context,
                title: 'Safety Plan',
                description: 'View or update your personalized step-by-step crisis plan.',
                icon: Icons.shield_rounded,
                color: AppColors.recoveryBlue,
                route: '/support-plan',
              ),
              
              AppSpacing.v16,
              
              _buildOptionCard(
                context: context,
                title: 'Safe Contacts',
                description: 'Manage the people you trust to reach out to during difficult times.',
                icon: Icons.people_alt_rounded,
                color: AppColors.successSoft,
                route: '/safe-contacts',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String route,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push(route);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s20),
        decoration: BoxDecoration(
          color: isPrimary ? color.withOpacity(0.15) : AppColors.backgroundSecondary.withOpacity(0.5),
          borderRadius: AppRadius.lg,
          border: Border.all(
            color: isPrimary ? color.withOpacity(0.3) : AppColors.textPrimary.withOpacity(0.1),
            width: isPrimary ? 2 : 1,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: isPrimary ? color.withOpacity(0.2) : AppColors.backgroundTertiary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isPrimary ? color : AppColors.textPrimary, size: 28),
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headingMedium.copyWith(
                      fontSize: 20,
                      color: isPrimary ? color : AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.v4,
                  Text(
                    description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isPrimary ? color.withOpacity(0.5) : AppColors.textDisabled,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
