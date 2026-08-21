import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_patte/core/notifications/notification_service.dart';
import 'package:memo_patte/core/notifications/notification_service_provider.dart';
import 'package:memo_patte/features/notifications/presentation/notification_permission_banner.dart';

import '../../../support/localized_test_app.dart';

const _bannerText = 'Rappels désactivés — active-les dans les réglages';

class _FakeNotificationService extends NotificationService {
  _FakeNotificationService(this.granted);

  bool granted;
  int openNotificationSettingsCallCount = 0;

  @override
  Future<bool> arePermissionsGranted() async => granted;

  @override
  Future<bool> openNotificationSettings() async {
    openNotificationSettingsCallCount++;
    return true;
  }
}

Widget _wrap(NotificationService service) {
  return ProviderScope(
    overrides: [notificationServiceProvider.overrideWithValue(service)],
    child: localizedTestApp(
      home: const Scaffold(body: NotificationPermissionBanner()),
    ),
  );
}

void main() {
  testWidgets('ne montre rien si la permission est accordée', (tester) async {
    await tester.pumpWidget(_wrap(_FakeNotificationService(true)));
    await tester.pumpAndSettle();

    expect(find.text(_bannerText), findsNothing);
  });

  testWidgets('montre le bandeau si la permission est refusée', (tester) async {
    await tester.pumpWidget(_wrap(_FakeNotificationService(false)));
    await tester.pumpAndSettle();

    expect(find.text(_bannerText), findsOneWidget);
  });

  testWidgets('tap sur le bandeau ouvre les réglages système', (tester) async {
    final fake = _FakeNotificationService(false);
    await tester.pumpWidget(_wrap(fake));
    await tester.pumpAndSettle();

    await tester.tap(find.text(_bannerText));
    await tester.pumpAndSettle();

    expect(fake.openNotificationSettingsCallCount, 1);
  });

  testWidgets('relit le statut au retour au premier plan de l\'app', (
    tester,
  ) async {
    final fake = _FakeNotificationService(false);
    await tester.pumpWidget(_wrap(fake));
    await tester.pumpAndSettle();

    expect(find.text(_bannerText), findsOneWidget);

    // Simule une réactivation manuelle dans les réglages système pendant
    // que l'app était en arrière-plan (ex. via le lien du bandeau
    // lui-même).
    fake.granted = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text(_bannerText), findsNothing);
  });
}
