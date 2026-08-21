import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../domain/due_status.dart';

/// Couleur d'accent associée à un [DueStatus] — même palette partout
/// dans l'app (barre d'accent des cartes, pilule de statut...).
Color dueStatusAccentColor(DueStatus status) => switch (status) {
  DueStatus.upToDate => AppTheme.validTeal,
  DueStatus.dueSoon => AppTheme.sandAmber,
  DueStatus.overdue => AppTheme.alertRed,
};

/// Pilule de statut du design `docs/design/PetCare - Ma Vision` : pleine
/// et colorée quand le statut appelle l'attention ("En retard", "À
/// venir"), simple coche sarcelle quand tout est à jour. Toujours
/// libellé + couleur, jamais la couleur seule — lisible en cas de
/// daltonisme, la passe d'accessibilité du ticket 9.3 n'aura rien à
/// reprendre ici.
///
/// Partagée entre `VaccinationCard` (ticket 3.3) et `TreatmentCard`
/// (ticket 4.3) — extraite au moment où le second en a eu besoin, même
/// principe que l'extraction de [DueStatus] lui-même.
class DueStatusBadge extends StatelessWidget {
  const DueStatusBadge({super.key, required this.status});

  final DueStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == DueStatus.upToDate) {
      return Semantics(
        label: status.label(context),
        child: const Icon(Icons.check_circle, color: AppTheme.primaryTeal),
      );
    }

    final color = dueStatusAccentColor(status);
    // Rouge foncé : texte blanc. Sable ambré, clair : texte encre.
    final onAccent = status == DueStatus.overdue ? Colors.white : AppTheme.ink;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label(context),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: onAccent,
        ),
      ),
    );
  }
}
