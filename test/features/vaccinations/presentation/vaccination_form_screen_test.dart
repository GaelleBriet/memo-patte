import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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
import 'package:memo_patte/features/vaccinations/data/vaccination_dao.dart';
import 'package:memo_patte/features/vaccinations/data/vaccination_repository.dart';
import 'package:memo_patte/features/vaccinations/presentation/vaccination_form_screen.dart';

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
}

/// Tests du flux de création (ticket 3.2), en particulier le
/// déclenchement de l'écran de priming (ticket 2.2) avant le *premier*
/// vaccin uniquement — décision du 2026-08-14 dans `decisions-log.md`.
/// Le détail programmation/annulation des notifications est couvert par
/// `vaccination_repository_test.dart`, pas re-testé ici.
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
                      builder: (_) => VaccinationFormScreen(animalId: animalId),
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
    await tester.tap(find.text('Ajouter le vaccin'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'premier vaccin sans permission : montre le priming, puis crée le '
    'vaccin même après "Plus tard"',
    (tester) async {
      await pumpForm(tester);
      await fillAndSubmit(tester, name: 'Rage');

      // Le priming s'affiche avant la création, sans avoir déclenché la
      // demande OS.
      expect(find.text(_primingTitle), findsOneWidget);
      expect(notificationService.requestPermissionCallCount, 0);

      await tester.tap(find.text('Plus tard'));
      await tester.pumpAndSettle();

      // Refus ou pas, la création s'est poursuivie et le formulaire
      // s'est fermé (l'app ne bloque jamais sur cette permission).
      expect(find.text(_primingTitle), findsNothing);
      expect(find.text('Ouvrir le formulaire'), findsOneWidget);
      final saved = await VaccinationDao(database).hasAny();
      expect(saved, isTrue);
    },
  );

  testWidgets('vaccins déjà présents : pas de priming, création directe', (
    tester,
  ) async {
    await pumpForm(tester);
    await fillAndSubmit(tester, name: 'Rage');
    await tester.tap(find.text('Plus tard'));
    await tester.pumpAndSettle();

    // Deuxième vaccin : le priming ne doit pas revenir (pas de
    // harcèlement — le bandeau de l'accueil suffit).
    await tester.tap(find.text('Ouvrir le formulaire'));
    await tester.pumpAndSettle();
    await fillAndSubmit(tester, name: 'CHPPiL');

    expect(find.text(_primingTitle), findsNothing);
    expect(find.text('Ouvrir le formulaire'), findsOneWidget);
    // Select ponctuel et pas `watchForAnimal(...).first` : l'émission
    // d'un stream de requête Drift passe par un timer, que la zone
    // FakeAsync de `testWidgets` ne déclenche jamais pendant un `await`
    // direct — le test resterait suspendu (vécu : suite entière bloquée).
    // Les futurs simples, eux, se résolvent en microtâches.
    final vaccinations = await (database.select(
      database.vaccinations,
    )..where((v) => v.animalId.equals(animalId))).get();
    expect(vaccinations, hasLength(2));
  });

  testWidgets('permission déjà accordée : pas de priming même pour le premier '
      'vaccin', (tester) async {
    notificationService.granted = true;

    await pumpForm(tester);
    await fillAndSubmit(tester, name: 'Rage');

    expect(find.text(_primingTitle), findsNothing);
    expect(find.text('Ouvrir le formulaire'), findsOneWidget);
    final saved = await VaccinationDao(database).hasAny();
    expect(saved, isTrue);
  });
}
