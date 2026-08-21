import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../treatments/data/treatment_repository.dart';
import '../../vaccinations/data/vaccination_repository.dart';
import '../domain/animal_species.dart';
import 'animal_dao.dart';

/// Point d'entrée métier pour les profils animaux — masque Drift (DAO,
/// `Companion`) au reste de l'app pour garder la présentation découplée du
/// détail de persistance (cf. couches légères de
/// `docs/technical/01-architecture.md`).
///
/// Dépend de [VaccinationRepository]/[TreatmentRepository] (ajouté le
/// 2026-08-21, audit issue #71 point 1.2) uniquement pour
/// [deleteAnimal] — voir son commentaire. Aucune dépendance inverse (ces
/// deux repositories ne dépendent que de `AnimalDao`, pas de
/// [AnimalRepository]), donc pas de cycle côté providers.
class AnimalRepository {
  AnimalRepository(
    this._dao,
    this._vaccinationRepository,
    this._treatmentRepository,
  );

  final AnimalDao _dao;
  final VaccinationRepository _vaccinationRepository;
  final TreatmentRepository _treatmentRepository;

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

  /// Supprime l'animal — et, avec lui, ses vaccins et traitements liés,
  /// en cascade côté SQL (`onDelete: KeyAction.cascade`, voir
  /// `vaccination_table.dart`/`treatment_table.dart`). Cette cascade ne
  /// connaît rien des notifications locales programmées pour ces
  /// lignes : sans le nettoyage explicite ci-dessous, un rappel pouvait
  /// continuer à se déclencher pour un vaccin/traitement dont même
  /// l'animal n'existait plus (audit du 2026-08-19, issue #71 point 1.2).
  ///
  /// Passe par `deleteVaccination`/`deleteTreatment` plutôt qu'un accès
  /// direct aux DAO : réutilise leur logique d'annulation déjà écrite et
  /// testée (`notificationId` *et* `reminderNotificationIds` pour les
  /// traitements à heure(s) fixe(s)), sans une deuxième implémentation
  /// qui pourrait diverger. La cascade SQL reste en place derrière comme
  /// filet de sécurité, pas comme mécanisme principal.
  Future<int> deleteAnimal(int id) async {
    final vaccinations = await _vaccinationRepository.getForAnimal(id);
    for (final vaccination in vaccinations) {
      await _vaccinationRepository.deleteVaccination(vaccination.id);
    }

    final treatments = await _treatmentRepository.getForAnimal(id);
    for (final treatment in treatments) {
      await _treatmentRepository.deleteTreatment(treatment.id);
    }

    return _dao.deleteAnimal(id);
  }
}
