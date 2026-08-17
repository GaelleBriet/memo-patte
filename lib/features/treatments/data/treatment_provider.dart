import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'treatment_repository_provider.dart';

/// Un traitement par id, pour préremplir le formulaire d'édition
/// (ticket 4.2). Écrit à la main pour les mêmes raisons que
/// `vaccination_provider.dart` (type de retour Drift).
final treatmentProvider = FutureProvider.family<Treatment?, int>((ref, id) {
  final repository = ref.watch(treatmentRepositoryProvider);
  return repository.getTreatment(id);
});
