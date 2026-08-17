import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/notifications/notification_service.dart';
import '../../animals/data/animal_dao.dart';
import '../domain/treatment_frequency.dart';
import 'treatment_dao.dart';

/// Point d'entrée métier pour les traitements (tickets 4.1 et 4.4) —
/// même rôle que `VaccinationRepository`, avec en plus le cycle de
/// rappel récurrent propre aux traitements (voir
/// [reconcileOverdueTreatments]).
class TreatmentRepository {
  TreatmentRepository(this._dao, this._animalDao, this._notificationService);

  final TreatmentDao _dao;
  final AnimalDao _animalDao;
  final NotificationService _notificationService;

  /// Même principe que `VaccinationRepository.notificationIdFor`
  /// (`id * 10 + 1`) mais décalé de `+ 2` : sans ce décalage, le
  /// traitement n°1 et le vaccin n°1 partageraient le même identifiant
  /// de notification et s'annuleraient mutuellement.
  static int notificationIdFor(int treatmentId) => treatmentId * 10 + 2;

  /// Même heure de déclenchement que les vaccins — voir
  /// `VaccinationRepository.notificationHour`.
  static const notificationHour = 9;

  Stream<List<Treatment>> watchForAnimal(int animalId) =>
      _dao.watchForAnimal(animalId);

  Future<Treatment?> getTreatment(int id) => _dao.getById(id);

  /// Voir `VaccinationRepository.hasAnyVaccinations` — détection du
  /// "premier vaccin ou traitement" pour l'écran de priming (ticket 2.2),
  /// maintenant que l'épic 4 est la deuxième source à devoir y participer
  /// (voir `features/notifications/data/first_reminder_source.dart`).
  Future<bool> hasAnyTreatments() => _dao.hasAny();

  /// Crée le traitement — [nextDueDate] est calculée ici (`date` +
  /// [frequency]), jamais saisie par l'utilisateur (contrairement au
  /// vaccin, cf. `treatment_table.dart`) — et programme son rappel si
  /// cette échéance calculée tombe dans le futur (ticket 4.4).
  Future<int> createTreatment({
    required int animalId,
    required String name,
    required DateTime date,
    required TreatmentFrequency frequency,
  }) async {
    final nextDueDate = frequency.nextOccurrenceAfter(date);
    final id = await _dao.insertTreatment(
      TreatmentsCompanion.insert(
        animalId: animalId,
        name: name,
        date: date,
        frequency: frequency,
        nextDueDate: nextDueDate,
      ),
    );

    final notificationId = await _scheduleIfDue(
      treatmentId: id,
      animalId: animalId,
      name: name,
      nextDueDate: nextDueDate,
    );
    if (notificationId != null) {
      final created = await _dao.getById(id);
      await _dao.updateTreatment(
        created!
            .copyWith(notificationId: Value(notificationId))
            .toCompanion(false),
      );
    }
    return id;
  }

  /// Met à jour le traitement et reprogramme son rappel — même principe
  /// annuler-puis-reprogrammer que `VaccinationRepository.updateVaccination`.
  /// [notificationId] porté par [treatment] est ignoré et réécrit ici.
  Future<bool> updateTreatment(Treatment treatment) async {
    final previous = await _dao.getById(treatment.id);
    if (previous?.notificationId != null) {
      await _notificationService.cancelNotification(previous!.notificationId!);
    }

    final notificationId = await _scheduleIfDue(
      treatmentId: treatment.id,
      animalId: treatment.animalId,
      name: treatment.name,
      nextDueDate: treatment.nextDueDate,
    );

    // `toCompanion(false)` et pas `true` : même leçon que pour les
    // vaccins (ticket 1.5 à l'origine) — une édition doit pouvoir
    // repasser `notificationId` à null, pas seulement "ne pas y toucher".
    return _dao.updateTreatment(
      treatment
          .copyWith(notificationId: Value(notificationId))
          .toCompanion(false),
    );
  }

  /// Reprogrammation automatique des traitements dont l'échéance est
  /// passée (ticket 4.4, "reprogrammation automatique à chaque échéance
  /// passée"). Sans service en arrière-plan — une app mobile pure, hors
  /// scope v1 — ce recalage se fait quand l'app est ouverte / l'écran du
  /// traitement consulté, pas par un vrai cron : voir les appelants
  /// (`AnimalProfileScreen`, `TreatmentsListScreen`).
  ///
  /// Avance `nextDueDate` par pas de [TreatmentFrequency] jusqu'à
  /// retomber dans le futur, et reprogramme la notification en
  /// conséquence — la boucle de rappel se perpétue tant que le
  /// traitement existe, contrairement au rappel ponctuel des vaccins.
  Future<void> reconcileOverdueTreatments(int animalId) async {
    final now = DateTime.now();
    final current = await _dao.getForAnimal(animalId);

    for (final treatment in current) {
      if (!treatment.nextDueDate.isBefore(now)) continue;

      var next = treatment.nextDueDate;
      while (!next.isAfter(now)) {
        next = treatment.frequency.nextOccurrenceAfter(next);
      }
      await updateTreatment(treatment.copyWith(nextDueDate: next));
    }
  }

  /// Supprime le traitement (ticket "appui long" du 2026-08-17) — même
  /// principe que `VaccinationRepository.deleteVaccination` : annule
  /// d'abord le rappel programmé s'il y en a un.
  Future<void> deleteTreatment(int id) async {
    final treatment = await _dao.getById(id);
    if (treatment?.notificationId != null) {
      await _notificationService.cancelNotification(treatment!.notificationId!);
    }
    await _dao.deleteTreatment(id);
  }

  Future<int?> _scheduleIfDue({
    required int treatmentId,
    required int animalId,
    required String name,
    required DateTime nextDueDate,
  }) async {
    final fireAt = DateTime(
      nextDueDate.year,
      nextDueDate.month,
      nextDueDate.day,
      notificationHour,
    );
    if (!fireAt.isAfter(DateTime.now())) return null;

    final animal = await _animalDao.getById(animalId);
    final notificationId = notificationIdFor(treatmentId);
    await _notificationService.scheduleNotification(
      id: notificationId,
      title: 'Rappel de traitement',
      body:
          'Le traitement $name de ${animal?.name ?? 'ton animal'} arrive à '
          'échéance aujourd\'hui.',
      scheduledDate: fireAt,
    );
    return notificationId;
  }
}
