/// Fréquence récurrente d'un traitement (vermifuge/antiparasitaire ou
/// médicament) — ce qui distingue les traitements des vaccins dans ce
/// schéma par ailleurs identique (`01-architecture.md`, épic 4).
///
/// Deux familles, distinguées par [usesReminderTimes] :
/// - Cycles longs ([monthly] à [annual]) : un jeu de valeurs prédéfinies
///   plutôt qu'une saisie libre en jours, cohérent avec le différenciant
///   "saisie rapide" (`docs/product/04-differenciation.md`) et avec les
///   fréquences réellement prescrites pour ce type de traitement (mensuel
///   pour la plupart des antiparasitaires, trimestriel pour certains
///   comme Bravecto — cf. maquette —, jusqu'à annuel pour certains
///   vermifuges). Prochaine échéance calculée par [nextOccurrenceAfter].
/// - Rappels quotidiens ([daily]/[severalTimesDaily], ajoutés le
///   2026-08-17) : pour un médicament pris une ou plusieurs fois par jour
///   à heure fixe (ex. antibiotique) — la notion de "prochaine échéance à
///   X mois" ne s'applique pas, seule compte l'heure du jour ; voir
///   `reminder_times.dart` pour le calcul de la prochaine occurrence et
///   `TreatmentRepository` pour la programmation des rappels natifs
///   récurrents (un par heure choisie).
///
/// **Valeurs ajoutées en fin de liste, jamais insérées au milieu** :
/// stockées comme entier (`intEnum<TreatmentFrequency>()` dans
/// `treatment_table.dart`), l'index de chaque valeur est persisté tel
/// quel en base — en insérer une au milieu changerait rétroactivement le
/// sens des lignes déjà enregistrées.
enum TreatmentFrequency {
  monthly,
  quarterly,
  biannual,
  annual,
  daily,
  severalTimesDaily;

  /// `true` pour les fréquences à heure(s) de rappel fixe(s)
  /// ([daily]/[severalTimesDaily]) — ce sont elles qui consomment
  /// `Treatment.reminderTimes`, pas les cycles longs.
  bool get usesReminderTimes =>
      this == TreatmentFrequency.daily ||
      this == TreatmentFrequency.severalTimesDaily;

  int get _months => switch (this) {
    TreatmentFrequency.monthly => 1,
    TreatmentFrequency.quarterly => 3,
    TreatmentFrequency.biannual => 6,
    TreatmentFrequency.annual => 12,
    TreatmentFrequency.daily ||
    TreatmentFrequency.severalTimesDaily => throw StateError(
      'nextOccurrenceAfter ne s\'applique pas à $this — voir '
      'reminder_times.dart pour les fréquences à heure(s) fixe(s).',
    ),
  };

  /// Prochaine occurrence après [date] — `DateTime` normalise tout seul
  /// un débordement de mois (ex. mois 13 → janvier de l'année
  /// suivante), pas besoin de le gérer à la main ici.
  ///
  /// Réservée aux cycles longs ([usesReminderTimes] `false`) : pour
  /// [daily]/[severalTimesDaily], voir `nextReminderDateTime` dans
  /// `reminder_times.dart`.
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
    TreatmentFrequency.daily => 'Tous les jours',
    TreatmentFrequency.severalTimesDaily => 'Plusieurs fois par jour',
  };
}
