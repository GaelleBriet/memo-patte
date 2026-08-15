import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_service_provider.dart';

/// Statut courant de la permission de notifications, et actions pour le
/// faire évoluer. Point de rencontre entre l'écran de priming (ticket 2.2,
/// qui appelle [NotificationPermissionStatusNotifier.requestPermission])
/// et le bandeau de statut (ticket 2.3, qui lit l'état et appelle
/// [NotificationPermissionStatusNotifier.refresh] au retour des réglages
/// système).
///
/// Écrit à la main (pas de codegen `@riverpod`), par cohérence avec
/// `features/animals/data/animals_list_provider.dart` : ce n'est pas
/// concerné par le bug Drift qui a motivé ce choix-là, mais la classe a
/// besoin de méthodes publiques au-delà du simple `build`, et rester
/// cohérent partout évite d'avoir à se souvenir au cas par cas quel
/// provider utilise le codegen.
final notificationPermissionStatusProvider =
    AsyncNotifierProvider<NotificationPermissionStatusNotifier, bool>(
      NotificationPermissionStatusNotifier.new,
    );

class NotificationPermissionStatusNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.watch(notificationServiceProvider).arePermissionsGranted();
  }

  /// Déclenche la vraie demande de permission côté OS
  /// ([NotificationService.requestPermission]) et met à jour l'état avec
  /// le résultat.
  ///
  /// Ne doit être appelée que depuis l'écran de priming (ticket 2.2) —
  /// jamais directement au lancement à froid, voir la décision actée le
  /// 2026-08-14 dans `decisions-log.md`.
  Future<bool> requestPermission() async {
    final granted = await ref
        .read(notificationServiceProvider)
        .requestPermission();
    state = AsyncData(granted);
    return granted;
  }

  /// Relit le statut auprès de l'OS, sans déclencher de nouvelle demande.
  ///
  /// Utilisé par le bandeau de statut `NotificationPermissionBanner`
  /// (ticket 2.3) quand l'app revient au premier plan, pour faire
  /// disparaître le bandeau sans attendre un redémarrage si la permission
  /// a été réactivée à la main dans les réglages système.
  ///
  /// Ne passe pas par un état `AsyncLoading` intermédiaire : [state] garde
  /// sa valeur précédente jusqu'à ce que la nouvelle soit connue, pour ne
  /// pas faire clignoter le bandeau (qui se cache pendant un chargement) le
  /// temps d'un aller-retour très bref vers l'OS.
  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(notificationServiceProvider).arePermissionsGranted(),
    );
  }
}
