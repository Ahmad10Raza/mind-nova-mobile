import 'package:flutter/material.dart';
import '../../design/colors/app_colors.dart';
import '../../design/typography/app_typography.dart';
import '../../design/surfaces/app_surfaces.dart';
import '../buttons/mind_nova_icon_button.dart';

class MindNovaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const MindNovaAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppSurfaces.primary,
      elevation: 0,
      centerTitle: true,
      leading: showBackButton && Navigator.canPop(context)
          ? MindNovaIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(title, style: AppTypography.headingMedium),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MindNovaTransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final bool showBackButton;

  const MindNovaTransparentAppBar({
    Key? key,
    this.actions,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: showBackButton && Navigator.canPop(context)
          ? MindNovaIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: () => Navigator.pop(context),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
