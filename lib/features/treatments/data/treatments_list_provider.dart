import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'treatment_repository_provider.dart';

/// Flux réactif des traitements d'un animal, pour l'écran liste (ticket
/// 4.3). Écrit à la main (pas de codegen `@riverpod`) : type de retour
/// Drift, même contournement que `vaccinations_list_provider.dart` (bug
/// `InvalidTypeException` de `riverpod_generator`,
/// https://github.com/rrousselGit/riverpod/issues/4363).
final treatmentsListProvider = StreamProvider.family<List<Treatment>, int>((
  ref,
  animalId,
) {
  final repository = ref.watch(treatmentRepositoryProvider);
  return repository.watchForAnimal(animalId);
});
