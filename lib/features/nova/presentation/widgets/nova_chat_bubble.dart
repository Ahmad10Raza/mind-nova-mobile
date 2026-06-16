import 'package:flutter/material.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../../../core/design/shadows/app_shadows.dart';

import '../../../chat/models/chat_model.dart';
import 'nova_avatar_widget.dart';

class NovaChatBubble extends StatelessWidget {
  final ChatMessage message;

  const NovaChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Nova avatar (left side for AI messages)
          if (!isUser) ...[
            const NovaAvatarWidget(size: 36, isActive: false),
            AppSpacing.h12,
          ],

          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s20,
                vertical: AppSpacing.s16,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.novaPurple
                    : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.radiusMD),
                  topRight: const Radius.circular(AppRadius.radiusMD),
                  bottomLeft: Radius.circular(
                    isUser ? AppRadius.radiusMD : AppRadius.radiusXS,
                  ),
                  bottomRight: Radius.circular(
                    isUser ? AppRadius.radiusXS : AppRadius.radiusMD,
                  ),
                ),
                boxShadow: AppShadows.shadowSubtle,
              ),
              child: Text(
                message.content,
                style: AppTypography.body.copyWith(
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),

          if (isUser) AppSpacing.h8,
        ],
      ),
    );
  }
}
