import 'package:drift/drift.dart' show Value;
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
import 'package:memo_patte/features/animals/presentation/animal_profile_screen.dart';

/// Fake muet — `AnimalProfileScreen` réconcilie les traitements en retard
/// dans `initState` (ticket 4.4), qui a besoin d'un `NotificationService`
/// utilisable même quand ce test ne crée ni vaccin ni traitement.
class _NoopNotificationService extends NotificationService {
  @override
  Future<void> init() async {}

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

/// Test de non-régression pour l'audit du 2026-08-19 (issue #71, point
/// 1.1) : éditer un animal effaçait silencieusement `photoPath` (et
/// n'importe quel autre champ absent du formulaire d'édition), parce que
/// `_save()` reconstruisait un `Animal(...)` à la main au lieu de partir
/// de `widget.animal.copyWith(...)`.
///
/// `photoPath` n'est saisissable nulle part dans l'UI actuelle (pas de
/// sélecteur de photo, cf. `animal_form_fields.dart`) — posé directement
/// via le repository, comme le serait n'importe quel champ futur que le
/// formulaire d'édition ne couvre pas encore.
void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets(
    'éditer un animal préserve les champs absents du formulaire '
    '(photoPath en particulier)',
    (tester) async {
      final id = await AnimalRepository(
        AnimalDao(database),
      ).createAnimal(name: 'Milo', species: AnimalSpecies.dog);
      // `photoPath` posé directement en base : aucun écran ne sait
      // encore le saisir (cf. commentaire de classe).
      await (database.update(
        database.animals,
      )..where((a) => a.id.equals(id))).write(
        const AnimalsCompanion(photoPath: Value('/fake/path/milo.jpg')),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            notificationServiceProvider.overrideWithValue(
              _NoopNotificationService(),
            ),
          ],
          child: MaterialApp(home: AnimalProfileScreen(animalId: id)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Modifier'));
      await tester.pumpAndSettle();

      // Un seul champ effectivement modifié par le formulaire — le
      // reste (dont `photoPath`, invisible ici) ne doit pas bouger.
      await tester.enterText(find.byType(TextFormField).first, 'Milo Junior');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      final updated = await AnimalDao(database).getById(id);
      expect(updated!.name, 'Milo Junior');
      expect(updated.photoPath, '/fake/path/milo.jpg');

      // Démontage explicite avant la fin du test : voir le commentaire
      // équivalent dans `widget_test.dart` — sans ça, un timer interne
      // de Drift (`StreamQueryStore.markAsClosed`, déclenché par les
      // `.watch()` de cet écran) traîne encore quand `flutter_test`
      // vérifie qu'aucun timer n'est en attente, et le test échoue sur
      // cette vérification plutôt que sur son contenu réel.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
