import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import 'treatment_table.dart';

part 'treatment_dao.g.dart';

@DriftAccessor(tables: [Treatments])
class TreatmentDao extends DatabaseAccessor<AppDatabase>
    with _$TreatmentDaoMixin {
  TreatmentDao(super.db);

  /// Traitements d'un animal, du plus récemment administré au plus
  /// ancien — même logique de lecture que `VaccinationDao.watchForAnimal`.
  Stream<List<Treatment>> watchForAnimal(int animalId) =>
      (select(treatments)
            ..where((t) => t.animalId.equals(animalId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  /// Lecture ponctuelle (pas un `Stream`) : utilisée par
  /// `TreatmentRepository.reconcileOverdueTreatments` (ticket 4.4), un
  /// contrôle fait au moment où l'écran est consulté, pas une
  /// souscription à maintenir.
  Future<List<Treatment>> getForAnimal(int animalId) =>
      (select(treatments)..where((t) => t.animalId.equals(animalId))).get();

  Future<Treatment?> getById(int id) =>
      (select(treatments)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// `true` dès qu'au moins un traitement existe, tous animaux confondus
  /// — même rôle que `VaccinationDao.hasAny` pour la détection du
  /// "premier vaccin ou traitement" de l'écran de priming (ticket 2.2).
  Future<bool> hasAny() async {
    final row = await (select(treatments)..limit(1)).get();
    return row.isNotEmpty;
  }

  Future<int> insertTreatment(TreatmentsCompanion entry) =>
      into(treatments).insert(entry);

  Future<bool> updateTreatment(TreatmentsCompanion entry) =>
      update(treatments).replace(entry);

  Future<int> deleteTreatment(int id) =>
      (delete(treatments)..where((t) => t.id.equals(id))).go();
}
