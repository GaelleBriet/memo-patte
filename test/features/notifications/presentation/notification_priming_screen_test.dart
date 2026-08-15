import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_patte/core/notifications/notification_service.dart';
import 'package:memo_patte/core/notifications/notification_service_provider.dart';
import 'package:memo_patte/features/notifications/presentation/notification_priming_screen.dart';

class _FakeNotificationService extends NotificationService {
  bool requestResult = true;
  int requestPermissionCallCount = 0;

  @override
  Future<bool> arePermissionsGranted() async => false;

  @override
  Future<bool> requestPermission() async {
    requestPermissionCallCount++;
    return requestResult;
  }
}

/// Pousse [NotificationPrimingScreen] depuis un écran d'appel bidon, pour
/// pouvoir observer la valeur renvoyée par `Navigator.pop` — comme le
/// feront les tickets 3.2/4.2, seuls vrais appelants de cet écran (voir le
/// commentaire de classe de `NotificationPrimingScreen`).
class _CallerScreen extends StatefulWidget {
  const _CallerScreen({super.key});

  @override
  State<_CallerScreen> createState() => _CallerScreenState();
}

class _CallerScreenState extends State<_CallerScreen> {
  bool? poppedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            poppedValue = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => const NotificationPrimingScreen(),
              ),
            );
          },
          child: const Text('Ouvrir la demande de permission'),
        ),
      ),
    );
  }
}

void main() {
  Future<_CallerScreenState> pumpCaller(
    WidgetTester tester,
    NotificationService service,
  ) async {
    final key = GlobalKey<_CallerScreenState>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [notificationServiceProvider.overrideWithValue(service)],
        child: MaterialApp(home: _CallerScreen(key: key)),
      ),
    );
    return key.currentState!;
  }

  testWidgets('explique pourquoi l\'app demande la permission', (tester) async {
    final fake = _FakeNotificationService();
    await pumpCaller(tester, fake);
    await tester.tap(find.text('Ouvrir la demande de permission'));
    await tester.pumpAndSettle();

    expect(find.text('Ne rate plus jamais un rappel'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Activer les rappels'),
      findsOneWidget,
    );
    // Ne doit rien déclencher côté OS tant que l'utilisateur n'a pas
    // interagi.
    expect(fake.requestPermissionCallCount, 0);
  });

  testWidgets('tap sur "Activer les rappels" déclenche la vraie demande OS et '
      'renvoie le résultat à l\'appelant', (tester) async {
    final fake = _FakeNotificationService()..requestResult = true;
    final caller = await pumpCaller(tester, fake);
    await tester.tap(find.text('Ouvrir la demande de permission'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Activer les rappels'));
    await tester.pumpAndSettle();

    expect(fake.requestPermissionCallCount, 1);
    expect(caller.poppedValue, isTrue);
  });

  testWidgets('tap sur "Plus tard" ferme l\'écran sans appeler l\'OS', (
    tester,
  ) async {
    final fake = _FakeNotificationService();
    final caller = await pumpCaller(tester, fake);
    await tester.tap(find.text('Ouvrir la demande de permission'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Plus tard'));
    await tester.pumpAndSettle();

    expect(fake.requestPermissionCallCount, 0);
    expect(caller.poppedValue, isFalse);
  });
}
