/// Fréquence récurrente d'un traitement (vermifuge/antiparasitaire) —
/// ce qui distingue les traitements des vaccins dans ce schéma par
/// ailleurs identique (`01-architecture.md`, épic 4).
///
/// Un jeu de valeurs prédéfinies plutôt qu'une saisie libre en jours :
/// cohérent avec le différenciant "saisie rapide"
/// (`docs/product/04-differenciation.md`) et avec les fréquences
/// réellement prescrites pour ce type de traitement (mensuel pour la
/// plupart des antiparasitaires, trimestriel pour certains comme
/// Bravecto — cf. maquette —, jusqu'à annuel pour certains vermifuges).
enum TreatmentFrequency {
  monthly,
  quarterly,
  biannual,
  annual;

  int get _months => switch (this) {
    TreatmentFrequency.monthly => 1,
    TreatmentFrequency.quarterly => 3,
    TreatmentFrequency.biannual => 6,
    TreatmentFrequency.annual => 12,
  };

  /// Prochaine occurrence après [date] — `DateTime` normalise tout seul
  /// un débordement de mois (ex. mois 13 → janvier de l'année
  /// suivante), pas besoin de le gérer à la main ici.
  DateTime nextOccurrenceAfter(DateTime date) =>
      DateTime(date.year, date.month + _months, date.day);
}

/// Libellé français affiché à l'écran — centralisé ici comme
/// [DueStatusLabel] pour éviter que chaque écran ne code sa propre
/// traduction.
extension TreatmentFrequencyLabel on TreatmentFrequency {
  String get label => switch (this) {
    TreatmentFrequency.monthly => 'Tous les mois',
    TreatmentFrequency.quarterly => 'Tous les 3 mois',
    TreatmentFrequency.biannual => 'Tous les 6 mois',
    TreatmentFrequency.annual => 'Tous les ans',
  };
}
