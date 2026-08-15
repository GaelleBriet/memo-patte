import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Force des icônes claires dans la barre de statut, réaffirmées à
/// chaque frame — pour les écrans à hero sombre qui n'ont pas d'`AppBar`
/// (accueil, Carnet de santé ; `GradientAppBar` s'en charge elle-même
/// pour les autres, via son propre `systemOverlayStyle`).
///
/// Complète le réglage global posé une fois dans `main.dart` plutôt que
/// de le remplacer : signalé le 2026-08-16 que l'icône restait parfois
/// sombre après être passé par un écran à `AppBar` puis revenu ici — la
/// détection du style système par Flutter se fait par `AnnotatedRegion`
/// trouvée dans l'arbre courant à chaque frame, un réglage posé une
/// seule fois avant le premier `runApp` ne suffit pas à rester valable
/// après un aller-retour par un écran qui en déclare une différente.
class LightStatusBar extends StatelessWidget {
  const LightStatusBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: child,
    );
  }
}
