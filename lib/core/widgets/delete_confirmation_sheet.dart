import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../l10n/generated/app_localizations.dart';

/// Feuille de confirmation de suppression, déclenchée par un appui long
/// sur une ligne de carnet (vaccin, traitement...) — pattern partagé pour
/// que la suppression se comporte et se voie pareil partout dans l'appli,
/// plutôt qu'un `AlertDialog` par écran. Retourne `true` seulement si
/// l'utilisateur a confirmé.
///
/// `HapticFeedback.mediumImpact()` accompagne le déclenchement : un
/// retour tactile "action disponible" au moment de l'appui long, avant
/// même que la feuille ne s'ouvre — cohérent avec le geste plutôt
/// qu'ajouté après coup sur le bouton "Supprimer".
Future<bool> showDeleteConfirmationSheet(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  HapticFeedback.mediumImpact();
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        _DeleteConfirmationSheet(title: title, message: message),
  );
  return confirmed ?? false;
}

class _DeleteConfirmationSheet extends StatelessWidget {
  const _DeleteConfirmationSheet({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0x1AC64E31), // alertRed à 10 % d'opacité.
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.alertRed,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(AppLocalizations.of(context)!.commonCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.alertRed,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        AppLocalizations.of(context)!.commonDelete,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
