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
import 'package:memo_patte/features/treatments/domain/treatment_frequency.dart';
import 'package:memo_patte/features/vaccinations/data/vaccination_dao.dart';
import 'package:memo_patte/features/vaccinations/data/vaccination_repository.dart';

/// Fake muet — capte les annulations pour vérifier le nettoyage en
/// cascade de `AnimalRepository.deleteAnimal` (audit du 2026-08-19,
/// issue #71 point 1.2), sans toucher aux vrais canaux de plateforme.
class _FakeNotificationService extends NotificationService {
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
  }) async {}

  @override
  Future<void> cancelNotification(int id) async {
    cancelled.add(id);
  }
}

/// Tests unitaires du repository `animals` (ticket 1.5) — CRUD complet,
/// sur une base sqlite en mémoire (`AppDatabase.forTesting`), pas la vraie
/// base fichier de l'app : rapide, isolé, sans état entre les tests.
void main() {
  late AppDatabase database;
  late _FakeNotificationService notificationService;
  late AnimalRepository repository;
  late VaccinationRepository vaccinationRepository;
  late TreatmentRepository treatmentRepository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    notificationService = _FakeNotificationService();
    vaccinationRepository = VaccinationRepository(
      VaccinationDao(database),
      AnimalDao(database),
      notificationService,
    );
    treatmentRepository = TreatmentRepository(
      TreatmentDao(database),
      AnimalDao(database),
      notificationService,
    );
    repository = AnimalRepository(
      AnimalDao(database),
      vaccinationRepository,
      treatmentRepository,
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('createAnimal', () {
    test('crée un animal avec seulement les champs obligatoires', () async {
      final id = await repository.createAnimal(
        name: 'Milo',
        species: AnimalSpecies.dog,
      );

      final animal = await repository.getAnimal(id);
      expect(animal, isNotNull);
      expect(animal!.name, 'Milo');
      expect(animal.species, AnimalSpecies.dog);
      expect(animal.breed, isNull);
      expect(animal.birthDate, isNull);
      expect(animal.initialWeightKg, isNull);
    });

    test(
      'crée un animal avec tous les champs facultatifs renseignés',
      () async {
        final birthDate = DateTime(2022, 3, 15);
        final id = await repository.createAnimal(
          name: 'Luna',
          species: AnimalSpecies.cat,
          breed: 'Siamois',
          birthDate: birthDate,
          initialWeightKg: 3.2,
        );

        final animal = await repository.getAnimal(id);
        expect(animal!.breed, 'Siamois');
        expect(animal.birthDate, birthDate);
        expect(animal.initialWeightKg, 3.2);
      },
    );
  });

  group('getAnimal', () {
    test("retourne null si l'id n'existe pas", () async {
      final animal = await repository.getAnimal(999);
      expect(animal, isNull);
    });
  });

  group('updateAnimal', () {
    test("met à jour les champs d'un animal existant", () async {
      final id = await repository.createAnimal(
        name: 'Milo',
        species: AnimalSpecies.dog,
      );
      final original = (await repository.getAnimal(id))!;

      final success = await repository.updateAnimal(
        Animal(
          id: original.id,
          name: 'Milo Junior',
          species: AnimalSpecies.dog,
          breed: 'Labrador',
          birthDate: null,
          initialWeightKg: 12.5,
          createdAt: original.createdAt,
        ),
      );
      expect(success, isTrue);

      final result = await repository.getAnimal(id);
      expect(result!.name, 'Milo Junior');
      expect(result.breed, 'Labrador');
      expect(result.initialWeightKg, 12.5);
    });

    test('peut effacer un champ facultatif en le repassant à null', () async {
      final id = await repository.createAnimal(
        name: 'Luna',
        species: AnimalSpecies.cat,
        breed: 'Siamois',
      );
      final original = (await repository.getAnimal(id))!;

      await repository.updateAnimal(
        Animal(
          id: original.id,
          name: original.name,
          species: original.species,
          breed: null,
          birthDate: null,
          initialWeightKg: null,
          createdAt: original.createdAt,
        ),
      );

      final result = await repository.getAnimal(id);
      expect(result!.breed, isNull);
    });
  });

  group('deleteAnimal', () {
    test('supprime un animal existant', () async {
      final id = await repository.createAnimal(
        name: 'Milo',
        species: AnimalSpecies.dog,
      );

      final deletedCount = await repository.deleteAnimal(id);
      expect(deletedCount, 1);
      expect(await repository.getAnimal(id), isNull);
    });

    test('ne fait rien si l\'id n\'existe pas', () async {
      final deletedCount = await repository.deleteAnimal(999);
      expect(deletedCount, 0);
    });

    test('annule les notifications des vaccins et traitements liés avant '
        'la suppression en cascade (audit du 2026-08-19, issue #71 point '
        '1.2)', () async {
      final id = await repository.createAnimal(
        name: 'Milo',
        species: AnimalSpecies.dog,
      );
      final vaccinationId = await vaccinationRepository.createVaccination(
        animalId: id,
        name: 'Rage',
        date: DateTime.now(),
        nextDueDate: DateTime.now().add(const Duration(days: 5)),
      );
      final treatmentId = await treatmentRepository.createTreatment(
        animalId: id,
        name: 'Bravecto',
        date: DateTime.now(),
        frequency: TreatmentFrequency.monthly,
      );
      final vaccination = (await vaccinationRepository.getVaccination(
        vaccinationId,
      ))!;
      final treatment = (await treatmentRepository.getTreatment(treatmentId))!;
      expect(vaccination.notificationId, isNotNull);
      expect(treatment.notificationId, isNotNull);

      await repository.deleteAnimal(id);

      expect(notificationService.cancelled, [
        vaccination.notificationId,
        treatment.notificationId,
      ]);
      // Cascade SQL toujours effective derrière : plus rien en base
      // pour cet animal.
      expect(await vaccinationRepository.getVaccination(vaccinationId), isNull);
      expect(await treatmentRepository.getTreatment(treatmentId), isNull);
    });
  });

  group('watchAnimals', () {
    test('émet la liste à jour après création puis suppression', () async {
      expect(await repository.watchAnimals().first, isEmpty);

      final id = await repository.createAnimal(
        name: 'Milo',
        species: AnimalSpecies.dog,
      );

      final afterCreate = await repository.watchAnimals().first;
      expect(afterCreate, hasLength(1));
      expect(afterCreate.first.name, 'Milo');

      await repository.deleteAnimal(id);

      final afterDelete = await repository.watchAnimals().first;
      expect(afterDelete, isEmpty);
    });
  });
}
