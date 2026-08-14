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

  Future<bool> updateAnimal(Animal animal) =>
      _dao.updateAnimal(animal.toCompanion(true));

  Future<int> deleteAnimal(int id) => _dao.deleteAnimal(id);
}
