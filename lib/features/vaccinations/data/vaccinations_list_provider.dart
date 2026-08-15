import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'vaccination_repository_provider.dart';

/// Flux réactif des vaccins d'un animal, pour l'écran liste (ticket 3.3).
///
/// Écrit à la main (pas de codegen `@riverpod`) : type de retour Drift,
/// même contournement que `animals_list_provider.dart` (bug
/// `InvalidTypeException` de `riverpod_generator`,
/// https://github.com/rrousselGit/riverpod/issues/4363).
final vaccinationsListProvider = StreamProvider.family<List<Vaccination>, int>((
  ref,
  animalId,
) {
  final repository = ref.watch(vaccinationRepositoryProvider);
  return repository.watchForAnimal(animalId);
});
