import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memo_patte/main.dart';

void main() {
  testWidgets('App démarre et affiche l\'écran d\'accueil', (
    WidgetTester tester,
  ) async {
    // `ProviderScope` explicite : jusqu'ici ce test s'en passait car
    // l'écran d'accueil (encore un placeholder, voir `app/router.dart`)
    // ne consommait aucun provider Riverpod. Ce n'est plus le cas depuis
    // que `NotificationPermissionBanner` (ticket 2.3) y est affiché — sans
    // ce wrapper, `main()` fonctionne quand même (il englobe `MyApp` dans
    // un `ProviderScope`, voir `lib/main.dart`), seul ce test isolé en a
    // besoin explicitement.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('MémoPatte'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
