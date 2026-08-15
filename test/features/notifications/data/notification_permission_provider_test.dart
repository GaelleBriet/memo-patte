import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_patte/core/notifications/notification_service.dart';
import 'package:memo_patte/core/notifications/notification_service_provider.dart';
import 'package:memo_patte/features/notifications/data/notification_permission_provider.dart';

/// Fake de [NotificationService] : évite de passer par les vrais canaux de
/// plateforme (non disponibles en test unitaire) tout en gardant un
/// comportement piloté par le test — même principe que la base sqlite en
/// mémoire de `animal_repository_test.dart` pour le repository `animals`.
class _FakeNotificationService extends NotificationService {
  bool granted = false;
  bool requestResult = true;
  int requestPermissionCallCount = 0;

  @override
  Future<bool> arePermissionsGranted() async => granted;

  @override
  Future<bool> requestPermission() async {
    requestPermissionCallCount++;
    granted = requestResult;
    return requestResult;
  }
}

void main() {
  late _FakeNotificationService fakeService;
  late ProviderContainer container;

  setUp(() {
    fakeService = _FakeNotificationService();
    container = ProviderContainer(
      overrides: [notificationServiceProvider.overrideWithValue(fakeService)],
    );
    addTearDown(container.dispose);
  });

  group('build', () {
    test(
      'reflète le statut initial retourné par le service (accordée)',
      () async {
        fakeService.granted = true;

        final status = await container.read(
          notificationPermissionStatusProvider.future,
        );

        expect(status, isTrue);
      },
    );

    test(
      'reflète le statut initial retourné par le service (refusée)',
      () async {
        fakeService.granted = false;

        final status = await container.read(
          notificationPermissionStatusProvider.future,
        );

        expect(status, isFalse);
      },
    );
  });

  group('requestPermission', () {
    test(
      'appelle la vraie demande OS et met l\'état à jour avec le résultat',
      () async {
        fakeService
          ..granted = false
          ..requestResult = true;
        await container.read(notificationPermissionStatusProvider.future);

        final granted = await container
            .read(notificationPermissionStatusProvider.notifier)
            .requestPermission();

        expect(granted, isTrue);
        expect(fakeService.requestPermissionCallCount, 1);
        expect(
          container.read(notificationPermissionStatusProvider).value,
          isTrue,
        );
      },
    );

    test('propage un refus sans erreur', () async {
      fakeService
        ..granted = false
        ..requestResult = false;
      await container.read(notificationPermissionStatusProvider.future);

      final granted = await container
          .read(notificationPermissionStatusProvider.notifier)
          .requestPermission();

      expect(granted, isFalse);
      expect(
        container.read(notificationPermissionStatusProvider).value,
        isFalse,
      );
    });
  });

  group('refresh', () {
    test(
      'relit le statut sans passer par une demande de permission',
      () async {
        fakeService.granted = false;
        await container.read(notificationPermissionStatusProvider.future);

        // Simule une réactivation manuelle dans les réglages système,
        // hors du contrôle de l'app.
        fakeService.granted = true;
        await container
            .read(notificationPermissionStatusProvider.notifier)
            .refresh();

        expect(
          container.read(notificationPermissionStatusProvider).value,
          isTrue,
        );
        expect(fakeService.requestPermissionCallCount, 0);
      },
    );
  });
}
