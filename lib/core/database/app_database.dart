import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Table technique temporaire, sans valeur métier.
///
/// Drift exige au moins une table déclarée pour accepter de générer du
/// code. Cette table n'est là que pour satisfaire cette contrainte tant
/// qu'aucune table métier n'existe. À supprimer dès que la première vraie
/// table (`Animal`, ticket 1.1) est ajoutée à la base.
/// (Classe volontairement publique : une table privée fait générer par
/// Drift des membres privés non utilisés, ce que l'analyzer signale.)
class SchemaBootstrap extends Table {
  IntColumn get id => integer().autoIncrement()();
}

@DriftDatabase(tables: [SchemaBootstrap])
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
