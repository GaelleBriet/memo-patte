import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// AppBar portant le dégradé sarcelle signature des en-têtes de
/// `docs/design/PetCare - Ma Vision` ([AppTheme.headerGradient]).
/// `AppBarTheme` ne sait pas exprimer un dégradé globalement — ce
/// wrapper évite de répéter le `flexibleSpace` dans chaque écran.
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({super.key, required this.title, this.actions});

  final Widget title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: actions,
      flexibleSpace: Container(decoration: AppTheme.headerGradient),
    );
  }
}
