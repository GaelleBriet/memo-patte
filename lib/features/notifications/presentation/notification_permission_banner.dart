import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/notifications/notification_service_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/notification_permission_provider.dart';

/// Bandeau persistant (ticket 2.3) affiché sur l'écran d'accueil quand la
/// permission de notifications est refusée. Décision actée le 2026-08-14
/// dans `decisions-log.md` : pas de blocage de l'app, pas de reprompt
/// automatique — juste ce bandeau discret, avec un lien direct vers les
/// réglages système de notifications de l'app.
///
/// N'affiche rien tant que le statut n'est pas encore connu (chargement,
/// ou erreur de lecture) ni si la permission est accordée : seul le cas
/// "refusée" a un rendu visuel.
class NotificationPermissionBanner extends ConsumerStatefulWidget {
  const NotificationPermissionBanner({super.key});

  @override
  ConsumerState<NotificationPermissionBanner> createState() =>
      _NotificationPermissionBannerState();
}

class _NotificationPermissionBannerState
    extends ConsumerState<NotificationPermissionBanner>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Le seul endroit d'où on peut réactiver la permission une fois
    // refusée est les réglages système (lien de ce bandeau, voir `build`
    // ci-dessous) — pas de reprompt via l'app elle-même. On relit le
    // statut au retour au premier plan pour que le bandeau disparaisse
    // sans attendre un redémarrage de l'app si l'utilisateur l'a
    // réactivée à la main.
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationPermissionStatusProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final granted = ref.watch(notificationPermissionStatusProvider).value;

    if (granted == null || granted) {
      return const SizedBox.shrink();
    }

    // Accent "action requise" du design (`AppTheme.alertRed`) sur fond
    // teinté, plutôt que le rouge Material par défaut.
    return Material(
      color: AppTheme.alertRed.withValues(alpha: 0.12),
      child: InkWell(
        onTap: () =>
            ref.read(notificationServiceProvider).openNotificationSettings(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.notifications_off_outlined,
                color: AppTheme.alertRed,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!
                      .notificationPermissionBannerText,
                  style: const TextStyle(
                    color: AppTheme.alertRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.alertRed),
            ],
          ),
        ),
      ),
    );
  }
}
