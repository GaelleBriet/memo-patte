import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/due_status.dart';
import '../../../core/widgets/delete_confirmation_sheet.dart';
import '../../../core/widgets/due_status_badge.dart';
import '../../../core/widgets/surface_card.dart';

/// Carte d'un traitement, style "Traitement en cours" de
/// `docs/design/PetCare - Ma Vision` : nom + pilule de statut en tête,
/// puis "Prochaine dose" avec barre de progression — pas la barre
/// d'accent à gauche de `VaccinationCard`, la maquette ne s'en sert pas
/// pour cette section-là.
///
/// Partagée entre `TreatmentsListScreen` (ticket 4.3) et l'aperçu inline
/// du profil animal, même principe que `VaccinationCard`.
///
/// Appui long → suppression (si [onDelete] est fourni) : voir
/// `delete_confirmation_sheet.dart` (ajouté le 2026-08-17).
class TreatmentCard extends StatelessWidget {
  const TreatmentCard({
    super.key,
    required this.treatment,
    this.onTap,
    this.onDelete,
  });

  final Treatment treatment;
  final VoidCallback? onTap;

  /// Si fourni, un appui long propose de supprimer ce traitement.
  final Future<void> Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final status = DueStatus.fromNextDueDate(treatment.nextDueDate, now);

    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      onLongPress: onDelete == null
          ? null
          : () async {
              final confirmed = await showDeleteConfirmationSheet(
                context,
                title: 'Supprimer ce traitement ?',
                message:
                    '"${treatment.name}" sera définitivement supprimé, '
                    'ainsi que son rappel programmé.',
              );
              if (confirmed) await onDelete!();
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconChip(icon: Icons.medication_outlined, size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  treatment.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DueStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Prochaine dose',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              Text(
                _dueInLabel(treatment.nextDueDate, now),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _progress(treatment, now),
              minHeight: 6,
              backgroundColor: AppTheme.divider,
              valueColor: AlwaysStoppedAnimation(dueStatusAccentColor(status)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avancement entre la dernière administration ([Treatment.date]) et la
/// prochaine dose ([Treatment.nextDueDate]) — la barre de la maquette se
/// remplit au fil du cycle, pas juste "fait/pas fait".
double _progress(Treatment treatment, DateTime now) {
  final total = treatment.nextDueDate.difference(treatment.date).inSeconds;
  if (total <= 0) return 1;
  final elapsed = now.difference(treatment.date).inSeconds;
  return (elapsed / total).clamp(0, 1);
}

/// "Dans 15 jours" / "Aujourd'hui" / "En retard de 3 jours" — au jour
/// près, même granularité que [DueStatus.fromNextDueDate] (une échéance
/// de traitement est une date de carnet, pas un instant précis).
String _dueInLabel(DateTime dueDate, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final days = due.difference(today).inDays;

  if (days == 0) return 'Aujourd\'hui';
  if (days > 0) return 'Dans $days jour${days > 1 ? 's' : ''}';
  final late = -days;
  return 'En retard de $late jour${late > 1 ? 's' : ''}';
}
