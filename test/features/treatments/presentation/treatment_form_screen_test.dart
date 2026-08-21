import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show AndroidScheduleMode, DateTimeComponents;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_patte/core/database/app_database.dart';
import 'package:memo_patte/core/database/database_provider.dart';
import 'package:memo_patte/core/notifications/notification_service.dart';
import 'package:memo_patte/core/notifications/notification_service_provider.dart';
import 'package:memo_patte/features/animals/data/animal_dao.dart';
import 'package:memo_patte/features/animals/data/animal_repository.dart';
import 'package:memo_patte/features/animals/domain/animal_species.dart';
import 'package:memo_patte/features/treatments/data/treatment_dao.dart';
import 'package:memo_patte/features/treatments/data/treatment_repository.dart';
import 'package:memo_patte/features/treatments/presentation/treatment_form_screen.dart';
import 'package:memo_patte/features/vaccinations/data/vaccination_dao.dart';
import 'package:memo_patte/features/vaccinations/data/vaccination_repository.dart';
import 'package:memo_patte/features/vaccinations/data/vaccination_repository_provider.dart';

import '../../../support/localized_test_app.dart';

const _primingTitle = 'Ne rate plus jamais un rappel';

class _FakeNotificationService extends NotificationService {
  _FakeNotificationService({required this.granted});

  bool granted;
  int requestPermissionCallCount = 0;

  @override
  Future<void> init() async {}

  @override
  Future<bool> arePermissionsGranted() async => granted;

  @override
  Future<bool> requestPermission() async {
    requestPermissionCallCount++;
    granted = true;
    return true;
  }

  // Contrairement au formulaire vaccin (`nextDueDate` facultative,
  // jamais renseignée par ces tests), le formulaire traitement calcule
  // toujours une `nextDueDate` (voir `treatment_table.dart`) — ces tests
  // atteignent donc réellement `scheduleNotification`, pas seulement le
  // court-circuit "pas d'échéance" de `_scheduleIfDue`. Sans ces
  // surcharges, l'implémentation réelle plante ici (`tz.local` jamais
  // initialisé, `init()` étant lui-même vidé ci-dessus).
  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    AndroidScheduleMode androidScheduleMode =
        AndroidScheduleMode.inexactAllowWhileIdle,
    DateTimeComponents? matchDateTimeComponents,
  }) async {}

  @override
  Future<void> cancelNotification(int id) async {}
}

/// Tests du flux de création (ticket 4.2), même principe que
/// `vaccination_form_screen_test.dart` — en particulier la détection
/// "premier vaccin ou traitement" partagée (`first_reminder_source.dart`,
/// décision du 2026-08-14 étendue au ticket 4.2). Le détail
/// programmation/annulation des notifications est couvert par
/// `treatment_repository_test.dart`, pas re-testé ici.
void main() {
  late AppDatabase database;
  late _FakeNotificationService notificationService;
  late int animalId;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    notificationService = _FakeNotificationService(granted: false);
    // `AnimalRepository` a besoin d'un `VaccinationRepository`/
    // `TreatmentRepository` depuis le 2026-08-21 (audit issue #71 point
    // 1.2) — jetables ici, juste pour créer l'animal de test ; aucun
    // test de ce fichier n'exerce `deleteAnimal`.
    animalId = await AnimalRepository(
      AnimalDao(database),
      VaccinationRepository(
        VaccinationDao(database),
        AnimalDao(database),
        notificationService,
      ),
      TreatmentRepository(
        TreatmentDao(database),
        AnimalDao(database),
        notificationService,
      ),
    ).createAnimal(name: 'Milo', species: AnimalSpecies.dog);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpForm(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          notificationServiceProvider.overrideWithValue(notificationService),
        ],
        child: localizedTestApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TreatmentFormScreen(animalId: animalId),
                    ),
                  ),
                  child: const Text('Ouvrir le formulaire'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ouvrir le formulaire'));
    await tester.pumpAndSettle();
  }

  Future<void> fillAndSubmit(
    WidgetTester tester, {
    required String name,
  }) async {
    await tester.enterText(find.byType(TextFormField).first, name);
    await tester.tap(find.text('Ajouter le traitement'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'premier traitement sans permission : montre le priming, puis crée '
    'le traitement même après "Plus tard"',
    (tester) async {
      await pumpForm(tester);
      await fillAndSubmit(tester, name: 'Bravecto');

      expect(find.text(_primingTitle), findsOneWidget);
      expect(notificationService.requestPermissionCallCount, 0);

      await tester.tap(find.text('Plus tard'));
      await tester.pumpAndSettle();

      expect(find.text(_primingTitle), findsNothing);
      expect(find.text('Ouvrir le formulaire'), findsOneWidget);
      final saved = await TreatmentDao(database).hasAny();
      expect(saved, isTrue);
    },
  );

  testWidgets('traitements déjà présents : pas de priming, création directe', (
    tester,
  ) async {
    await pumpForm(tester);
    await fillAndSubmit(tester, name: 'Bravecto');
    await tester.tap(find.text('Plus tard'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ouvrir le formulaire'));
    await tester.pumpAndSettle();
    await fillAndSubmit(tester, name: 'Vermifuge');

    expect(find.text(_primingTitle), findsNothing);
    expect(find.text('Ouvrir le formulaire'), findsOneWidget);
    // Select ponctuel et pas `watchForAnimal(...).first` : voir
    // `vaccination_form_screen_test.dart` pour pourquoi (deadlock
    // FakeAsync/timer Drift constaté en écrivant ce genre de test).
    final treatments = await (database.select(
      database.treatments,
    )..where((t) => t.animalId.equals(animalId))).get();
    expect(treatments, hasLength(2));
  });

  testWidgets('permission déjà accordée : pas de priming même pour le premier '
      'traitement', (tester) async {
    notificationService.granted = true;

    await pumpForm(tester);
    await fillAndSubmit(tester, name: 'Bravecto');

    expect(find.text(_primingTitle), findsNothing);
    final saved = await TreatmentDao(database).hasAny();
    expect(saved, isTrue);
  });

  testWidgets(
    'un vaccin existe déjà : pas de priming pour le premier traitement '
    'non plus (détection partagée entre les deux features)',
    (tester) async {
      // Un vaccin déjà enregistré, sans passer par l'UI — juste pour
      // poser l'état "au moins un rappel existe déjà".
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);
      await container
          .read(vaccinationRepositoryProvider)
          .createVaccination(
            animalId: animalId,
            name: 'Rage',
            date: DateTime.now(),
          );

      await pumpForm(tester);
      await fillAndSubmit(tester, name: 'Bravecto');

      expect(find.text(_primingTitle), findsNothing);
      final saved = await TreatmentDao(database).hasAny();
      expect(saved, isTrue);
    },
  );

  group('fréquence quotidienne (ticket "heure(s) de rappel", 2026-08-17)', () {
    testWidgets(
      'fréquence "1×/jour" sélectionnée : affiche la section heure de '
      'rappel',
      (tester) async {
        await pumpForm(tester);

        await tester.tap(find.text('1×/jour'));
        await tester.pumpAndSettle();

        expect(find.text('Heure de rappel *'), findsOneWidget);
        expect(find.text('Choisir une heure'), findsOneWidget);
        // Pas la section "cycle long" en même temps.
        expect(find.textContaining('Prochaine échéance :'), findsNothing);
      },
    );

    testWidgets(
      'fréquence "1×/jour" sans heure choisie : bloque la soumission avec '
      'un message, ne crée rien',
      (tester) async {
        await pumpForm(tester);
        await tester.enterText(
          find.byType(TextFormField).first,
          'Antibiotique',
        );
        await tester.tap(find.text('1×/jour'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter le traitement'));
        await tester.pumpAndSettle();

        expect(
          find.text('Choisis au moins une heure de rappel.'),
          findsOneWidget,
        );
        final saved = await TreatmentDao(database).hasAny();
        expect(saved, isFalse);
      },
    );

    testWidgets('fréquence "Plusieurs/jour" sélectionnée : affiche le bouton '
        '"Ajouter une heure", pas de sélecteur à heure unique', (tester) async {
      await pumpForm(tester);

      await tester.tap(find.text('Plusieurs/jour'));
      await tester.pumpAndSettle();

      expect(find.text('Heures de rappel *'), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, 'Ajouter une heure'),
        findsOneWidget,
      );
      expect(find.text('Choisir une heure'), findsNothing);
    });
  });
}
