import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/due_status.dart';
import '../../../core/widgets/delete_confirmation_sheet.dart';
import '../../../core/widgets/due_status_badge.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/reminder_times.dart';

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
              final l10n = AppLocalizations.of(context)!;
              final confirmed = await showDeleteConfirmationSheet(
                context,
                title: l10n.deleteTreatmentTitle,
                message: l10n.deleteTreatmentMessage(treatment.name),
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
              Text(
                AppLocalizations.of(context)!.treatmentNextDoseLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                _dueInLabel(context, treatment, now),
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

/// Avancement vers la prochaine dose ([Treatment.nextDueDate]) — la barre
/// de la maquette se remplit au fil du cycle, pas juste "fait/pas fait".
///
/// Deux bases de calcul selon la fréquence (voir
/// [TreatmentFrequency.usesReminderTimes], ajouté le 2026-08-17) :
/// - Cycle long : depuis la dernière administration ([Treatment.date])
///   jusqu'à la prochaine échéance — comportement d'origine.
/// - Heure(s) fixe(s) : depuis minuit jusqu'à la prochaine heure de
///   rappel — [Treatment.date] (date de *début* du traitement, pas de la
///   dernière prise) ferait une barre trompeuse, quasi toujours pleine,
///   si elle servait de point de départ ici.
double _progress(Treatment treatment, DateTime now) {
  final start = treatment.frequency.usesReminderTimes
      ? DateTime(now.year, now.month, now.day)
      : treatment.date;
  final total = treatment.nextDueDate.difference(start).inSeconds;
  if (total <= 0) return 1;
  final elapsed = now.difference(start).inSeconds;
  return (elapsed / total).clamp(0, 1);
}

/// "Dans 15 jours" / "Aujourd'hui" / "En retard de 3 jours" pour un cycle
/// long (au jour près, même granularité que [DueStatus.fromNextDueDate])
/// — "Aujourd'hui à 20:00" / "Demain à 08:00" pour une fréquence à
/// heure(s) fixe(s), voir [describeUpcomingReminder] (pas encore
/// localisé, voir son commentaire dans `reminder_times.dart`).
String _dueInLabel(BuildContext context, Treatment treatment, DateTime now) {
  if (treatment.frequency.usesReminderTimes) {
    return describeUpcomingReminder(treatment.nextDueDate, now);
  }

  final l10n = AppLocalizations.of(context)!;
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(
    treatment.nextDueDate.year,
    treatment.nextDueDate.month,
    treatment.nextDueDate.day,
  );
  final days = due.difference(today).inDays;

  if (days == 0) return l10n.treatmentDueToday;
  if (days > 0) return l10n.treatmentDueInDays(days);
  return l10n.treatmentOverdueDays(-days);
}
