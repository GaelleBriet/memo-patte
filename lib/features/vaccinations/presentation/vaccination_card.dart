import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/delete_confirmation_sheet.dart';
import '../../../core/widgets/due_status_badge.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/vaccination_status.dart';

/// Carte d'un vaccin, style "Carnet de santé" de
/// `docs/design/PetCare - Ma Vision` : barre d'accent 4 px colorée par
/// statut à gauche (à jour / à venir / en retard), pilule d'action ou
/// coche à droite (voir [DueStatusBadge]).
///
/// Partagée entre `VaccinationsListScreen` (ticket 3.3, la liste
/// complète) et l'aperçu inline du profil animal (ticket 6.4) — même
/// rendu pour les deux points d'entrée, pas deux implémentations à faire
/// diverger.
///
/// Appui long → suppression (si [onDelete] est fourni) : voir
/// `delete_confirmation_sheet.dart`, même feuille de confirmation que
/// `TreatmentCard` pour rester cohérent dans toute l'appli (ajouté le
/// 2026-08-17).
class VaccinationCard extends StatelessWidget {
  const VaccinationCard({
    super.key,
    required this.vaccination,
    this.onTap,
    this.onDelete,
  });

  final Vaccination vaccination;
  final VoidCallback? onTap;

  /// Si fourni, un appui long propose de supprimer ce vaccin.
  final Future<void> Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    final status = VaccinationStatus.fromNextDueDate(
      vaccination.nextDueDate,
      DateTime.now(),
    );

    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      onLongPress: onDelete == null
          ? null
          : () async {
              final l10n = AppLocalizations.of(context)!;
              final confirmed = await showDeleteConfirmationSheet(
                context,
                title: l10n.deleteVaccinationTitle,
                message: l10n.deleteVaccinationMessage(vaccination.name),
              );
              if (confirmed) await onDelete!();
            },
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: dueStatusAccentColor(status),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccination.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vaccination.nextDueDate == null
                      ? AppLocalizations.of(
                          context,
                        )!.vaccinationDoneOn(_formatDate(vaccination.date))
                      : AppLocalizations.of(context)!.vaccinationDoneOnWithDue(
                          _formatDate(vaccination.date),
                          _formatDate(vaccination.nextDueDate!),
                        ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DueStatusBadge(status: status),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
