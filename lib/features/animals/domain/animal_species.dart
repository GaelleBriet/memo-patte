/// Espèces couvertes en v1 (voir `docs/product/06-mvp-scope.md`).
///
/// Volontairement limité à chien/chat : élargir la couverture d'espèces
/// sans que ça réponde à un vrai pain point identifié est un piège observé
/// chez la concurrence (voir DogCat dans `docs/product/01-competitors/`).
enum AnimalSpecies { dog, cat }

/// Libellé français affiché à l'écran — centralisé ici pour éviter que
/// chaque écran (création, liste, profil...) ne code sa propre traduction.
extension AnimalSpeciesLabel on AnimalSpecies {
  String get label => switch (this) {
    AnimalSpecies.dog => 'Chien',
    AnimalSpecies.cat => 'Chat',
  };
}
