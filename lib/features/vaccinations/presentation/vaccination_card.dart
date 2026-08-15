import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/surface_card.dart';
import '../domain/vaccination_status.dart';

/// Carte d'un vaccin, style "Carnet de santé" de
/// `docs/design/PetCare - Ma Vision` : barre d'accent 4 px colorée par
/// statut à gauche (à jour / à venir / en retard), pilule d'action ou
/// coche à droite.
///
/// Partagée entre `VaccinationsListScreen` (ticket 3.3, la liste
/// complète) et l'aperçu inline du profil animal (ticket 6.4) — même
/// rendu pour les deux points d'entrée, pas deux implémentations à faire
/// diverger.
class VaccinationCard extends StatelessWidget {
  const VaccinationCard({super.key, required this.vaccination, this.onTap});

  final Vaccination vaccination;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = VaccinationStatus.fromNextDueDate(
      vaccination.nextDueDate,
      DateTime.now(),
    );

    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          _StatusAccentBar(status: status),
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
                      ? 'Fait le ${_formatDate(vaccination.date)}'
                      : 'Fait le ${_formatDate(vaccination.date)} — '
                            'échéance le '
                            '${_formatDate(vaccination.nextDueDate!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusTrailing(status: status),
        ],
      ),
    );
  }
}

/// Barre verticale d'accent du design (4 px de large, coins arrondis),
/// colorée par statut.
class _StatusAccentBar extends StatelessWidget {
  const _StatusAccentBar({required this.status});

  final VaccinationStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 36,
      decoration: BoxDecoration(
        color: status.accentColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Côté droit de la carte, comme dans le design : pilule pleine quand le
/// statut appelle l'attention ("En retard", "À venir"), simple coche
/// sarcelle quand tout est à jour. Toujours libellé + couleur (ou icône
/// + libellé sémantique), jamais la couleur seule — lisible en cas de
/// daltonisme, la passe d'accessibilité du ticket 9.3 n'aura rien à
/// reprendre ici.
class _StatusTrailing extends StatelessWidget {
  const _StatusTrailing({required this.status});

  final VaccinationStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == VaccinationStatus.upToDate) {
      return Semantics(
        label: status.label,
        child: const Icon(Icons.check_circle, color: AppTheme.primaryTeal),
      );
    }

    final onAccent = switch (status) {
      // Rouge foncé : texte blanc. Sable ambré, clair : texte encre.
      VaccinationStatus.overdue => Colors.white,
      _ => AppTheme.ink,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.accentColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: onAccent,
        ),
      ),
    );
  }
}

extension on VaccinationStatus {
  Color get accentColor => switch (this) {
    VaccinationStatus.upToDate => AppTheme.validTeal,
    VaccinationStatus.dueSoon => AppTheme.sandAmber,
    VaccinationStatus.overdue => AppTheme.alertRed,
  };
}

String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
