/// Heure(s) de rappel d'un traitement à fréquence quotidienne
/// ([TreatmentFrequency.daily]/[TreatmentFrequency.severalTimesDaily],
/// ajoutées le 2026-08-17) — une ou plusieurs heures du jour auxquelles
/// un rappel récurrent doit se déclencher (ex. 08:00 et 20:00 pour un
/// médicament deux fois par jour).
///
/// Représentées en minutes depuis minuit (`0..1439`) plutôt qu'un type
/// dédié : `Treatment.reminderTimes` (colonne Drift `TEXT`) les stocke en
/// CSV via [encodeReminderTimes]/[decodeReminderTimes], et `TimeOfDay`
/// (type Flutter) reste cantonné à la couche présentation — le domaine
/// et le repository n'en dépendent pas, même principe que le reste de ce
/// dossier (`treatment_frequency.dart` n'importe pas Flutter non plus).
library;

/// Décode le CSV stocké en base (`"480,1200"` → `[480, 1200]`), triées et
/// sans doublon. `null`/vide → liste vide (traitement à cycle long, qui
/// n'utilise pas ce champ — voir [TreatmentFrequency.usesReminderTimes]
/// dans `treatment_frequency.dart`).
List<int> decodeReminderTimes(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  return {for (final part in raw.split(',')) int.parse(part)}.toList()..sort();
}

/// Encode en CSV pour stockage (`Treatment.reminderTimes`), triées et
/// sans doublon.
String encodeReminderTimes(List<int> minutesOfDay) =>
    ({...minutesOfDay}.toList()..sort()).join(',');

/// Prochaine occurrence à partir de [now] : la première heure de
/// [minutesOfDay] encore à venir aujourd'hui, ou la première de demain si
/// toutes celles d'aujourd'hui sont déjà passées.
///
/// [minutesOfDay] ne doit pas être vide — un traitement à fréquence
/// [TreatmentFrequency.daily]/[TreatmentFrequency.severalTimesDaily] a
/// toujours au moins une heure de rappel (imposé par la validation du
/// formulaire, `treatment_form_screen.dart`).
DateTime nextReminderDateTime(List<int> minutesOfDay, DateTime now) {
  if (minutesOfDay.isEmpty) {
    throw ArgumentError.value(
      minutesOfDay,
      'minutesOfDay',
      'au moins une heure de rappel est requise',
    );
  }

  final sorted = [...minutesOfDay]..sort();
  final today = DateTime(now.year, now.month, now.day);
  final nowMinuteOfDay = now.hour * 60 + now.minute;

  for (final minute in sorted) {
    if (minute > nowMinuteOfDay) {
      return today.add(Duration(minutes: minute));
    }
  }
  // Toutes les heures d'aujourd'hui sont passées (ou égales à l'instant
  // présent, à la minute près) : la prochaine est la première de demain.
  return today.add(Duration(days: 1, minutes: sorted.first));
}

/// "08:00" — formatage pour affichage (carte, aperçu du formulaire,
/// accueil), à partir des minutes depuis minuit.
String formatMinuteOfDay(int minutesOfDay) {
  final hour = (minutesOfDay ~/ 60).toString().padLeft(2, '0');
  final minute = (minutesOfDay % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// "Aujourd'hui à 20:00" / "Demain à 08:00" — description lisible d'une
/// occurrence produite par [nextReminderDateTime]. Partagée entre
/// `TreatmentFormScreen` (aperçu "Prochain rappel") et `TreatmentCard`
/// (ligne "Prochaine dose") pour ne pas dupliquer cette mise en forme.
String describeUpcomingReminder(DateTime due, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final dueDay = DateTime(due.year, due.month, due.day);
  final time = formatMinuteOfDay(due.hour * 60 + due.minute);

  if (dueDay == today) return 'Aujourd\'hui à $time';
  if (dueDay == today.add(const Duration(days: 1))) return 'Demain à $time';
  // N'arrive normalement pas en lecture juste après
  // `reconcileOverdueTreatments` (l'écran l'appelle avant d'afficher),
  // mais reste correct si jamais l'app n'a pas encore eu l'occasion de
  // rattraper un jour dépassé.
  return 'En retard ($time)';
}
