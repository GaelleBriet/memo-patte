import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_patte/core/database/app_database.dart';
import 'package:memo_patte/core/database/database_provider.dart';
import 'package:memo_patte/core/notifications/notification_service.dart';
import 'package:memo_patte/core/notifications/notification_service_provider.dart';
import 'package:memo_patte/features/animals/data/animal_repository_provider.dart';
import 'package:memo_patte/app/router.dart';
import 'package:memo_patte/features/animals/domain/animal_species.dart';
import 'package:memo_patte/main.dart';

/// Fake muet — voir les fakes équivalents de `test/features/...`.
class _NoopNotificationService extends NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> arePermissionsGranted() async => true;
}

/// Tests de la coquille de navigation (ticket 6.0, `AppShell`) — audit
/// du 2026-08-19, issue #71 point 3.7 ("tests UI/navigation encore
/// légers"). L'onglet Carnet n'a pas de route fixe (voir
/// `AppShell._onCarnetTap`) : il mène soit à la création du premier
/// animal, soit au profil de l'animal courant, selon qu'il en existe
/// déjà un — comportement dynamique jamais couvert jusqu'ici, donc le
/// plus à risque de régression silencieuse.
void main() {
  Future<AppDatabase> pumpApp(
    WidgetTester tester, {
    required AppDatabase database,
  }) async {
    // `appRouter` (`app/router.dart`) est un singleton global, pas
    // recréé entre les tests d'un même fichier — sans ce reset, un
    // test qui a navigué ailleurs que `/` laisse le suivant démarrer
    // de cette position au lieu de l'accueil, contamination constatée
    // en écrivant ce test (le deuxième échouait/bloquait selon l'ordre
    // d'exécution).
    appRouter.go('/');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          notificationServiceProvider.overrideWithValue(
            _NoopNotificationService(),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    return database;
  }

  testWidgets(
    'onglet Carnet sans animal : mène à la création du premier profil',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await pumpApp(tester, database: database);

      expect(find.text('Bonjour'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Carnet'));
      await tester.pumpAndSettle();

      expect(find.text('Créer un profil animal'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('onglet Carnet avec un animal existant : mène à son profil, '
      'aller-retour avec Accueil fonctionne', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    await container
        .read(animalRepositoryProvider)
        .createAnimal(name: 'Milo', species: AnimalSpecies.dog);

    await pumpApp(tester, database: database);

    await tester.tap(find.bySemanticsLabel('Carnet'));
    await tester.pumpAndSettle();

    // Le hero du Carnet de santé affiche le nom de l'animal (et le
    // sélecteur de chips juste en dessous aussi — d'où `findsWidgets`,
    // pas `findsOneWidget`).
    expect(find.text('Milo'), findsWidgets);
    expect(find.text('Créer un profil animal'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Accueil'));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
  });
}
