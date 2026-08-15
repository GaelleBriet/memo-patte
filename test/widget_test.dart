import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_patte/core/database/app_database.dart';
import 'package:memo_patte/core/database/database_provider.dart';
import 'package:memo_patte/core/notifications/notification_service.dart';
import 'package:memo_patte/core/notifications/notification_service_provider.dart';
import 'package:memo_patte/main.dart';

/// Fake muet — voir les fakes équivalents de `test/features/...` pour le
/// principe : éviter de toucher aux vrais canaux de plateforme
/// (notifications) en test.
class _FakeNotificationService extends NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> arePermissionsGranted() async => true;
}

void main() {
  testWidgets('App démarre et affiche l\'écran d\'accueil', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    // `appDatabaseProvider`/`notificationServiceProvider` explicitement
    // remplacés : depuis le ticket 6.2, l'accueil réel (`HomeScreen`)
    // lit la base de données dès le premier `build` (liste des animaux,
    // rappels) — sans ce remplacement, ce test pompe la vraie connexion
    // fichier (`path_provider`, non mocké en test) et `pumpAndSettle`
    // ne se termine jamais. Jusqu'ici ce test s'en passait : l'accueil
    // était encore un placeholder qui ne consommait aucun provider
    // Riverpod (voir l'historique de `app/router.dart`).
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          notificationServiceProvider.overrideWithValue(
            _FakeNotificationService(),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Depuis le ticket 6.2, l'accueil n'a plus d'AppBar "MémoPatte" —
    // remplacée par le hero "Bonjour" de la maquette. Le nom de l'app
    // n'apparaît plus nulle part à l'écran, seulement dans le titre de
    // la fenêtre (`MaterialApp.title`) — pas vérifiable via `find`.
    expect(find.text('Bonjour'), findsOneWidget);
    // 2 `Scaffold` empilés, comportement attendu : celui de `AppShell`
    // (ticket 6.0, porte la bottom nav) et celui de `HomeScreen` à
    // l'intérieur (porte le contenu de l'onglet actif).
    expect(find.byType(Scaffold), findsNWidgets(2));

    // Démontage explicite avant la fin du test : Drift programme un
    // timer de durée nulle en interne à la fermeture d'une subscription
    // à une requête `.watch()` (`StreamQueryStore.markAsClosed`,
    // déclenché ici par `animalsListProvider`/`vaccinationsListProvider`
    // à la destruction du `ProviderScope`). Si ce démontage n'a lieu
    // qu'après la fin de la fonction de test (démontage automatique de
    // `testWidgets`), ce timer traîne encore au moment où `flutter_test`
    // vérifie qu'aucun timer n'est en attente, et le test échoue sur
    // cette vérification-là plutôt que sur le contenu réel du test.
    // Pomper un widget vide ici force ce démontage — et le timer qui va
    // avec — pendant qu'on peut encore pomper derrière pour le laisser
    // se déclencher. Deux pumps à durée non nulle : un seul (ou un pump
    // à durée nulle) ne suffit pas à vider la chaîne de timers de
    // `markAsClosed`, testé empiriquement.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
  });
}
