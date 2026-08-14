import 'package:drift/drift.dart';

import '../domain/animal_species.dart';

/// Table Drift des profils animaux.
///
/// `breed`, `birthDate`, `initialWeightKg` et `photoPath` sont facultatifs :
/// un propriétaire d'animal adopté/trouvé ne connaît pas toujours la race ou
/// la date de naissance exacte, et forcer la saisie irait contre le
/// différenciant "saisie rapide" (`docs/product/04-differenciation.md`).
@DataClassName('Animal')
class Animals extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Limité à chien/chat en v1 par le type [AnimalSpecies] lui-même.
  IntColumn get species => intEnum<AnimalSpecies>()();

  TextColumn get breed => text().nullable()();

  DateTimeColumn get birthDate => dateTime().nullable()();

  RealColumn get initialWeightKg => real().nullable()();

  /// Chemin local vers la photo (pas de stockage cloud en v1, cf.
  /// offline-first dans `docs/technical/01-architecture.md`).
  TextColumn get photoPath => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
