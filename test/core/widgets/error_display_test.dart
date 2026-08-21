import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_patte/core/widgets/error_display.dart';

import '../../support/localized_test_app.dart';

/// Tests du composant d'erreur partagé (audit du 2026-08-19, issue #71
/// point 3.2).
void main() {
  testWidgets('affiche le message d\'erreur', (tester) async {
    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: ErrorDisplay(
            error: Exception('panne réseau'),
            loggerName: 'test',
          ),
        ),
      ),
    );

    expect(find.text('Une erreur est survenue'), findsOneWidget);
    expect(find.textContaining('panne réseau'), findsOneWidget);
    expect(find.text('Réessayer'), findsNothing);
  });

  testWidgets('affiche "Réessayer" seulement si onRetry est fourni', (
    tester,
  ) async {
    var retried = false;

    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: ErrorDisplay(
            error: Exception('panne réseau'),
            loggerName: 'test',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Réessayer'), findsOneWidget);
    await tester.tap(find.text('Réessayer'));
    expect(retried, isTrue);
  });
}
