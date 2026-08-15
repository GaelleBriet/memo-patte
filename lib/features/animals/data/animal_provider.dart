import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'animal_repository_provider.dart';

/// Un animal par id, pour l'écran profil (ticket 1.4).
///
/// `FutureProvider.family` écrit à la main plutôt qu'en codegen
/// `@riverpod` : même famille de bug que [animalsListProvider]
/// (`InvalidTypeException` sur un type généré par Drift,
/// https://github.com/rrousselGit/riverpod/issues/4363) — pas vérifié que
/// `Future<Animal?>` (par opposition à `Stream<List<Animal>>`) y est aussi
/// sujet, mais pas envie de le découvrir en CI. Écrit à la main partout où
/// le type de retour touche à un type Drift, par cohérence.
final animalProvider = FutureProvider.family<Animal?, int>((ref, id) {
  final repository = ref.watch(animalRepositoryProvider);
  return repository.getAnimal(id);
});
