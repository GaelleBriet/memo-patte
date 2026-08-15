import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_patte/core/database/app_database.dart';
import 'package:memo_patte/features/animals/data/animal_dao.dart';
import 'package:memo_patte/features/animals/data/animal_repository.dart';
import 'package:memo_patte/features/animals/domain/animal_species.dart';

/// Tests unitaires du repository `animals` (ticket 1.5) — CRUD complet,
/// sur une base sqlite en mémoire (`AppDatabase.forTesting`), pas la vraie
/// base fichier de l'app : rapide, isolé, sans état entre les tests.
void main() {
  late AppDatabase database;
  late AnimalRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = AnimalRepository(AnimalDao(database));
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
