import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_patte/core/database/app_database.dart';
import 'package:memo_patte/core/database/database_provider.dart';
import 'package:memo_patte/features/animals/data/animal_dao.dart';
import 'package:memo_patte/features/animals/presentation/create_animal_screen.dart';
import 'package:memo_patte/l10n/generated/app_localizations.dart';

import '../../../support/localized_test_app.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets(
    'premier animal créé (rien à dépiler dans la pile de navigation) : '
    'navigue vers son profil au lieu de planter',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/animals/new',
        routes: [
          GoRoute(
            path: '/animals/new',
            name: 'createAnimal',
            builder: (context, state) => const CreateAnimalScreen(),
          ),
          GoRoute(
            path: '/animals/:id',
            name: 'animalProfile',
            builder: (context, state) =>
                Scaffold(body: Text('Profil ${state.pathParameters['id']}')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(database)],
          child: MaterialApp.router(
            routerConfig: router,
            locale: testLocale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: testLocalizationsDelegates,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'Milo');
      await tester.tap(find.text('Chien'));
      await tester.pump();

      await tester.tap(find.text('Créer le profil'));
      await tester.pumpAndSettle();

      // Pas d'écran noir/vide : on a atterri sur le profil du nouvel
      // animal (id 1, premier de la base en mémoire).
      expect(find.text('Profil 1'), findsOneWidget);
      final saved = await AnimalDao(database).getById(1);
      expect(saved?.name, 'Milo');
    },
  );
}
