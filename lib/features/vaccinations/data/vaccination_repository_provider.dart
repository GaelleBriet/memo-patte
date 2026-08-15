import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/notifications/notification_service_provider.dart';
import '../../animals/data/animal_dao.dart';
import 'vaccination_dao.dart';
import 'vaccination_repository.dart';

part 'vaccination_repository_provider.g.dart';

/// Même durée de vie que [appDatabaseProvider], pour les mêmes raisons
/// que `animal_repository_provider.dart`.
@Riverpod(keepAlive: true)
VaccinationRepository vaccinationRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return VaccinationRepository(
    VaccinationDao(database),
    AnimalDao(database),
    ref.watch(notificationServiceProvider),
  );
}
