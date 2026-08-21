import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/animals/data/animal_table.dart';
// Import direct requis : le code généré par Drift dans
// app_database.g.dart référence AnimalSpecies (via intEnum<T>()) et a
// besoin de ce type dans la portée de CETTE librairie, pas seulement
// dans celle d'animal_table.dart (les imports ne sont pas transitifs).
import '../../features/animals/domain/animal_species.dart';
import '../../features/treatments/data/treatment_table.dart';
// Même remarque que pour AnimalSpecies ci-dessus, cette fois pour
// TreatmentFrequency (intEnum<T>() dans treatment_table.dart).
import '../../features/treatments/domain/treatment_frequency.dart';
import '../../features/vaccinations/data/vaccination_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Animals, Vaccinations, Treatments])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Pour les tests unitaires (ticket 1.5) : permet d'injecter une base en
  /// mémoire (`NativeDatabase.memory()`) plutôt que la vraie connexion
  /// fichier de [AppDatabase.new], pour des tests rapides et isolés.
  AppDatabase.forTesting(super.executor);

  /// v4 : ajout de `Treatments.reminderTimes`/`reminderNotificationIds`
  /// (fréquences quotidiennes à heure(s) fixe(s), 2026-08-17).
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Migrations écrites à la main tant qu'elles restent triviales
    // (création de table / ajout de colonne). Si une migration doit un
    // jour faire quelque chose de plus lourd, passer sur l'outillage
    // `drift_dev schema` (exports de schéma versionnés + tests de
    // migration), plus lourd mais sûr.
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // `createTable` génère `CREATE TABLE IF NOT EXISTS` (voir Drift,
        // `Migrator._writeCreateTable`) : déjà sûr à rejouer.
        await m.createTable(vaccinations);
      }
      if (from < 3) {
        await m.createTable(treatments);
      }
      if (from < 4) {
        // `addColumn`, lui, génère un simple `ALTER TABLE ADD COLUMN`
        // sans garde — le rejouer sur une colonne déjà présente plante
        // avec `duplicate column name`. Ça peut arriver si une
        // migration précédente a été interrompue *après* l'`ALTER
        // TABLE` mais *avant* que Drift n'enregistre la nouvelle
        // version du schéma (ex. app tuée en arrière-plan pendant la
        // migration) : au lancement suivant, Drift croit devoir migrer
        // à nouveau depuis la version d'avant, plante, et l'app entière
        // reste bloquée dessus (bug constaté sur le téléphone de
        // Gaelle le 2026-08-21, écran d'accueil en erreur). D'où la
        // vérification défensive via `_hasColumn` plutôt qu'un appel
        // direct — l'ajout devient idempotent, la base se répare toute
        // seule au prochain lancement sans perte de données.
        if (!await _hasColumn('treatments', 'reminder_times')) {
          await m.addColumn(treatments, treatments.reminderTimes);
        }
        if (!await _hasColumn('treatments', 'reminder_notification_ids')) {
          await m.addColumn(treatments, treatments.reminderNotificationIds);
        }
      }
    },
    // Sqlite n'applique PAS les clés étrangères par défaut : sans ce
    // pragma, le `references(..., onDelete: cascade)` de
    // `vaccination_table.dart` serait silencieusement ignoré.
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// `true` si [table] a déjà une colonne nommée [column] — via
  /// `PRAGMA table_info`, la façon standard sqlite d'inspecter le
  /// schéma réel d'une table (pas ce que le code Dart *déclare*, ce qui
  /// est *effectivement en base*). Les noms sont ceux générés par Drift
  /// (snake_case), pas les noms Dart des colonnes.
  Future<bool> _hasColumn(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    return rows.any((row) => row.data['name'] == column);
  }

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
