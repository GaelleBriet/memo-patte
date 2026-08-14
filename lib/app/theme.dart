import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Thème de base de MémoPatte.
///
/// Palette et typographie reprises de la référence de style
/// `docs/design/PetCare - Ma Vision` (teal profond + fond crème,
/// Space Grotesk pour les titres, Inter pour le texte courant).
///
/// Note offline-first : `google_fonts` télécharge les fontes au premier
/// lancement puis les met en cache localement sur l'appareil. Sans réseau
/// à ce moment-là, Flutter se rabat silencieusement sur la police système
/// — aucune erreur, aucun impact sur les fonctionnalités coeur (rappels,
/// saisie...). Si un contrôle strict est voulu plus tard, ticket 9.2
/// (polish/branding) pourra bundler les fontes en assets locaux.
class AppTheme {
  AppTheme._();

  static const primaryTeal = Color(0xFF2F6F66);
  static const darkTeal = Color(0xFF1B3A3A);
  static const creamBackground = Color(0xFFF5F1EA);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.light,
    ).copyWith(surface: creamBackground);

    final textTheme = GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: darkTeal,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: darkTeal,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: creamBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: darkTeal,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
