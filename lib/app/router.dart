import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/animals/presentation/animal_profile_screen.dart';
import '../features/animals/presentation/animals_list_screen.dart';
import '../features/animals/presentation/create_animal_screen.dart';
import '../features/notifications/presentation/notification_permission_banner.dart';
import '../features/notifications/presentation/notification_priming_screen.dart';

/// Router minimal de l'app.
///
/// Le vrai écran d'accueil (vue consolidée multi-animaux, différenciant
/// n°2) arrive au ticket 6.2, dans `features/home/`. `_HomePlaceholder`
/// n'est qu'un jalon de navigation en attendant — volontairement gardé
/// hors de `features/` pour ne pas empiéter sur le ticket 0.4 (structure
/// de dossiers `features/`), et à supprimer quand 6.2 le remplace.
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const _HomePlaceholder(),
      routes: [
        GoRoute(
          path: 'animals',
          name: 'animalsList',
          builder: (context, state) => const AnimalsListScreen(),
          routes: [
            GoRoute(
              path: 'new',
              name: 'createAnimal',
              builder: (context, state) => const CreateAnimalScreen(),
            ),
            GoRoute(
              // Segment statique 'new' testé avant ':id' par go_router
              // (les routes littérales priment sur les routes
              // dynamiques au même niveau) — pas d'ambiguïté entre
              // /animals/new et /animals/<id>.
              path: ':id',
              name: 'animalProfile',
              builder: (context, state) => AnimalProfileScreen(
                animalId: int.parse(state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        GoRoute(
          // Pas encore appelée automatiquement nulle part (voir le
          // commentaire de classe de `NotificationPrimingScreen`) : les
          // tickets 3.2/4.2 qui doivent la déclencher n'existent pas
          // encore. Route nommée exposée dès maintenant pour que ces
          // tickets-là n'aient qu'à naviguer dessus, et pour permettre un
          // aperçu manuel via le bouton temporaire de `_HomePlaceholder`.
          path: 'notifications/priming',
          name: 'notificationPriming',
          builder: (context, state) => const NotificationPrimingScreen(),
        ),
      ],
    ),
  ],
);

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MémoPatte'),
        actions: [
          // Aperçu manuel temporaire de l'écran de priming (ticket 2.2),
          // pour pouvoir le tester sur téléphone avant que les tickets
          // 3.2/4.2 (création vaccin/traitement) ne le déclenchent pour
          // de vrai. À retirer quand l'un de ces tickets fournit le vrai
          // point d'entrée.
          IconButton(
            onPressed: () => context.goNamed('notificationPriming'),
            tooltip: 'Aperçu : demande de permission notifications',
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      // Le bandeau de statut (ticket 2.3) s'affiche seulement si la
      // permission de notifications a été refusée — `SizedBox.shrink()`
      // sinon, voir `NotificationPermissionBanner`.
      body: Column(
        children: [
          const NotificationPermissionBanner(),
          const Expanded(
            child: Center(child: Text('Écran d\'accueil à venir')),
          ),
        ],
      ),
      // Point d'entrée temporaire vers l'écran liste des animaux (ticket
      // 1.3), qui a lui-même son propre bouton "+" vers la création. À
      // retirer quand le vrai écran d'accueil (ticket 6.2) le remplace.
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed('animalsList'),
        tooltip: 'Voir mes animaux',
        child: const Icon(Icons.pets),
      ),
    );
  }
}
