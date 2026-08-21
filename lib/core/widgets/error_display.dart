import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../logging/app_logger.dart';

/// Affichage d'erreur générique et réutilisable — remplace les
/// `Text('Erreur de chargement : $error')` disséminés dans les écrans
/// (audit du 2026-08-19, issue #71 point 3.2) : un rendu cohérent avec
/// le reste du design (même motif d'icône que
/// `delete_confirmation_sheet.dart` — cercle rouge pâle, pas juste du
/// texte brut) plutôt qu'un composant par écran, et une trace loggée
/// (`AppLogger`) plutôt qu'une erreur seulement visible tant que
/// l'écran reste affiché.
///
/// Loggue à chaque `build()`, pas uniquement à la première apparition
/// de l'erreur : un `AsyncValue` en état d'erreur reste en erreur tant
/// que rien ne le fait réévaluer, donc un rebuild non lié (ex. un autre
/// widget de l'arbre qui se met à jour) rejouera ce log. Accepté
/// volontairement plutôt que de complexifier chaque site d'appel avec
/// un suivi de transition d'état (`ref.listen`) juste pour dédupliquer
/// des logs de debug peu coûteux à répéter.
class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    super.key,
    required this.error,
    required this.loggerName,
    this.stackTrace,
    this.onRetry,
  });

  final Object error;

  /// Origine de l'erreur (nom d'écran/provider) — voir `AppLogger.error`.
  final String loggerName;
  final StackTrace? stackTrace;

  /// Si fourni, affiche un bouton "Réessayer" qui l'appelle — utile
  /// quand l'appelant peut ré-observer la source (`ref.invalidate`...).
  /// Pas de valeur par défaut generique (ex. relancer l'écran) : chaque
  /// site sait mieux que ce composant ce que "réessayer" veut dire chez
  /// lui, ou si ça n'a pas de sens (chargement one-shot).
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    AppLogger.error(loggerName, error, stackTrace: stackTrace);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0x1AC64E31), // alertRed à 10 % d'opacité.
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppTheme.alertRed,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Une erreur est survenue',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
            ],
          ],
        ),
      ),
    );
  }
}
