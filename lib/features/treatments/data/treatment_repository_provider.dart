import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/notifications/notification_service_provider.dart';
import '../../animals/data/animal_dao.dart';
import 'treatment_dao.dart';
import 'treatment_repository.dart';

part 'treatment_repository_provider.g.dart';

/// Même durée de vie que [appDatabaseProvider], pour les mêmes raisons
/// que `vaccination_repository_provider.dart`.
@Riverpod(keepAlive: true)
TreatmentRepository treatmentRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return TreatmentRepository(
    TreatmentDao(database),
    AnimalDao(database),
    ref.watch(notificationServiceProvider),
  );
}
