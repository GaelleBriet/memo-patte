import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/animals/data/animal_table.dart';
// Import direct requis : le code généré par Drift dans
// app_database.g.dart référence AnimalSpecies (via intEnum<T>()) et a
// besoin de ce type dans la portée de CETTE librairie, pas seulement
// dans celle d'animal_table.dart (les imports ne sont pas transitifs).
import '../../features/animals/domain/animal_species.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Animals])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Connexion sqlite native (Android/iOS/desktop), fichier stocké dans le
  // dossier "application support" du système. `drift_flutter` est
  // l'approche actuellement recommandée par la doc officielle Drift pour
  // Flutter : elle gère la création de la connexion (isolate en arrière-plan
  // inclus) sans configuration manuelle par plateforme.
  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'memo_patte',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
