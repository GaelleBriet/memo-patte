import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notification_permission_provider.dart';

/// Écran de "priming" (ticket 2.2) : explique pourquoi l'app demande la
/// permission de notifications *avant* de déclencher la vraie popup
/// système, plutôt que de la griller au lancement à froid. Décision actée
/// le 2026-08-14 dans `decisions-log.md`.
///
/// Doit être affiché juste avant la création du premier vaccin ou
/// traitement (pas au lancement à froid) — mais les écrans qui créent ces
/// entités n'existent pas encore (tickets 3.2/4.2, épics postérieures à
/// celle-ci dans l'ordre de séquencement de `02-tickets-v1.md`). Ce sont
/// ces tickets-là qui pousseront cet écran (`Navigator.push` ou route
/// nommée `notificationPriming`) avant la première sauvegarde ; ce ticket
/// se limite à livrer l'écran lui-même, prêt à être appelé.
///
/// `Navigator.pop` renvoie `true` si la permission a été accordée, `false`
/// sinon (refus, ou fermeture via "Plus tard" sans interagir avec l'OS).
class NotificationPrimingScreen extends ConsumerStatefulWidget {
  const NotificationPrimingScreen({super.key});

  @override
  ConsumerState<NotificationPrimingScreen> createState() =>
      _NotificationPrimingScreenState();
}

class _NotificationPrimingScreenState
    extends ConsumerState<NotificationPrimingScreen> {
  bool _requesting = false;

  Future<void> _requestPermission() async {
    setState(() => _requesting = true);
    final granted = await ref
        .read(notificationPermissionStatusProvider.notifier)
        .requestPermission();
    if (mounted) {
      Navigator.of(context).pop(granted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Activer les rappels')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_active_outlined,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Ne rate plus jamais un rappel',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'MémoPatte peut te prévenir quand un vaccin ou un '
              'vermifuge approche de son échéance. Autorise les '
              'notifications pour ne rien oublier — tu pourras changer '
              'd\'avis à tout moment dans les réglages de ton téléphone.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _requesting ? null : _requestPermission,
              child: _requesting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Activer les rappels'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _requesting
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: const Text('Plus tard'),
            ),
          ],
        ),
      ),
    );
  }
}
