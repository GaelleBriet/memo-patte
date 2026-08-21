import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'l10n/generated/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Explicite pour les appareils sous Android < 15 (API 35) — à partir de
  // l'API 35, `edgeToEdge` est le mode par défaut et à partir de l'API 36
  // (celle ciblée par ce projet, `flutter.targetSdkVersion`), Android ne
  // permet même plus de désactiver ce mode. Gardé quand même pour les
  // appareils plus anciens que peut cibler `minSdkVersion`.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // `statusBarColor` n'a plus aucun effet à partir de l'API 35/36 (edge-
  // to-edge forcé, la doc de `SystemChrome.setSystemUIOverlayStyle` le
  // dit explicitement) : `Colors.transparent` ici documente juste
  // l'intention, la vraie couleur vue derrière la barre de statut est
  // entièrement déterminée par ce que l'app peint elle-même à cet
  // endroit. Longtemps cru cassé (deux essais précédents, 2026-08-16) —
  // le vrai bug était ailleurs, dans les `ListView` des heros
  // (`home_screen.dart`/`animal_profile_screen.dart`) qui, sans
  // `padding: EdgeInsets.zero`, ajoutaient elles-mêmes un padding haut
  // = hauteur de barre de statut avant leur premier enfant, poussant le
  // dégradé sous la barre au lieu de l'étendre derrière elle.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark, // iOS
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MémoPatte',
      theme: AppTheme.light(),
      routerConfig: appRouter,
      // Préparation i18n (audit du 2026-08-19, issue #71 point 3.3) :
      // `AppLocalizations` (généré depuis `lib/l10n/*.arb`, voir
      // `l10n.yaml`) sait déjà servir FR et EN, mais `locale` reste
      // pinné en dur sur le français plutôt que `null` (qui suivrait la
      // langue système) — le produit n'est pas encore réellement
      // bilingue, seulement prêt à l'être. Retirer ce `locale:` (et
      // ajouter un sélecteur de langue si besoin) le jour où l'anglais
      // est vraiment exposé aux utilisateurs et utilisatrices ; ce
      // pin protège aussi les tests, qui cherchent du texte français en
      // dur (`find.text('Bonjour')`...) et casseraient si la locale du
      // système du test runner (souvent `en_US` par défaut) prenait le
      // dessus.
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
