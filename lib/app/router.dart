import 'package:go_router/go_router.dart';

import '../features/animals/presentation/animal_profile_screen.dart';
import '../features/animals/presentation/create_animal_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/treatments/presentation/treatment_form_screen.dart';
import '../features/treatments/presentation/treatments_list_screen.dart';
import '../features/vaccinations/presentation/vaccination_form_screen.dart';
import '../features/vaccinations/presentation/vaccinations_list_screen.dart';
import 'app_shell.dart';

/// Router de l'app, avec coquille de navigation persistante (ticket 6.0,
/// `StatefulShellRoute.indexedStack` de go_router) : 2 onglets — Accueil,
/// Carnet — voir `app_shell.dart` pour pourquoi pas les 4 de la maquette
/// `docs/design/PetCare - Ma Vision`.
///
/// Pas d'écran "liste des animaux" (`AnimalsListScreen`, ticket 1.3) :
/// supprimé le 2026-08-15, la branche Carnet mène directement au profil
/// de l'animal courant (`selectedAnimalIdProvider`) — voir
/// `app_shell.dart` pour comment l'onglet du bas résout cette route
/// dynamiquement. `/animals/new` (création) et `/animals/:id` (profil)
/// restent deux routes soeurs, plus de racine `/animals` commune entre
/// elles.
///
/// Chaque branche garde sa propre pile de navigation (routes imbriquées
/// incluses) : ouvrir le profil d'un animal depuis l'onglet Carnet, puis
/// basculer sur Accueil et revenir sur Carnet, retrouve l'écran de
/// profil tel qu'on l'a laissé — comportement standard d'une bottom nav,
/// pas quelque chose codé à la main ici.
final appRouter = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/animals/new',
              name: 'createAnimal',
              builder: (context, state) => const CreateAnimalScreen(),
            ),
            GoRoute(
              // Route soeur de `/animals/new` ci-dessus (même niveau,
              // pas imbriquée dessous) : le segment littéral 'new' prime
              // sur ':id' dans la résolution de go_router, donc pas
              // d'ambiguïté entre /animals/new et /animals/<id> malgré
              // l'absence de racine `/animals` commune.
              path: '/animals/:id',
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
                GoRoute(
                  // Route soeur de 'vaccinations' ci-dessus, même
                  // gabarit (ticket 4.1-4.3).
                  path: 'treatments',
                  name: 'treatmentsList',
                  builder: (context, state) => TreatmentsListScreen(
                    animalId: int.parse(state.pathParameters['id']!),
                  ),
                  routes: [
                    GoRoute(
                      path: 'new',
                      name: 'createTreatment',
                      builder: (context, state) => TreatmentFormScreen(
                        animalId: int.parse(state.pathParameters['id']!),
                        // Raccourci "Antiparasitaire" de l'accueil
                        // (ticket 6.2/4.2) : préremplit le nom via un
                        // paramètre de requête plutôt qu'un flag dédié,
                        // pas de champ supplémentaire à porter partout
                        // pour un seul cas d'usage.
                        initialName: state.uri.queryParameters['name'],
                      ),
                    ),
                    GoRoute(
                      // Même remarque 'new' avant ':treatmentId' que
                      // pour /animals ci-dessus.
                      path: ':treatmentId',
                      name: 'editTreatment',
                      builder: (context, state) => TreatmentFormScreen(
                        animalId: int.parse(state.pathParameters['id']!),
                        treatmentId: int.parse(
                          state.pathParameters['treatmentId']!,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // L'écran de priming (ticket 2.2) n'a pas de route nommée : son vrai
    // point d'entrée est le formulaire vaccin (ticket 3.2), qui le
    // pousse directement via `Navigator.of(context, rootNavigator: true)`
    // pour en attendre le résultat sans passer par la coquille de nav
    // (ticket 6.0) — voir `VaccinationFormScreen`.
  ],
);
