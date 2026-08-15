import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service.dart';

/// Instance unique de [NotificationService] pour toute l'app.
///
/// Écrit à la main (pas de codegen `@riverpod`), comme
/// `features/animals/data/animals_list_provider.dart` — pas de type Drift
/// en jeu ici, mais aucun des providers de `core/notifications` n'a besoin
/// du codegen, donc autant rester cohérent avec le provider qu'il expose
/// ([notificationPermissionStatusProvider], écrit à la main aussi).
///
/// Pas de `.autoDispose` : comme `appDatabaseProvider`, le plugin de
/// notifications ne doit pas être réinitialisé au gré des écrans qui
/// l'observent ou non.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
