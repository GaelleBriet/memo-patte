import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show AndroidScheduleMode, DateTimeComponents;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_patte/core/database/app_database.dart';
import 'package:memo_patte/core/database/database_provider.dart';
import 'package:memo_patte/core/notifications/notification_service.dart';
import 'package:memo_patte/core/notifications/notification_service_provider.dart';
import 'package:memo_patte/features/animals/data/animal_dao.dart';
import 'package:memo_patte/features/animals/data/animal_repository.dart';
import 'package:memo_patte/features/animals/domain/animal_species.dart';
import 'package:memo_patte/features/home/data/home_reminders_provider.dart';
import 'package:memo_patte/features/home/domain/home_reminder.dart';
import 'package:memo_patte/features/treatments/data/treatment_repository_provider.dart';
import 'package:memo_patte/features/treatments/domain/treatment_frequency.dart';
import 'package:memo_patte/features/vaccinations/data/vaccination_repository_provider.dart';

/// Fake muet : `homeRemindersProvider` ne lit que les données Drift, ce
/// service n'est ici que pour satisfaire `vaccinationRepositoryProvider`/
/// `treatmentRepositoryProvider` (qui en ont besoin pour programmer les
/// rappels — tickets 3.4/4.4) sans toucher aux canaux de plateforme en
/// test.
class _NoopNotificationService extends NotificationService {
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
  }) async {}

  @override
  Future<void> cancelNotification(int id) async {}
}

/// Tests du provider de rappels de l'accueil (ticket 6.1) : sur une base
/// sqlite en mémoire, comme les tests de repository.
///
/// Scopé à un animal à la fois (`.family` sur l'id) depuis le
/// 2026-08-15 — plus une agrégation multi-animaux, voir le commentaire
/// de classe de `home_reminders_provider.dart`. Depuis le ticket 4.1,
/// vaccins et traitements sont tous les deux des sources possibles
/// (`ReminderKind`).
void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        notificationServiceProvider.overrideWithValue(
          _NoopNotificationService(),
        ),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);
  });

  Future<int> createAnimal(String name) =>
      AnimalRepository(AnimalDao(database))
          .createAnimal(name: name, species: AnimalSpecies.dog);

  /// Attend qu'un provider `Stream`/`AsyncValue` sorte de l'état
  /// `AsyncLoading`, par polling plutôt que `container.read(provider.future)`.
  ///
  /// Constaté en écrivant ce test : sur `animalsListProvider`
  /// (`StreamNotifierProvider` écrit à la main, cf. son commentaire de
  /// classe sur le bug Drift/codegen de `riverpod_generator`), `.future`
  /// ne se résout jamais — le test reste bloqué indéfiniment (repro
  /// isolée : `container.listen` + `container.read` en boucle s'en sort,
  /// `.future` seul non). Probablement apparenté au même bug runtime
  /// plutôt qu'une erreur d'usage ; à revisiter si une version plus
  /// récente de `riverpod`/`riverpod_generator` le corrige.
  ///
  /// `listen`/`read` en closures plutôt que le provider en paramètre
  /// typé : `ProviderListenable`, le type qu'attendent
  /// `container.listen`/`container.read`, n'est pas exporté publiquement
  /// par `riverpod` (seuls des sous-types comme `ProviderListenableSelect`
  /// le sont) — passer par des closures laisse l'inférence de type faire
  /// le travail à chaque site d'appel, sans avoir à nommer ce type.
  Future<T> settle<T>({
    required AsyncValue<T> Function() read,
    required void Function() listen,
  }) async {
    listen();
    var value = read();
    for (var i = 0; i < 500 && !value.hasValue && !value.hasError; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      value = read();
    }
    if (value.hasError) {
      Error.throwWithStackTrace(value.error!, value.stackTrace!);
    }
    if (!value.hasValue) {
      throw StateError('provider jamais résolu (encore loading) : $value');
    }
    return value.value as T;
  }

  Future<List<HomeReminder>> readReminders(int animalId) => settle(
    read: () => container.read(homeRemindersProvider(animalId)),
    listen: () =>
        container.listen(homeRemindersProvider(animalId), (previous, next) {}),
  );

  test('animal sans vaccin ni traitement : liste vide', () async {
    final animalId = await createAnimal('Milo');
    expect(await readReminders(animalId), isEmpty);
  });

  test('vaccin à jour (échéance lointaine) : absent de la liste', () async {
    final animalId = await createAnimal('Milo');
    await container
        .read(vaccinationRepositoryProvider)
        .createVaccination(
          animalId: animalId,
          name: 'Rage',
          date: DateTime.now(),
          nextDueDate: DateTime.now().add(const Duration(days: 200)),
        );

    expect(await readReminders(animalId), isEmpty);
  });

  test('vaccin sans échéance : absent de la liste', () async {
    final animalId = await createAnimal('Milo');
    await container
        .read(vaccinationRepositoryProvider)
        .createVaccination(
          animalId: animalId,
          name: 'Rage',
          date: DateTime.now(),
        );

    expect(await readReminders(animalId), isEmpty);
  });

  test('vaccin à venir/en retard : présent avec les bons champs', () async {
    final animalId = await createAnimal('Milo');
    // Tronqué à la seconde : la colonne Drift `dateTime()` stocke en
    // secondes epoch, une comparaison à la microseconde près échouerait
    // au retour de la base même si rien n'est cassé.
    final now = DateTime.now();
    final dueDate = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
    ).add(const Duration(days: 5));
    final vaccinationId = await container
        .read(vaccinationRepositoryProvider)
        .createVaccination(
          animalId: animalId,
          name: 'Rage',
          date: DateTime.now(),
          nextDueDate: dueDate,
        );

    final reminders = await readReminders(animalId);
    expect(reminders, hasLength(1));
    final reminder = reminders.single;
    expect(reminder.animalId, animalId);
    expect(reminder.animalName, 'Milo');
    expect(reminder.kind, ReminderKind.vaccination);
    expect(reminder.sourceId, vaccinationId);
    expect(reminder.title, 'Rappel de vaccin');
    expect(reminder.detail, 'Rage');
    expect(reminder.dueDate, dueDate);
    // Les vaccins n'ont pas d'heure de rappel configurable — voir
    // `HomeReminder.reminderTimeLabel`.
    expect(reminder.reminderTimeLabel, isNull);
  });

  test('traitement à jour (échéance lointaine) : absent de la liste', () async {
    final animalId = await createAnimal('Milo');
    await container
        .read(treatmentRepositoryProvider)
        .createTreatment(
          animalId: animalId,
          name: 'Bravecto',
          date: DateTime.now(),
          frequency: TreatmentFrequency.annual,
        );

    expect(await readReminders(animalId), isEmpty);
  });

  test('traitement à venir/en retard : présent avec les bons champs', () async {
    final animalId = await createAnimal('Milo');
    final treatmentId = await container
        .read(treatmentRepositoryProvider)
        .createTreatment(
          animalId: animalId,
          name: 'Bravecto',
          // Fréquence mensuelle avec une administration il y a 25
          // jours : prochaine échéance dans 5 jours, "à venir".
          date: DateTime.now().subtract(const Duration(days: 25)),
          frequency: TreatmentFrequency.monthly,
        );

    final reminders = await readReminders(animalId);
    expect(reminders, hasLength(1));
    final reminder = reminders.single;
    expect(reminder.animalId, animalId);
    expect(reminder.animalName, 'Milo');
    expect(reminder.kind, ReminderKind.treatment);
    expect(reminder.sourceId, treatmentId);
    expect(reminder.title, 'Rappel de traitement');
    expect(reminder.detail, 'Bravecto');
    // Cycle long : pas d'heure de rappel à afficher (9h par défaut,
    // jamais choisie par l'utilisateur — voir `HomeReminder.reminderTimeLabel`).
    expect(reminder.reminderTimeLabel, isNull);
  });

  test('traitement à fréquence quotidienne : l\'heure de rappel est '
      'exposée pour l\'accueil', () async {
    final animalId = await createAnimal('Milo');
    final treatmentId = await container
        .read(treatmentRepositoryProvider)
        .createTreatment(
          animalId: animalId,
          name: 'Antibiotique',
          date: DateTime.now(),
          frequency: TreatmentFrequency.daily,
          reminderTimes: [
            DateTime.now().add(const Duration(hours: 1)).hour * 60,
          ],
        );

    final reminders = await readReminders(animalId);
    expect(reminders, hasLength(1));
    final reminder = reminders.single;
    expect(reminder.sourceId, treatmentId);
    expect(reminder.reminderTimeLabel, isNotNull);
    expect(reminder.reminderTimeLabel, matches(RegExp(r'^\d{2}:\d{2}$')));
  });

  test('vaccins et traitements fusionnés, triés par échéance la plus '
      'proche', () async {
    final animalId = await createAnimal('Milo');

    await container
        .read(vaccinationRepositoryProvider)
        .createVaccination(
          animalId: animalId,
          name: 'Rage',
          date: DateTime.now(),
          nextDueDate: DateTime.now().add(const Duration(days: 10)),
        );
    await container
        .read(treatmentRepositoryProvider)
        .createTreatment(
          animalId: animalId,
          name: 'Vermifuge',
          // En retard : doit passer devant malgré l'ordre de création.
          date: DateTime.now().subtract(const Duration(days: 40)),
          frequency: TreatmentFrequency.monthly,
        );

    final reminders = await readReminders(animalId);
    expect(reminders.map((r) => r.detail), ['Vermifuge', 'Rage']);
    expect(reminders.map((r) => r.kind), [
      ReminderKind.treatment,
      ReminderKind.vaccination,
    ]);
  });

  test('scopé à l\'animal demandé : n\'inclut pas les vaccins/traitements '
      'des autres', () async {
    final milo = await createAnimal('Milo');
    final luna = await createAnimal('Luna');
    final vaccinationRepository = container.read(vaccinationRepositoryProvider);
    final treatmentRepository = container.read(treatmentRepositoryProvider);

    await vaccinationRepository.createVaccination(
      animalId: milo,
      name: 'Rage',
      date: DateTime.now(),
      nextDueDate: DateTime.now().add(const Duration(days: 5)),
    );
    await treatmentRepository.createTreatment(
      animalId: luna,
      name: 'Bravecto',
      date: DateTime.now().subtract(const Duration(days: 25)),
      frequency: TreatmentFrequency.monthly,
    );

    final miloReminders = await readReminders(milo);
    expect(miloReminders.map((r) => r.detail), ['Rage']);

    final lunaReminders = await readReminders(luna);
    expect(lunaReminders.map((r) => r.detail), ['Bravecto']);
  });
}
