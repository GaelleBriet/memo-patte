import '../../vaccinations/domain/vaccination_status.dart';

/// Un rappel affiché dans la section "À faire aujourd'hui" de l'accueil
/// (ticket 6.2), déjà résolu à un animal et une échéance précis.
///
/// Aujourd'hui, seuls les vaccins produisent des [HomeReminder] (épic 4
/// "treatments" pas encore faite — voir `home_reminders_provider.dart`
/// pour comment ce type reste prêt à en recevoir d'autres sans
/// réécriture).
class HomeReminder {
  const HomeReminder({
    required this.animalId,
    required this.animalName,
    required this.vaccinationId,
    required this.title,
    required this.detail,
    required this.dueDate,
    required this.status,
  });

  final int animalId;
  final String animalName;

  /// Id du vaccin source — permet à l'accueil de router directement vers
  /// son édition au tap, sans re-résoudre "quel vaccin" côté écran.
  final int vaccinationId;

  /// Ex. "Rappel de vaccin" — générique, pas le nom du vaccin lui-même
  /// (voir [detail]), pour rester cohérent visuellement le jour où les
  /// traitements s'ajoutent ("Rappel de traitement", même gabarit).
  final String title;

  /// Ex. "Rage" — le détail spécifique à cette échéance.
  final String detail;

  final DateTime dueDate;

  /// Toujours `dueSoon` ou `overdue` : un rappel "à jour" n'a rien à
  /// faire dans "À faire aujourd'hui" (filtré à la source, voir le
  /// provider).
  ///
  /// Réutilise le type `vaccinations` tel quel plutôt que d'en extraire
  /// un type générique par anticipation — le jour où l'épic 4
  /// (`treatments`) alimentera aussi cette liste, la logique de calcul
  /// (`fromNextDueDate`) sera de toute façon identique et pourra migrer
  /// vers `core/` à ce moment-là, avec un vrai deuxième appelant sous les
  /// yeux plutôt qu'une supposition.
  final VaccinationStatus status;
}
