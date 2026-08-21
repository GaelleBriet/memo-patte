import 'package:flutter/widgets.dart' show BuildContext;

import '../../l10n/generated/app_localizations.dart';

/// Statut d'une échéance par rapport à aujourd'hui (à jour / à venir /
/// en retard).
///
/// Extrait de `features/vaccinations/domain/vaccination_status.dart`
/// (ticket 3.3) au moment où l'épic 4 (`treatments`) en a eu besoin à son
/// tour pour son propre statut visuel (ticket 4.3) : annoncé dans le
/// commentaire d'origine de ce fichier plutôt que fait par anticipation
/// — vaccins et traitements partagent exactement ce calcul, même si la
/// prochaine échéance elle-même est saisie pour l'un (`nextDueDate` donné
/// par le vétérinaire) et calculée pour l'autre (`date` + fréquence
/// récurrente, voir `treatments/domain/treatment_frequency.dart`).
enum DueStatus {
  /// Pas d'échéance connue, ou échéance encore lointaine.
  upToDate,

  /// Échéance dans [dueSoonWindow] au plus (aujourd'hui compris).
  dueSoon,

  /// Échéance strictement dépassée (au jour près).
  overdue;

  /// Fenêtre "à venir" : 30 jours — le temps de prendre un rendez-vous
  /// vétérinaire sans urgence. Valeur non spécifiée par le ticket 3.3,
  /// choisie ici et centralisée pour être facile à ajuster.
  static const dueSoonWindow = Duration(days: 30);

  /// Calcule le statut au jour près : l'heure de [now] ou de
  /// [nextDueDate] ne joue pas (une échéance est une date de carnet de
  /// santé, pas un instant précis). Échéance aujourd'hui = [dueSoon] (il
  /// reste la journée pour agir), en retard seulement à partir du
  /// lendemain.
  static DueStatus fromNextDueDate(DateTime? nextDueDate, DateTime now) {
    if (nextDueDate == null) return upToDate;

    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(
      nextDueDate.year,
      nextDueDate.month,
      nextDueDate.day,
    );

    if (dueDay.isBefore(today)) return overdue;
    if (!dueDay.isAfter(today.add(dueSoonWindow))) return dueSoon;
    return upToDate;
  }
}

/// Libellé affiché à l'écran — centralisé ici comme [AnimalSpeciesLabel]
/// pour `animals`, pour éviter que chaque écran ne code sa propre
/// traduction. Méthode plutôt que getter depuis la préparation i18n
/// (audit du 2026-08-19, issue #71 point 3.3, `AppLocalizations` a
/// besoin d'un `BuildContext`) — `import` direct du fichier généré
/// plutôt que passé en paramètre : ce fichier ne dépend déjà de rien
/// côté Flutter, autant garder l'appel simple (`status.label(context)`)
/// pour les call sites plutôt que de leur faire porter l'instance
/// `AppLocalizations` elle-même.
extension DueStatusLabel on DueStatus {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      DueStatus.upToDate => l10n.dueStatusUpToDate,
      DueStatus.dueSoon => l10n.dueStatusDueSoon,
      DueStatus.overdue => l10n.dueStatusOverdue,
    };
  }
}
