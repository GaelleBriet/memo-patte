/// Statut visuel d'un vaccin par rapport à sa prochaine échéance
/// (ticket 3.3 : "à jour / à venir / en retard").
///
/// C'est la seule logique de calcul autour de l'échéance côté
/// `vaccinations` : contrairement aux traitements (épic 4, notion de
/// fréquence récurrente), la prochaine échéance d'un vaccin n'est pas
/// calculée par l'app — elle est saisie telle que donnée par le
/// vétérinaire (carnet/rappel papier), voir `01-architecture.md` ("un
/// vaccin a une date + rappel simple").
enum VaccinationStatus {
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
  static VaccinationStatus fromNextDueDate(
    DateTime? nextDueDate,
    DateTime now,
  ) {
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

/// Libellé français affiché à l'écran — centralisé ici comme
/// [AnimalSpeciesLabel] pour `animals`, pour éviter que chaque écran ne
/// code sa propre traduction.
extension VaccinationStatusLabel on VaccinationStatus {
  String get label => switch (this) {
    VaccinationStatus.upToDate => 'À jour',
    VaccinationStatus.dueSoon => 'À venir',
    VaccinationStatus.overdue => 'En retard',
  };
}
