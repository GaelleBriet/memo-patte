import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Carte blanche arrondie du design `PetCare - Ma Vision` : surface
/// blanc cassé, coins à 16 px, ombre douce (voir [AppTheme.cardShadow]).
/// C'est LE conteneur de contenu du design — listes, sections, tuiles —
/// centralisé ici pour que tous les écrans partagent exactement les
/// mêmes valeurs.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Si présent, la carte entière devient tapable (avec ripple).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: radius,
        boxShadow: AppTheme.cardShadow,
      ),
      // Material transparent au-dessus du Container : nécessaire pour
      // que le ripple de l'InkWell reste visible et épouse les coins.
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Pastille d'icône du design : carré arrondi menthe avec icône
/// sarcelle foncé (ex. actions rapides, sections du carnet).
class IconChip extends StatelessWidget {
  const IconChip({super.key, required this.icon, this.size = 40});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.mint,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.55, color: AppTheme.tealOnMint),
    );
  }
}
