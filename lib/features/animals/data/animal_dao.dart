import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import 'animal_table.dart';

part 'animal_dao.g.dart';

@DriftAccessor(tables: [Animals])
class AnimalDao extends DatabaseAccessor<AppDatabase> with _$AnimalDaoMixin {
  AnimalDao(super.db);

  Stream<List<Animal>> watchAll() => select(animals).watch();

  Future<Animal?> getById(int id) =>
      (select(animals)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<int> insertAnimal(AnimalsCompanion entry) =>
      into(animals).insert(entry);

  Future<bool> updateAnimal(AnimalsCompanion entry) =>
      update(animals).replace(entry);

  Future<int> deleteAnimal(int id) =>
      (delete(animals)..where((a) => a.id.equals(id))).go();
}
