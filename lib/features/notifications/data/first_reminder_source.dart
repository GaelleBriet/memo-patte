import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../treatments/data/treatment_repository_provider.dart';
import '../../vaccinations/data/vaccination_repository_provider.dart';

/// Vrai si aucun vaccin ni traitement n'existe encore, tous animaux
/// confondus — condition du "premier vaccin ou traitement" qui
/// déclenche l'écran de priming (ticket 2.2, décision du 2026-08-14
/// dans `decisions-log.md` : l'app ne demande la permission de
/// notifications qu'à ce moment-là, pas au lancement à froid).
///
/// Partagé entre `VaccinationFormScreen` (ticket 3.2) et
/// `TreatmentFormScreen` (ticket 4.2) plutôt que dupliqué — annoncé dans
/// le commentaire de `VaccinationFormScreen._submit` à l'époque du
/// ticket 3.2 ("le ticket 4.2 devra étendre ce 'premier' aux deux
/// tables confondues"), maintenant que l'épic 4 est ce deuxième
/// appelant.
Future<bool> isFirstReminderSource(WidgetRef ref) async {
  final hasVaccinations = await ref
      .read(vaccinationRepositoryProvider)
      .hasAnyVaccinations();
  if (hasVaccinations) return false;

  final hasTreatments = await ref
      .read(treatmentRepositoryProvider)
      .hasAnyTreatments();
  return !hasTreatments;
}
