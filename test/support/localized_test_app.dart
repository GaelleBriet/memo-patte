import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:memo_patte/l10n/generated/app_localizations.dart';

/// Délégués/locale nécessaires pour pomper un vrai écran de l'app en
/// test — depuis la préparation i18n (audit du 2026-08-19, issue #71
/// point 3.3), les écrans lisent `AppLocalizations.of(context)!` ; sans
/// ces délégués, n'importe quel `MaterialApp` de test plante (`Null
/// check operator used on a null value`) dès qu'il pompe un widget qui y
/// touche. Locale française fixée en dur, comme la vraie app
/// (`main.dart`) — les tests cherchent du texte français en dur
/// (`find.text('Bonjour')`...), qui casserait si la locale suivait
/// celle (souvent `en_US`) du runner de tests.
const List<LocalizationsDelegate<Object?>> testLocalizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const Locale testLocale = Locale('fr');

/// `MaterialApp` minimal mais localisé, pour les tests qui n'ont besoin
/// que d'un `home:` (pas de `MaterialApp.router` — voir
/// `create_animal_screen_test.dart`/`app_shell_navigation_test.dart`
/// pour ce cas, qui ajoutent les mêmes délégués directement).
Widget localizedTestApp({required Widget home}) {
  return MaterialApp(
    locale: testLocale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: testLocalizationsDelegates,
    home: home,
  );
}
