import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import 'vaccination_table.dart';

part 'vaccination_dao.g.dart';

@DriftAccessor(tables: [Vaccinations])
class VaccinationDao extends DatabaseAccessor<AppDatabase>
    with _$VaccinationDaoMixin {
  VaccinationDao(super.db);

  /// Vaccins d'un animal, du plus récemment administré au plus ancien :
  /// l'écran liste (ticket 3.3) se lit comme un carnet de santé
  /// (l'historique récent d'abord), l'urgence étant portée par le badge
  /// de statut, pas par l'ordre. L'écran d'accueil (ticket 6.1)
  /// agrégera l'échéance la plus proche de son côté.
  Stream<List<Vaccination>> watchForAnimal(int animalId) =>
      (select(vaccinations)
            ..where((v) => v.animalId.equals(animalId))
            ..orderBy([(v) => OrderingTerm.desc(v.date)]))
          .watch();

  /// Lecture ponctuelle (pas un `Stream`) — même principe que
  /// `TreatmentDao.getForAnimal` : utilisée par
  /// `VaccinationRepository.getForAnimal`, elle-même consommée par
  /// `AnimalRepository.deleteAnimal` (annulation des notifications avant
  /// suppression en cascade, audit du 2026-08-19, issue #71 point 1.2) —
  /// une consultation ponctuelle, pas un flux à maintenir.
  Future<List<Vaccination>> getForAnimal(int animalId) =>
      (select(vaccinations)..where((v) => v.animalId.equals(animalId))).get();

  Future<Vaccination?> getById(int id) =>
      (select(vaccinations)..where((v) => v.id.equals(id))).getSingleOrNull();

  /// `true` dès qu'au moins un vaccin existe, tous animaux confondus —
  /// sert à détecter "la création du premier vaccin" pour l'écran de
  /// priming (ticket 3.2, décision du 2026-08-14 dans `decisions-log.md`).
  Future<bool> hasAny() async {
    final row = await (select(vaccinations)..limit(1)).get();
    return row.isNotEmpty;
  }

  Future<int> insertVaccination(VaccinationsCompanion entry) =>
      into(vaccinations).insert(entry);

  Future<bool> updateVaccination(VaccinationsCompanion entry) =>
      update(vaccinations).replace(entry);

  Future<int> deleteVaccination(int id) =>
      (delete(vaccinations)..where((v) => v.id.equals(id))).go();
}
