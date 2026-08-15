import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Thème de MémoPatte, aligné sur la référence de style
/// `docs/design/PetCare - Ma Vision` (décision du 2026-08-13 :
/// référence de style — couleurs, typo, composants — pas un plan de
/// fonctionnalités).
///
/// Les couleurs sont les conversions sRGB exactes des valeurs `oklch()`
/// du fichier de design (commentées ligne à ligne). Les anciennes
/// valeurs du thème (#2F6F66/#1B3A3A) venaient en fait de la vignette
/// SVG de chargement du fichier, pas de la maquette — c'est ce qui
/// expliquait l'écart visuel.
///
/// Note offline-first : `google_fonts` télécharge les fontes au premier
/// lancement puis les met en cache localement sur l'appareil. Sans réseau
/// à ce moment-là, Flutter se rabat silencieusement sur la police système
/// — aucune erreur, aucun impact sur les fonctionnalités coeur (rappels,
/// saisie...). Si un contrôle strict est voulu plus tard, ticket 9.2
/// (polish/branding) pourra bundler les fontes en assets locaux.
class AppTheme {
  AppTheme._();

  // -- Palette (oklch du design → sRGB) --------------------------------

  /// Texte principal et surfaces sombres — oklch(20% 0.02 250).
  static const ink = Color(0xFF0F171F);

  /// Sarcelle profond, couleur principale — oklch(42% 0.08 200).
  static const primaryTeal = Color(0xFF005A5E);

  /// Dégradé d'en-tête, extrémité sombre — oklch(28% 0.06 200).
  static const headerTealDark = Color(0xFF003134);

  /// Dégradé d'en-tête, extrémité claire — oklch(48% 0.09 200).
  static const headerTealLight = Color(0xFF006C72);

  /// Fond sable chaud de tous les écrans — oklch(94% 0.01 70).
  static const cream = Color(0xFFF0EAE4);

  /// Surface des cartes, blanc cassé — oklch(99% 0.004 70).
  static const cardSurface = Color(0xFFFEFBF9);

  /// Texte secondaire — oklch(50% 0.02 250).
  static const textSecondary = Color(0xFF5B646F);

  /// Fond menthe des pastilles d'icône — oklch(85% 0.05 200).
  static const mint = Color(0xFFA8D8DB);

  /// Variante pâle du fond menthe — oklch(90% 0.04 200).
  static const mintPale = Color(0xFFC0E7E8);

  /// Couleur d'icône posée sur fond menthe — oklch(35% 0.08 200).
  static const tealOnMint = Color(0xFF00464B);

  /// Accent "action requise / en retard" — oklch(58% 0.16 35).
  static const alertRed = Color(0xFFC64E31);

  /// Accent "échéance proche", sable ambré — oklch(80% 0.06 90).
  static const sandAmber = Color(0xFFCDBD92);

  /// Accent "valide / à jour", sarcelle doux — oklch(70% 0.06 200).
  static const validTeal = Color(0xFF71AAAD);

  /// Séparateurs et bordures discrètes — oklch(88% 0.01 70).
  static const divider = Color(0xFFDCD6D1);

  // -- Composants partagés ---------------------------------------------

  /// Dégradé signature des en-têtes du design
  /// (`linear-gradient(160deg, ...)`) : à poser en `flexibleSpace` d'un
  /// `AppBar` — `AppBarTheme` ne sait pas porter un dégradé globalement.
  static const headerGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [headerTealDark, headerTealLight],
    ),
  );

  /// Ombre douce des cartes du design
  /// (`0 4px 12px rgba(20,20,20,0.05)`), consommée par `SurfaceCard`.
  static const cardShadow = [
    BoxShadow(color: Color(0x0D141414), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primaryTeal,
          brightness: Brightness.light,
        ).copyWith(
          primary: primaryTeal,
          onPrimary: Colors.white,
          primaryContainer: mintPale,
          onPrimaryContainer: tealOnMint,
          surface: cream,
          onSurface: ink,
          onSurfaceVariant: textSecondary,
          error: alertRed,
          outlineVariant: divider,
        );

    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: ink,
      displayColor: ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: cream,
      textTheme: textTheme.copyWith(
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      appBarTheme: AppBarTheme(
        // Couleur de repli sous le dégradé (voir [headerGradient]) et
        // pour les AppBar qui ne le posent pas.
        backgroundColor: headerTealDark,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      // Boutons pilule (radius 999 dans le design).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: primaryTeal),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: const StadiumBorder()),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),
      // Champs de saisie : surface carte, coins arrondis, bordure
      // discrète qui passe sarcelle au focus.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: const StadiumBorder(),
          selectedBackgroundColor: primaryTeal,
          selectedForegroundColor: Colors.white,
          backgroundColor: cardSurface,
          side: const BorderSide(color: divider),
        ),
      ),
      dividerTheme: const DividerThemeData(color: divider),
      listTileTheme: const ListTileThemeData(iconColor: primaryTeal),
    );
  }
}
