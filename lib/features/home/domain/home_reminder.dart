import '../../../core/domain/due_status.dart';

/// Source d'un [HomeReminder] — détermine vers quelle route le tap sur
/// la carte doit naviguer (voir `home_screen.dart`, `_ReminderCard`).
enum ReminderKind { vaccination, treatment }

/// Un rappel affiché dans la section "À faire aujourd'hui" de l'accueil
/// (ticket 6.2), déjà résolu à un animal et une échéance précis.
///
/// Vaccins (épic 3) et traitements (épic 4) produisent tous les deux des
/// [HomeReminder] — voir `home_reminders_provider.dart` pour comment ils
/// sont fusionnés dans une même liste triée.
class HomeReminder {
  const HomeReminder({
    required this.animalId,
    required this.animalName,
    required this.kind,
    required this.sourceId,
    required this.title,
    required this.detail,
    required this.dueDate,
    required this.status,
  });

  final int animalId;
  final String animalName;

  final ReminderKind kind;

  /// Id du vaccin ou du traitement source, selon [kind] — permet à
  /// l'accueil de router directement vers son édition au tap, sans
  /// re-résoudre "quel enregistrement" côté écran.
  final int sourceId;

  /// Ex. "Rappel de vaccin" / "Rappel de traitement" — générique, pas le
  /// nom du vaccin/traitement lui-même (voir [detail]), pour un gabarit
  /// visuel cohérent entre les deux [kind].
  final String title;

  /// Ex. "Rage" / "Bravecto" — le détail spécifique à cette échéance.
  final String detail;

  final DateTime dueDate;

  /// Toujours `dueSoon` ou `overdue` : un rappel "à jour" n'a rien à
  /// faire dans "À faire aujourd'hui" (filtré à la source, voir le
  /// provider).
  final DueStatus status;
}
