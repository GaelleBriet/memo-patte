import 'package:flutter/material.dart';

/// Place [chips] à cheval sur le bord inférieur de [hero] — moitié posée
/// sur le dégradé, moitié sur le fond de l'écran, comme sur
/// `docs/design/PetCare - Ma Vision` (demandé explicitement le
/// 2026-08-15, le premier rendu du ticket 6.2 mettait les chips
/// entièrement dans le hero).
///
/// Partagé entre l'accueil et le Carnet de santé (même sélecteur
/// d'animaux, cf. `AnimalChipSelector`) plutôt que dupliqué : c'est
/// uniquement le calage visuel qui est commun ici, le contenu du hero
/// diffère entre les deux écrans.
///
/// Après ce widget, prévoir un espace de [overlap] dans le parent (ex.
/// `SizedBox(height: overlap)` dans une `ListView`) : `Positioned` sort
/// [chips] du flux normal, sans cet espace le contenu suivant chevauche
/// la moitié basse des chips.
class StraddlingHero extends StatelessWidget {
  const StraddlingHero({
    super.key,
    required this.hero,
    required this.chips,
    // Moitié de `AnimalChipSelector.height` (48) : garde le
    // chevauchement pile à 50/50, chips comprises.
    this.overlap = 24,
  });

  final Widget hero;
  final Widget chips;
  final double overlap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      // `passthrough` et pas le défaut (`loose`) : dans une `ListView`,
      // ce `Stack` reçoit une largeur *tight* (= largeur de l'écran) de
      // son parent. `loose` relâche cette contrainte avant de la
      // transmettre à [hero], qui — n'ayant pas de largeur explicite —
      // se réduisait alors à la largeur de son contenu (le texte
      // "Bonjour") au lieu de remplir l'écran : le bug de fond cassé/pas
      // pleine largeur signalé le 2026-08-15. `passthrough` transmet la
      // contrainte reçue telle quelle, sans la relâcher.
      fit: StackFit.passthrough,
      children: [
        hero,
        Positioned(left: 20, right: 20, bottom: -overlap, child: chips),
      ],
    );
  }
}
