import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/notifications/notification_service.dart';
import '../../animals/data/animal_dao.dart';
import 'vaccination_dao.dart';

/// Point d'entrée métier pour les vaccinations (tickets 3.1 et 3.4) —
/// masque Drift au reste de l'app, comme `AnimalRepository`, et porte le
/// branchement notifications décrit dans `01-architecture.md` : le
/// service `core/notifications` est appelé ici, à la création/
/// modification d'un enregistrement, jamais depuis les écrans.
class VaccinationRepository {
  VaccinationRepository(this._dao, this._animalDao, this._notificationService);

  final VaccinationDao _dao;
  final AnimalDao _animalDao;
  final NotificationService _notificationService;

  /// Identifiant de notification dérivé de l'id de ligne, comme suggéré
  /// par la doc de [NotificationService.scheduleNotification], mais avec
  /// un décalage par feature : `id * 10 + 1` pour les vaccins, le slot
  /// `+ 2` étant réservé aux traitements (ticket 4.4) — sans ça, le
  /// vaccin n°1 et le traitement n°1 partageraient le même identifiant et
  /// s'annuleraient mutuellement.
  static int notificationIdFor(int vaccinationId) => vaccinationId * 10 + 1;

  /// Heure locale de déclenchement du rappel, le jour de l'échéance.
  /// L'échéance est une date de carnet (granularité du jour) ; 9 h du
  /// matin laisse la journée pour appeler le vétérinaire. Pas de réglage
  /// utilisateur en v1.
  static const notificationHour = 9;

  Stream<List<Vaccination>> watchForAnimal(int animalId) =>
      _dao.watchForAnimal(animalId);

  Future<Vaccination?> getVaccination(int id) => _dao.getById(id);

  /// Voir [VaccinationDao.hasAny] — détection du "premier vaccin" pour
  /// l'écran de priming (ticket 3.2).
  Future<bool> hasAnyVaccinations() => _dao.hasAny();

  /// Crée le vaccin et programme son rappel si [nextDueDate] s'y prête
  /// (ticket 3.4). Deux écritures : l'id de ligne — dont dérive l'id de
  /// notification — n'existe qu'après l'insertion.
  Future<int> createVaccination({
    required int animalId,
    required String name,
    required DateTime date,
    DateTime? nextDueDate,
  }) async {
    final id = await _dao.insertVaccination(
      VaccinationsCompanion.insert(
        animalId: animalId,
        name: name,
        date: date,
        nextDueDate: Value.absentIfNull(nextDueDate),
      ),
    );

    final notificationId = await _scheduleIfDue(
      vaccinationId: id,
      animalId: animalId,
      name: name,
      nextDueDate: nextDueDate,
    );
    if (notificationId != null) {
      final created = await _dao.getById(id);
      await _dao.updateVaccination(
        created!
            .copyWith(notificationId: Value(notificationId))
            .toCompanion(false),
      );
    }
    return id;
  }

  /// Met à jour le vaccin et reprogramme son rappel (ticket 3.4) :
  /// annulation systématique de l'ancienne notification puis
  /// reprogrammation si la (nouvelle) échéance s'y prête. Toujours
  /// annuler+reprogrammer, même si la date n'a pas bougé : idempotent,
  /// et plus simple qu'une comparaison champ à champ.
  ///
  /// [notificationId] est géré ici : la valeur portée par [vaccination]
  /// est ignorée et réécrite.
  Future<bool> updateVaccination(Vaccination vaccination) async {
    final previous = await _dao.getById(vaccination.id);
    if (previous?.notificationId != null) {
      await _notificationService.cancelNotification(previous!.notificationId!);
    }

    final notificationId = await _scheduleIfDue(
      vaccinationId: vaccination.id,
      animalId: vaccination.animalId,
      name: vaccination.name,
      nextDueDate: vaccination.nextDueDate,
    );

    // `toCompanion(false)` et pas `true` : même leçon que
    // `AnimalRepository.updateAnimal` (ticket 1.5) — une édition doit
    // pouvoir repasser un champ facultatif (ici `nextDueDate` ou
    // `notificationId`) à null, pas seulement "ne pas y toucher".
    return _dao.updateVaccination(
      vaccination
          .copyWith(notificationId: Value(notificationId))
          .toCompanion(false),
    );
  }

  /// Supprime le vaccin (ticket "appui long" du 2026-08-17) — annule
  /// d'abord son rappel programmé s'il y en a un, même logique que
  /// l'annulation en tête de [updateVaccination] : on ne veut pas d'une
  /// notification qui survit à la ligne qu'elle décrivait.
  Future<void> deleteVaccination(int id) async {
    final vaccination = await _dao.getById(id);
    if (vaccination?.notificationId != null) {
      await _notificationService.cancelNotification(
        vaccination!.notificationId!,
      );
    }
    await _dao.deleteVaccination(id);
  }

  /// Programme la notification de rappel et retourne son identifiant, ou
  /// `null` sans rien programmer si l'échéance est absente ou si son
  /// instant de déclenchement est déjà passé (saisie rétroactive d'un
  /// vaccin en retard : le statut visuel du ticket 3.3 et le bandeau
  /// d'accueil suffisent, programmer une notification dans le passé est
  /// de toute façon refusé par le plugin).
  Future<int?> _scheduleIfDue({
    required int vaccinationId,
    required int animalId,
    required String name,
    required DateTime? nextDueDate,
  }) async {
    if (nextDueDate == null) return null;

    final fireAt = DateTime(
      nextDueDate.year,
      nextDueDate.month,
      nextDueDate.day,
      notificationHour,
    );
    if (!fireAt.isAfter(DateTime.now())) return null;

    final animal = await _animalDao.getById(animalId);
    final notificationId = notificationIdFor(vaccinationId);
    await _notificationService.scheduleNotification(
      id: notificationId,
      title: 'Rappel vaccin',
      body:
          'Le vaccin $name de ${animal?.name ?? 'ton animal'} arrive à '
          'échéance aujourd\'hui.',
      scheduledDate: fireAt,
    );
    return notificationId;
  }
}
