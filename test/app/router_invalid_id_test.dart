import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_patte/app/router.dart';
import 'package:memo_patte/core/database/app_database.dart';
import 'package:memo_patte/core/database/database_provider.dart';
import 'package:memo_patte/core/notifications/notification_service.dart';
import 'package:memo_patte/core/notifications/notification_service_provider.dart';
import 'package:memo_patte/main.dart';

/// Fake muet — voir les fakes équivalents de `test/features/...`.
class _NoopNotificationService extends NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> arePermissionsGranted() async => true;
}

/// Test de non-régression pour l'audit du 2026-08-19 (issue #71, point
/// 1.3) : un id malformé dans l'URL (deep link cassé, navigation
/// manuelle...) faisait planter l'app (`int.parse` non protégé,
/// `FormatException` propagée jusqu'à l'écran noir) — voir
/// `router.dart`, `_requireValidId`/`_parseIdOrFallback`.
void main() {
  testWidgets(
    'id de route invalide (deep link cassé) : redirige vers l\'accueil '
    'au lieu de planter',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

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

      // Id manifestement pas un entier — équivalent d'une URL modifiée
      // à la main ou d'un deep link corrompu.
      appRouter.go('/animals/not-a-number');
      await tester.pumpAndSettle();

      // Pas d'exception non gérée, et retour propre sur l'accueil —
      // pas juste "n'a pas planté", vraiment atterri quelque part de
      // sensé.
      expect(tester.takeException(), isNull);
      expect(find.text('Bonjour'), findsOneWidget);

      // Même chose pour un id valide au niveau `/animals/:id` mais un
      // sous-id invalide plus loin dans l'URL (`editTreatment`).
      appRouter.go('/animals/1/treatments/not-a-number');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Bonjour'), findsOneWidget);

      // Démontage explicite avant la fin du test — voir le commentaire
      // équivalent dans `widget_test.dart` (timer interne Drift,
      // `StreamQueryStore.markAsClosed`).
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
