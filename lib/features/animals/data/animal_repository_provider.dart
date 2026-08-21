import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_provider.dart';
import '../../treatments/data/treatment_repository_provider.dart';
import '../../vaccinations/data/vaccination_repository_provider.dart';
import 'animal_dao.dart';
import 'animal_repository.dart';

part 'animal_repository_provider.g.dart';

/// Même durée de vie que [appDatabaseProvider] : le repository ne fait
/// qu'envelopper le DAO, pas de raison qu'il soit recréé indépendamment de
/// la connexion à la base.
///
/// Dépend aussi de [vaccinationRepositoryProvider]/
/// [treatmentRepositoryProvider] depuis le 2026-08-21 (audit issue #71
/// point 1.2) — voir le commentaire de classe d'[AnimalRepository].
@Riverpod(keepAlive: true)
AnimalRepository animalRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return AnimalRepository(
    AnimalDao(database),
    ref.watch(vaccinationRepositoryProvider),
    ref.watch(treatmentRepositoryProvider),
  );
}
