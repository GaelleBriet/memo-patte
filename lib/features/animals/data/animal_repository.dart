import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/animal_species.dart';
import 'animal_dao.dart';

/// Point d'entrée métier pour les profils animaux — masque Drift (DAO,
/// `Companion`) au reste de l'app pour garder la présentation découplée du
/// détail de persistance (cf. couches légères de
/// `docs/technical/01-architecture.md`).
class AnimalRepository {
  AnimalRepository(this._dao);

  final AnimalDao _dao;

  Stream<List<Animal>> watchAnimals() => _dao.watchAll();

  Future<Animal?> getAnimal(int id) => _dao.getById(id);

  Future<int> createAnimal({
    required String name,
    required AnimalSpecies species,
    String? breed,
    DateTime? birthDate,
    double? initialWeightKg,
    String? photoPath,
  }) {
    return _dao.insertAnimal(
      AnimalsCompanion.insert(
        name: name,
        species: species,
        breed: Value.absentIfNull(breed),
        birthDate: Value.absentIfNull(birthDate),
        initialWeightKg: Value.absentIfNull(initialWeightKg),
        photoPath: Value.absentIfNull(photoPath),
      ),
    );
  }

  // `nullToAbsent: false` est nécessaire ici (et pas `true`, l'erreur
  // commise au ticket 1.1, trouvée par le test du ticket 1.5) : `true`
  // convertit les champs null en `Value.absent()`, donc "ne pas y
  // toucher" — l'inverse de ce qu'on veut pour une édition qui doit
  // pouvoir effacer un champ facultatif (repasser breed à null, etc.).
  Future<bool> updateAnimal(Animal animal) =>
      _dao.updateAnimal(animal.toCompanion(false));

  Future<int> deleteAnimal(int id) => _dao.deleteAnimal(id);
}
