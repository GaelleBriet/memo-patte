import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/database/app_database.dart';

/// Sélecteur d'animaux en chips, partagé entre l'accueil (ticket 6.2) et
/// le Carnet de santé (ticket 6.4) — même rendu sur les deux écrans,
/// demandé explicitement le 2026-08-15 plutôt que deux implémentations
/// qui pourraient diverger.
///
/// Chip de l'animal affiché : contour sarcelle (couleur). Les autres :
/// contour gris/beige léger. Chip "+" en dernier : fond clair, contour en
/// pointillés (voir [_DashedCircleBorder]) — pas de style plein comme le
/// reste, pour bien le distinguer comme une action plutôt qu'une
/// sélection.
class AnimalChipSelector extends StatelessWidget {
  const AnimalChipSelector({
    super.key,
    required this.animals,
    required this.selectedAnimalId,
    required this.onSelect,
    required this.onAdd,
  });

  final List<Animal> animals;
  final int? selectedAnimalId;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  /// 48 : taille de cible tactile minimale recommandée (Material,
  /// ~48dp) — les 40 px du premier rendu étaient un peu justes,
  /// signalé le 2026-08-15 (chips qui demandaient plusieurs taps pour
  /// être pris en compte, plus probable sur une cible un peu petite
  /// dans une rangée qui scrolle — la zone de geste doit départager
  /// clairement "tap" de "début de scroll horizontal").
  static const height = 48.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          for (final animal in animals)
            Padding(
              key: ValueKey(animal.id),
              padding: const EdgeInsets.only(right: 8),
              child: _AnimalChip(
                label: animal.name,
                selected: animal.id == selectedAnimalId,
                onTap: () => onSelect(animal.id),
              ),
            ),
          _AddAnimalChip(onTap: onAdd),
        ],
      ),
    );
  }
}

class _AnimalChip extends StatelessWidget {
  const _AnimalChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Hauteur fixe plutôt qu'un simple padding vertical : garantit
      // une cible tactile d'exactement [AnimalChipSelector.height],
      // sans dépendre de ce que la `ListView` horizontale parente
      // transmet comme contrainte de hauteur (`SizedBox` l'impose,
      // point final — contrairement à un `minHeight` sur
      // `ConstrainedBox`, sans risque d'ambiguïté de layout).
      height: AnimalChipSelector.height,
      child: Material(
        color: AppTheme.cardSurface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? AppTheme.primaryTeal : AppTheme.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 10,
                    backgroundColor: AppTheme.mint,
                    child: Icon(
                      Icons.pets,
                      size: 12,
                      color: AppTheme.tealOnMint,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddAnimalChip extends StatelessWidget {
  const _AddAnimalChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Carré de côté [AnimalChipSelector.height] : même cible tactile
    // que les chips animaux (`_AnimalChip`), et le cercle en pointillés
    // (peint par-dessus, cf. `_DashedCircleBorder`) épouse exactement
    // ce carré.
    return SizedBox.square(
      dimension: AnimalChipSelector.height,
      child: CustomPaint(
        painter: _DashedCircleBorder(color: AppTheme.textSecondary),
        child: Material(
          color: AppTheme.cardSurface,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: const Center(
              child: Icon(Icons.add, color: AppTheme.textSecondary, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

/// Contour en pointillés du chip "+" — pas de dépendance à un package
/// tiers (`dotted_border` & co.) pour une seule bordure, même choix que
/// le reste du code (dates/âge formatés à la main, cf.
/// `home_screen.dart`/`animal_profile_screen.dart`).
class _DashedCircleBorder extends CustomPainter {
  const _DashedCircleBorder({required this.color});

  final Color color;

  static const _dashLength = 4.0;
  static const _gapLength = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (_dashLength + _gapLength)).floor();
    final dashAngle = _dashLength / radius;
    final gapAngle = _gapLength / radius;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    var angle = -math.pi / 2;
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        dashAngle,
        false,
        paint,
      );
      angle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCircleBorder oldDelegate) =>
      oldDelegate.color != color;
}
