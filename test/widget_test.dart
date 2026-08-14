import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memo_patte/main.dart';

void main() {
  testWidgets('App démarre et affiche l\'écran d\'accueil', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('MémoPatte'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
