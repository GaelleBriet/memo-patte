import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'vaccination_repository_provider.dart';

/// Un vaccin par id, pour préremplir le formulaire d'édition
/// (ticket 3.2). Écrit à la main pour les mêmes raisons que
/// `animal_provider.dart` (type de retour Drift).
final vaccinationProvider = FutureProvider.family<Vaccination?, int>((ref, id) {
  final repository = ref.watch(vaccinationRepositoryProvider);
  return repository.getVaccination(id);
});
