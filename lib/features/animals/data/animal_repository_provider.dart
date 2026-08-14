import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_provider.dart';
import 'animal_dao.dart';
import 'animal_repository.dart';

part 'animal_repository_provider.g.dart';

/// Même durée de vie que [appDatabaseProvider] : le repository ne fait
/// qu'envelopper le DAO, pas de raison qu'il soit recréé indépendamment de
/// la connexion à la base.
@Riverpod(keepAlive: true)
AnimalRepository animalRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return AnimalRepository(AnimalDao(database));
}
