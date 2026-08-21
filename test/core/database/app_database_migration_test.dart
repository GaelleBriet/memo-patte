import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_patte/core/database/app_database.dart';

/// Test de non-régression pour un bug constaté sur le téléphone de
/// Gaelle le 2026-08-21 : `sqlite exception ... duplicate column name:
/// reminder_times`, qui bloquait l'ouverture de la base (et donc tout
/// l'écran d'accueil).
///
/// Fichier réel plutôt qu'une base en mémoire : le scénario reproduit
/// une fermeture/réouverture de connexion (comme un vrai relancement de
/// l'app), ce qu'une base `NativeDatabase.memory()` ne permet pas de
/// simuler proprement (les données en mémoire ne survivent pas à la
/// fermeture de la connexion).
void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'memo_patte_migration_test',
    );
    dbFile = File('${tempDir.path}/test.sqlite');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('colonnes déjà présentes en base mais version de schéma restée en '
      'retard (migration précédente interrompue) : ne plante pas, se '
      'répare toute seule', () async {
    // Base neuve : Drift crée directement le schéma complet actuel
    // (v4, colonnes `reminder_times`/`reminder_notification_ids`
    // comprises) et enregistre `PRAGMA user_version = 4`.
    final db1 = AppDatabase.forTesting(NativeDatabase(dbFile));
    await db1.customSelect('SELECT 1').get();

    // Simule l'interruption : la structure sur disque est déjà en
    // v4 (colonnes déjà là), mais Drift "oublie" qu'il le sait —
    // exactement ce qui arrive si l'app est tuée juste après
    // l'`ALTER TABLE` mais avant que Drift n'enregistre la nouvelle
    // version.
    await db1.customStatement('PRAGMA user_version = 3');
    await db1.close();

    // Réouverture, comme au prochain lancement de l'app : Drift
    // rejoue `onUpgrade(3, 4)`, qui retente d'ajouter des colonnes
    // déjà présentes. Sans la vérification défensive
    // (`AppDatabase._hasColumn`), ça lève `duplicate column name` et
    // bloque toute la base (donc l'écran d'accueil).
    final db2 = AppDatabase.forTesting(NativeDatabase(dbFile));
    await expectLater(db2.customSelect('SELECT 1').get(), completes);

    final version = await db2.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 4);

    await db2.close();
  });
}
