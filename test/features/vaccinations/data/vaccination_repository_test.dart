import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show AndroidScheduleMode, DateTimeComponents;
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_patte/core/database/app_database.dart';
import 'package:memo_patte/core/notifications/notification_service.dart';
import 'package:memo_patte/features/animals/data/animal_dao.dart';
import 'package:memo_patte/features/animals/data/animal_repository.dart';
import 'package:memo_patte/features/animals/domain/animal_species.dart';
import 'package:memo_patte/features/treatments/data/treatment_dao.dart';
import 'package:memo_patte/features/treatments/data/treatment_repository.dart';
import 'package:memo_patte/features/vaccinations/data/vaccination_dao.dart';
import 'package:memo_patte/features/vaccinations/data/vaccination_repository.dart';

/// Une programmation de notification captée par [_FakeNotificationService].
typedef _ScheduledCall = ({
  int id,
  String title,
  String body,
  DateTime scheduledDate,
});

/// Fake de [NotificationService] : capte les appels au lieu de toucher
/// aux canaux de plateforme — même principe que le fake des tests de
/// `features/notifications`, enrichi pour vérifier le branchement du
/// ticket 3.4 (quoi est programmé/annulé, quand).
class _FakeNotificationService extends NotificationService {
  final List<_ScheduledCall> scheduled = [];
  final List<int> cancelled = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    AndroidScheduleMode androidScheduleMode =
        AndroidScheduleMode.inexactAllowWhileIdle,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    scheduled.add((
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    ));
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelled.add(id);
  }
}

/// `AnimalRepository` a besoin d'un `VaccinationRepository`/
/// `TreatmentRepository` depuis le 2026-08-21 (audit issue #71 point
/// 1.2, nettoyage des notifications avant suppression en cascade) —
/// réutilise le `VaccinationRepository` déjà en jeu dans ce fichier
/// plutôt que d'en construire un deuxième qui pourrait diverger ; le
/// `TreatmentRepository` est un jetable, aucun test ici n'exerce les
/// traitements.
AnimalRepository _animalRepository(
  AppDatabase database,
  VaccinationRepository vaccinationRepository,
  NotificationService notificationService,
) => AnimalRepository(
  AnimalDao(database),
  vaccinationRepository,
  TreatmentRepository(
    TreatmentDao(database),
    AnimalDao(database),
    notificationService,
  ),
);

/// Tests unitaires du repository `vaccinations` (ticket 3.5) : CRUD sur
/// base sqlite en mémoire (comme `animal_repository_test.dart`) et
/// branchement notifications (ticket 3.4) via le fake ci-dessus.
///
/// Les échéances relatives ("demain", "hier") plutôt qu'absolues : le
/// comportement dépend de `DateTime.now()` (on ne programme jamais dans
/// le passé), et J±1 reste déterministe quelle que soit l'heure
/// d'exécution du test — contrairement à "aujourd'hui", volontairement
/// non testé ici.
void main() {
  late AppDatabase database;
  late _FakeNotificationService notificationService;
  late VaccinationRepository repository;
  late int animalId;

  final today = DateTime.now();
  final tomorrow = DateTime(today.year, today.month, today.day + 1);
  final yesterday = DateTime(today.year, today.month, today.day - 1);

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    notificationService = _FakeNotificationService();
    repository = VaccinationRepository(
      VaccinationDao(database),
      AnimalDao(database),
      notificationService,
    );
    animalId = await _animalRepository(database, repository, notificationService)
        .createAnimal(name: 'Milo', species: AnimalSpecies.dog);
  });

  tearDown(() async {
    await database.close();
  });

  group('createVaccination', () {
    test('sans échéance : enregistre, ne programme rien', () async {
      final id = await repository.createVaccination(
        animalId: animalId,
        name: 'Rage',
        date: DateTime(2026, 6, 1),
      );

      final vaccination = await repository.getVaccination(id);
      expect(vaccination, isNotNull);
      expect(vaccination!.name, 'Rage');
      expect(vaccination.animalId, animalId);
      expect(vaccination.date, DateTime(2026, 6, 1));
      expect(vaccination.nextDueDate, isNull);
      expect(vaccination.notificationId, isNull);
      expect(notificationService.scheduled, isEmpty);
    });

    test('échéance future : programme le rappel à 9h le jour J et stocke '
        'son identifiant', () async {
      final id = await repository.createVaccination(
        animalId: animalId,
        name: 'Rage',
        date: DateTime(2026, 6, 1),
        nextDueDate: tomorrow,
      );

      expect(notificationService.scheduled, hasLength(1));
      final call = notificationService.scheduled.single;
      expect(call.id, VaccinationRepository.notificationIdFor(id));
      expect(
        call.scheduledDate,
        DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          VaccinationRepository.notificationHour,
        ),
      );
      expect(call.body, contains('Rage'));
      expect(call.body, contains('Milo'));

      final vaccination = await repository.getVaccination(id);
      expect(
        vaccination!.notificationId,
        VaccinationRepository.notificationIdFor(id),
      );
    });

    test('échéance passée (saisie rétroactive d\'un vaccin en retard) : '
        'ne programme rien', () async {
      final id = await repository.createVaccination(
        animalId: animalId,
        name: 'Rage',
        date: DateTime(2024, 6, 1),
        nextDueDate: yesterday,
      );

      expect(notificationService.scheduled, isEmpty);
      final vaccination = await repository.getVaccination(id);
      expect(vaccination!.nextDueDate, yesterday);
      expect(vaccination.notificationId, isNull);
    });
  });

  group('updateVaccination', () {
    test('changement d\'échéance : annule puis reprogramme', () async {
      final id = await repository.createVaccination(
        animalId: animalId,
        name: 'Rage',
        date: DateTime(2026, 6, 1),
        nextDueDate: tomorrow,
      );
      final original = (await repository.getVaccination(id))!;
      final newDueDate = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day + 7,
      );

      await repository.updateVaccination(
        original.copyWith(nextDueDate: Value(newDueDate)),
      );

      expect(notificationService.cancelled, [
        VaccinationRepository.notificationIdFor(id),
      ]);
      expect(notificationService.scheduled, hasLength(2));
      expect(
        notificationService.scheduled.last.scheduledDate,
        DateTime(
          newDueDate.year,
          newDueDate.month,
          newDueDate.day,
          VaccinationRepository.notificationHour,
        ),
      );
      final updated = await repository.getVaccination(id);
      expect(
        updated!.notificationId,
        VaccinationRepository.notificationIdFor(id),
      );
    });

    test('échéance retirée : annule sans reprogrammer', () async {
      final id = await repository.createVaccination(
        animalId: animalId,
        name: 'Rage',
        date: DateTime(2026, 6, 1),
        nextDueDate: tomorrow,
      );
      final original = (await repository.getVaccination(id))!;

      await repository.updateVaccination(
        original.copyWith(nextDueDate: const Value(null)),
      );

      expect(notificationService.cancelled, [
        VaccinationRepository.notificationIdFor(id),
      ]);
      expect(notificationService.scheduled, hasLength(1)); // La création.
      final updated = await repository.getVaccination(id);
      expect(updated!.nextDueDate, isNull);
      expect(updated.notificationId, isNull);
    });

    test('échéance ajoutée là où il n\'y en avait pas : programme sans '
        'avoir rien à annuler', () async {
      final id = await repository.createVaccination(
        animalId: animalId,
        name: 'Rage',
        date: DateTime(2026, 6, 1),
      );
      final original = (await repository.getVaccination(id))!;

      await repository.updateVaccination(
        original.copyWith(nextDueDate: Value(tomorrow)),
      );

      expect(notificationService.cancelled, isEmpty);
      expect(notificationService.scheduled, hasLength(1));
      final updated = await repository.getVaccination(id);
      expect(
        updated!.notificationId,
        VaccinationRepository.notificationIdFor(id),
      );
    });

    test('édition simple (nom) : les autres champs restent intacts', () async {
      final id = await repository.createVaccination(
        animalId: animalId,
        name: 'Rge',
        date: DateTime(2026, 6, 1),
        nextDueDate: tomorrow,
      );
      final original = (await repository.getVaccination(id))!;

      await repository.updateVaccination(original.copyWith(name: 'Rage'));

      final updated = await repository.getVaccination(id);
      expect(updated!.name, 'Rage');
      expect(updated.date, DateTime(2026, 6, 1));
      expect(updated.nextDueDate, tomorrow);
    });
  });

  group('watchForAnimal', () {
    test('ne retourne que les vaccins de l\'animal, du plus récent au plus '
        'ancien', () async {
      final otherAnimalId = await _animalRepository(database, repository, notificationService)
          .createAnimal(name: 'Luna', species: AnimalSpecies.cat);
      await repository.createVaccination(
        animalId: animalId,
        name: 'Rage',
        date: DateTime(2025, 6, 1),
      );
      await repository.createVaccination(
        animalId: animalId,
        name: 'CHPPiL',
        date: DateTime(2026, 6, 1),
      );
      await repository.createVaccination(
        animalId: otherAnimalId,
        name: 'Typhus',
        date: DateTime(2026, 1, 1),
      );

      final vaccinations = await repository.watchForAnimal(animalId).first;

      expect(vaccinations.map((v) => v.name), ['CHPPiL', 'Rage']);
    });
  });

  group('hasAnyVaccinations', () {
    test('false tant qu\'aucun vaccin n\'existe, true ensuite', () async {
      expect(await repository.hasAnyVaccinations(), isFalse);

      await repository.createVaccination(
        animalId: animalId,
        name: 'Rage',
        date: DateTime(2026, 6, 1),
      );

      expect(await repository.hasAnyVaccinations(), isTrue);
    });
  });

  group('suppression d\'un animal', () {
    test('supprime ses vaccins en cascade (clés étrangères actives)', () async {
      await repository.createVaccination(
        animalId: animalId,
        name: 'Rage',
        date: DateTime(2026, 6, 1),
      );

      await _animalRepository(database, repository, notificationService).deleteAnimal(animalId);

      final vaccinations = await repository.watchForAnimal(animalId).first;
      expect(vaccinations, isEmpty);
    });
  });

  group('deleteVaccination', () {
    test('rappel programmé : annule la notification avant de supprimer '
        'la ligne', () async {
      final id = await repository.createVaccination(
        animalId: animalId,
        name: 'Rage',
        date: DateTime(2026, 6, 1),
        nextDueDate: tomorrow,
      );

      await repository.deleteVaccination(id);

      expect(notificationService.cancelled, [
        VaccinationRepository.notificationIdFor(id),
      ]);
      expect(await repository.getVaccination(id), isNull);
    });

    test('sans rappel programmé : supprime sans tenter d\'annuler', () async {
      final id = await repository.createVaccination(
        animalId: animalId,
        name: 'Rage',
        date: DateTime(2026, 6, 1),
      );

      await repository.deleteVaccination(id);

      expect(notificationService.cancelled, isEmpty);
      expect(await repository.getVaccination(id), isNull);
    });
  });
}
