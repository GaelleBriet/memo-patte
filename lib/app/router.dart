import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/gradient_app_bar.dart';
import '../features/animals/presentation/animal_profile_screen.dart';
import '../features/animals/presentation/animals_list_screen.dart';
import '../features/animals/presentation/create_animal_screen.dart';
import '../features/notifications/presentation/notification_permission_banner.dart';
import '../features/vaccinations/presentation/vaccination_form_screen.dart';
import '../features/vaccinations/presentation/vaccinations_list_screen.dart';

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
              routes: [
                GoRoute(
                  path: 'vaccinations',
                  name: 'vaccinationsList',
                  builder: (context, state) => VaccinationsListScreen(
                    animalId: int.parse(state.pathParameters['id']!),
                  ),
                  routes: [
                    GoRoute(
                      path: 'new',
                      name: 'createVaccination',
                      builder: (context, state) => VaccinationFormScreen(
                        animalId: int.parse(state.pathParameters['id']!),
                      ),
                    ),
                    GoRoute(
                      // Même remarque 'new' avant ':vaccinationId' que
                      // pour /animals ci-dessus.
                      path: ':vaccinationId',
                      name: 'editVaccination',
                      builder: (context, state) => VaccinationFormScreen(
                        animalId: int.parse(state.pathParameters['id']!),
                        vaccinationId: int.parse(
                          state.pathParameters['vaccinationId']!,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // L'écran de priming (ticket 2.2) n'a plus de route nommée : son
        // vrai point d'entrée est le formulaire vaccin (ticket 3.2), qui
        // le pousse directement via Navigator pour en attendre le
        // résultat — voir `VaccinationFormScreen`.
      ],
    ),
  ],
);

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Le bouton d'aperçu temporaire du priming (ajouté au ticket 2.2)
      // a été retiré : le ticket 3.2 fournit le vrai point d'entrée
      // (création du premier vaccin), comme prévu.
      appBar: const GradientAppBar(title: Text('MémoPatte')),
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
