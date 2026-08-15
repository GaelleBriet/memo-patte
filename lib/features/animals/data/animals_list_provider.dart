import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'animal_repository_provider.dart';

/// Flux réactif de tous les animaux, pour l'écran liste (ticket 1.3).
///
/// Écrit à la main (pas de codegen `@riverpod`) : le codegen plante avec
/// `InvalidTypeException` sur les providers `Stream<List<T>>` où `T` est un
/// type généré par un autre outil (ici Drift, `Animal`) — bug connu de
/// `riverpod_generator`, pas propre à ce projet :
/// https://github.com/rrousselGit/riverpod/issues/4363
/// `StreamNotifierProvider` écrit à la main = contournement recommandé par
/// le mainteneur, sans perte de fonctionnalité par rapport au codegen.
///
/// Piège constaté en écrivant les tests du ticket 6.1
/// (`home_reminders_provider_test.dart`) : `container.read(animalsListProvider.future)`
/// ne se résout jamais (bloque indéfiniment), probablement apparenté au
/// même bug côté runtime plutôt qu'un défaut d'usage — `container.listen`
/// puis `container.read` en boucle jusqu'à sortie de `AsyncLoading`
/// fonctionne, lui. Voir le helper `settle` dans ce fichier de test pour
/// le contournement.
final animalsListProvider =
    StreamNotifierProvider<AnimalsListNotifier, List<Animal>>(
      AnimalsListNotifier.new,
    );

class AnimalsListNotifier extends StreamNotifier<List<Animal>> {
  @override
  Stream<List<Animal>> build() {
    final repository = ref.watch(animalRepositoryProvider);
    return repository.watchAnimals();
  }
}
