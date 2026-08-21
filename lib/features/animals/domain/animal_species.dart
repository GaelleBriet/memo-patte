import 'package:flutter/widgets.dart' show BuildContext;

import '../../../l10n/generated/app_localizations.dart';

/// Espèces couvertes en v1 (voir `docs/product/06-mvp-scope.md`).
///
/// Volontairement limité à chien/chat : élargir la couverture d'espèces
/// sans que ça réponde à un vrai pain point identifié est un piège observé
/// chez la concurrence (voir DogCat dans `docs/product/01-competitors/`).
enum AnimalSpecies { dog, cat }

/// Libellé affiché à l'écran — centralisé ici pour éviter que chaque
/// écran (création, liste, profil...) ne code sa propre traduction.
/// Méthode plutôt que getter depuis la préparation i18n (audit du
/// 2026-08-19, issue #71 point 3.3) — voir le commentaire équivalent de
/// [DueStatusLabel] dans `core/domain/due_status.dart`.
extension AnimalSpeciesLabel on AnimalSpecies {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      AnimalSpecies.dog => l10n.animalSpeciesDog,
      AnimalSpecies.cat => l10n.animalSpeciesCat,
    };
  }
}
