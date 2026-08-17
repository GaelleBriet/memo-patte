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
import 'package:memo_patte/features/treatments/domain/reminder_times.dart';
import 'package:memo_patte/features/treatments/domain/treatment_frequency.dart';
import 'package:memo_patte/features/vaccinations/data/vaccination_repository.dart';

/// Une programmation de notification captée par [_FakeNotificationService].
typedef _ScheduledCall = ({
  int id,
  String title,
  String body,
  DateTime scheduledDate,
  DateTimeComponents? matchDateTimeComponents,
});

/// Fake de [NotificationService] — même principe que
/// `vaccination_repository_test.dart` : capte les appels au lieu de
/// toucher aux canaux de plateforme.
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
      matchDateTimeComponents: matchDateTimeComponents,
    ));
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelled.add(id);
  }
}

/// Tests unitaires du repository `treatments` (ticket 4.5) : CRUD +
/// branchement notification récurrente (ticket 4.4) sur base sqlite en
/// mémoire, comme `vaccination_repository_test.dart`.
///
/// Échéances relatives ("demain", "hier") plutôt qu'absolues — même
/// raison que côté vaccins : le comportement dépend de `DateTime.now()`.
void main() {
  late AppDatabase database;
  late _FakeNotificationService notificationService;
  late TreatmentRepository repository;
  late int animalId;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    notificationService = _FakeNotificationService();
    repository = TreatmentRepository(
      TreatmentDao(database),
      AnimalDao(database),
      notificationService,
    );
    animalId = await AnimalRepository(AnimalDao(database))
        .createAnimal(name: 'Milo', species: AnimalSpecies.dog);
  });

  tearDown(() async {
    await database.close();
  });

  group('createTreatment', () {
    test('calcule la prochaine échéance à partir de date + fréquence et '
        'programme le rappel', () async {
      final id = await repository.createTreatment(
        animalId: animalId,
        name: 'Bravecto',
        date: DateTime.now(),
        frequency: TreatmentFrequency.quarterly,
      );

      final treatment = await repository.getTreatment(id);
      expect(treatment, isNotNull);
      expect(treatment!.name, 'Bravecto');
      expect(treatment.frequency, TreatmentFrequency.quarterly);
      expect(
        treatment.nextDueDate,
        TreatmentFrequency.quarterly.nextOccurrenceAfter(treatment.date),
      );

      expect(notificationService.scheduled, hasLength(1));
      final call = notificationService.scheduled.single;
      expect(call.id, TreatmentRepository.notificationIdFor(id));
      expect(call.body, contains('Bravecto'));
      expect(call.body, contains('Milo'));
      expect(
        treatment.notificationId,
        TreatmentRepository.notificationIdFor(id),
      );
    });

    test('saisie rétroactive profonde (échéance calculée déjà passée) : '
        'enregistre sans programmer de rappel', () async {
      final id = await repository.createTreatment(
        animalId: animalId,
        name: 'Vermifuge',
        date: DateTime.now().subtract(const Duration(days: 400)),
        frequency: TreatmentFrequency.monthly,
      );

      expect(notificationService.scheduled, isEmpty);
      final treatment = await repository.getTreatment(id);
      expect(treatment!.notificationId, isNull);
      expect(treatment.nextDueDate.isBefore(DateTime.now()), isTrue);
    });

    test('l\'identifiant de notification ne collisionne pas avec un vaccin '
        'de même id de ligne, ni entre cycle long et heure(s) fixe(s)', () {
      for (var id = 1; id <= 20; id++) {
        final vaccinationId = VaccinationRepository.notificationIdFor(id);
        final cycleId = TreatmentRepository.notificationIdFor(id);
        expect(cycleId, isNot(vaccinationId));

        for (var slot = 0; slot < 10; slot++) {
          final slotId = TreatmentRepository.notificationIdForSlot(id, slot);
          expect(slotId, isNot(vaccinationId));
          expect(slotId, isNot(cycleId));
        }
      }
    });
  });

  group('createTreatment — fréquence quotidienne (une heure)', () {
    test('calcule la prochaine échéance à partir de l\'heure choisie et '
        'programme un rappel récurrent natif', () async {
      final now = DateTime.now();
      final upcoming = now.add(const Duration(hours: 2));
      final id = await repository.createTreatment(
        animalId: animalId,
        name: 'Antibiotique',
        date: now,
        frequency: TreatmentFrequency.daily,
        reminderTimes: [upcoming.hour * 60 + upcoming.minute],
      );

      final treatment = await repository.getTreatment(id);
      expect(treatment, isNotNull);
      expect(treatment!.frequency, TreatmentFrequency.daily);
      expect(treatment.nextDueDate.hour, upcoming.hour);
      expect(treatment.nextDueDate.minute, upcoming.minute);
      // Pas de rappel "cycle long" pour cette famille de fréquence — voir
      // `treatment_table.dart`.
      expect(treatment.notificationId, isNull);

      expect(notificationService.scheduled, hasLength(1));
      final call = notificationService.scheduled.single;
      expect(call.id, TreatmentRepository.notificationIdForSlot(id, 0));
      expect(call.matchDateTimeComponents, DateTimeComponents.time);
      expect(treatment.reminderNotificationIds, '${call.id}');
    });
  });

  group('createTreatment — fréquence quotidienne (plusieurs heures)', () {
    test('programme un rappel récurrent natif par heure choisie', () async {
      final id = await repository.createTreatment(
        animalId: animalId,
        name: 'Antibiotique',
        date: DateTime.now(),
        frequency: TreatmentFrequency.severalTimesDaily,
        reminderTimes: const [8 * 60, 20 * 60],
      );

      expect(notificationService.scheduled, hasLength(2));
      expect(
        notificationService.scheduled.map((c) => c.matchDateTimeComponents),
        everyElement(DateTimeComponents.time),
      );
      expect(notificationService.scheduled.map((c) => c.id), [
        TreatmentRepository.notificationIdForSlot(id, 0),
        TreatmentRepository.notificationIdForSlot(id, 1),
      ]);

      final treatment = await repository.getTreatment(id);
      expect(
        treatment!.reminderNotificationIds,
        '${TreatmentRepository.notificationIdForSlot(id, 0)},'
        '${TreatmentRepository.notificationIdForSlot(id, 1)}',
      );
    });
  });

  group('updateTreatment', () {
    test('changement de fréquence : recalcule l\'échéance, annule et '
        'reprogramme', () async {
      final now = DateTime.now();
      final id = await repository.createTreatment(
        animalId: animalId,
        name: 'Bravecto',
        date: now,
        frequency: TreatmentFrequency.monthly,
      );
      final original = (await repository.getTreatment(id))!;
      final firstNotificationId = original.notificationId;

      final updated = original.copyWith(
        frequency: TreatmentFrequency.quarterly,
        nextDueDate: TreatmentFrequency.quarterly.nextOccurrenceAfter(now),
      );
      await repository.updateTreatment(updated);

      expect(notificationService.cancelled, [firstNotificationId]);
      expect(notificationService.scheduled, hasLength(2));
      final result = await repository.getTreatment(id);
      expect(
        result!.nextDueDate,
        TreatmentFrequency.quarterly.nextOccurrenceAfter(now),
      );
    });

    test('fréquence à heure(s) fixe(s) : annule les anciens rappels '
        'récurrents et en programme de nouveaux pour les nouvelles heures',
        () async {
      final id = await repository.createTreatment(
        animalId: animalId,
        name: 'Antibiotique',
        date: DateTime.now(),
        frequency: TreatmentFrequency.daily,
        reminderTimes: const [8 * 60],
      );
      final original = (await repository.getTreatment(id))!;
      final firstSlotId = TreatmentRepository.notificationIdForSlot(id, 0);
      expect(original.reminderNotificationIds, '$firstSlotId');

      await repository.updateTreatment(
        original.copyWith(
          frequency: TreatmentFrequency.severalTimesDaily,
          reminderTimes: Value(encodeReminderTimes(const [8 * 60, 20 * 60])),
          nextDueDate: nextReminderDateTime(
            const [8 * 60, 20 * 60],
            DateTime.now(),
          ),
        ),
      );

      expect(notificationService.cancelled, [firstSlotId]);
      final result = await repository.getTreatment(id);
      expect(
        result!.reminderNotificationIds,
        '${TreatmentRepository.notificationIdForSlot(id, 0)},'
        '${TreatmentRepository.notificationIdForSlot(id, 1)}',
      );
    });
  });

  group('reconcileOverdueTreatments', () {
    test('échéance future : ne touche à rien', () async {
      final id = await repository.createTreatment(
        animalId: animalId,
        name: 'Bravecto',
        date: DateTime.now(),
        frequency: TreatmentFrequency.monthly,
      );
      final before = await repository.getTreatment(id);
      notificationService.scheduled.clear();

      await repository.reconcileOverdueTreatments(animalId);

      final after = await repository.getTreatment(id);
      expect(after!.nextDueDate, before!.nextDueDate);
      expect(notificationService.scheduled, isEmpty);
      expect(notificationService.cancelled, isEmpty);
    });

    test('échéance dépassée d\'un cycle : avance d\'une fréquence et '
        'reprogramme', () async {
      // Dernière administration il y a 2 mois, fréquence mensuelle :
      // la prochaine échéance calculée (il y a 1 mois) est déjà
      // dépassée d'un cycle complet.
      final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));
      final id = await repository.createTreatment(
        animalId: animalId,
        name: 'Vermifuge',
        date: twoMonthsAgo,
        frequency: TreatmentFrequency.monthly,
      );
      final before = await repository.getTreatment(id);
      expect(before!.nextDueDate.isBefore(DateTime.now()), isTrue);

      await repository.reconcileOverdueTreatments(animalId);

      final after = await repository.getTreatment(id);
      expect(after!.nextDueDate.isAfter(DateTime.now()), isTrue);
      // Une seule reprogrammation : l'échéance avancée d'un cycle
      // suffit à retomber dans le futur, pas la peine d'avancer plus.
      expect(
        after.nextDueDate,
        TreatmentFrequency.monthly.nextOccurrenceAfter(before.nextDueDate),
      );
      // Rien programmé à la création (échéance calculée déjà passée,
      // comme le test "saisie rétroactive profonde" ci-dessus) — la
      // seule notification programmée vient de la reconciliation.
      expect(notificationService.scheduled, hasLength(1));
    });

    test('échéance dépassée de plusieurs cycles : avance jusqu\'à retomber '
        'dans le futur, pas juste d\'un cran', () async {
      // Fréquence mensuelle, dernière administration il y a 6 mois :
      // 5 échéances mensuelles ont dû être manquées d'affilée.
      final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
      final id = await repository.createTreatment(
        animalId: animalId,
        name: 'Vermifuge',
        date: sixMonthsAgo,
        frequency: TreatmentFrequency.monthly,
      );

      await repository.reconcileOverdueTreatments(animalId);

      final after = await repository.getTreatment(id);
      expect(after!.nextDueDate.isAfter(DateTime.now()), isTrue);
      // La précédente occurrence (un mois avant la nouvelle
      // échéance) doit, elle, être dans le passé — sans ça on aurait
      // avancé d'un cycle de trop.
      final previousOccurrence = DateTime(
        after.nextDueDate.year,
        after.nextDueDate.month - 1,
        after.nextDueDate.day,
      );
      expect(previousOccurrence.isAfter(DateTime.now()), isFalse);
    });

    test('plusieurs animaux : ne touche que celui demandé', () async {
      final luna = await AnimalRepository(AnimalDao(database))
          .createAnimal(name: 'Luna', species: AnimalSpecies.cat);
      final overdueDate = DateTime.now().subtract(const Duration(days: 60));

      await repository.createTreatment(
        animalId: animalId,
        name: 'Vermifuge Milo',
        date: overdueDate,
        frequency: TreatmentFrequency.monthly,
      );
      final lunaTreatmentId = await repository.createTreatment(
        animalId: luna,
        name: 'Vermifuge Luna',
        date: overdueDate,
        frequency: TreatmentFrequency.monthly,
      );

      await repository.reconcileOverdueTreatments(animalId);

      final lunaTreatment = await repository.getTreatment(lunaTreatmentId);
      // Toujours en retard : la reconciliation n'a porté que sur Milo.
      expect(lunaTreatment!.nextDueDate.isBefore(DateTime.now()), isTrue);
    });
  });

  group('watchForAnimal', () {
    test('ne retourne que les traitements de l\'animal, du plus récent au '
        'plus ancien', () async {
      final luna = await AnimalRepository(AnimalDao(database))
          .createAnimal(name: 'Luna', species: AnimalSpecies.cat);
      await repository.createTreatment(
        animalId: animalId,
        name: 'Vermifuge',
        date: DateTime(2025, 6, 1),
        frequency: TreatmentFrequency.monthly,
      );
      await repository.createTreatment(
        animalId: animalId,
        name: 'Bravecto',
        date: DateTime(2026, 6, 1),
        frequency: TreatmentFrequency.quarterly,
      );
      await repository.createTreatment(
        animalId: luna,
        name: 'Autre',
        date: DateTime(2026, 1, 1),
        frequency: TreatmentFrequency.monthly,
      );

      final treatments = await repository.watchForAnimal(animalId).first;

      expect(treatments.map((t) => t.name), ['Bravecto', 'Vermifuge']);
    });
  });

  group('hasAnyTreatments', () {
    test('false tant qu\'aucun traitement n\'existe, true ensuite', () async {
      expect(await repository.hasAnyTreatments(), isFalse);

      await repository.createTreatment(
        animalId: animalId,
        name: 'Bravecto',
        date: DateTime.now(),
        frequency: TreatmentFrequency.quarterly,
      );

      expect(await repository.hasAnyTreatments(), isTrue);
    });
  });

  group('suppression d\'un animal', () {
    test(
      'supprime ses traitements en cascade (clés étrangères actives)',
      () async {
        await repository.createTreatment(
          animalId: animalId,
          name: 'Bravecto',
          date: DateTime.now(),
          frequency: TreatmentFrequency.quarterly,
        );

        await AnimalRepository(AnimalDao(database)).deleteAnimal(animalId);

        final treatments = await repository.watchForAnimal(animalId).first;
        expect(treatments, isEmpty);
      },
    );
  });

  group('deleteTreatment', () {
    test('rappel programmé : annule la notification avant de supprimer '
        'la ligne', () async {
      final id = await repository.createTreatment(
        animalId: animalId,
        name: 'Bravecto',
        date: DateTime.now(),
        frequency: TreatmentFrequency.quarterly,
      );

      await repository.deleteTreatment(id);

      expect(notificationService.cancelled, [
        TreatmentRepository.notificationIdFor(id),
      ]);
      expect(await repository.getTreatment(id), isNull);
    });

    test('sans rappel programmé (échéance déjà passée à la création) : '
        'supprime sans tenter d\'annuler', () async {
      final id = await repository.createTreatment(
        animalId: animalId,
        name: 'Vermifuge',
        date: DateTime.now().subtract(const Duration(days: 400)),
        frequency: TreatmentFrequency.monthly,
      );

      await repository.deleteTreatment(id);

      expect(notificationService.cancelled, isEmpty);
      expect(await repository.getTreatment(id), isNull);
    });
  });
}
