import 'package:go_router/go_router.dart';

import '../features/animals/presentation/animal_profile_screen.dart';
import '../features/animals/presentation/create_animal_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/treatments/presentation/treatment_form_screen.dart';
import '../features/treatments/presentation/treatments_list_screen.dart';
import '../features/vaccinations/presentation/vaccination_form_screen.dart';
import '../features/vaccinations/presentation/vaccinations_list_screen.dart';
import 'app_shell.dart';

/// Parse tolérant d'un id de route — id invalide/absent (deep link
/// cassé, URL modifiée à la main...) → `null`, jamais d'exception.
/// `int.parse(...)!` non protégé levait `FormatException` sur un id
/// malformé (écran noir, audit du 2026-08-19, issue #71 point 1.3).
int? _tryParseId(GoRouterState state, String key) =>
    int.tryParse(state.pathParameters[key] ?? '');

/// Redirige vers l'accueil si [key] ne parse pas en entier — posé sur
/// chaque route qui introduit un nouveau paramètre d'id, en plus du
/// filet de sécurité `_parseIdOrFallback` dans les builders eux-mêmes
/// (défense en profondeur : un id invalide ne doit jamais atteindre un
/// écran, mais si jamais ce garde-fou était contourné, le fallback des
/// builders évite quand même le crash).
String? _requireValidId(GoRouterState state, String key) =>
    _tryParseId(state, key) == null ? '/' : null;

/// Id à utiliser dans un builder si jamais un id invalide arrivait
/// jusque-là malgré [_requireValidId] : `-1` n'existera jamais en base,
/// ce qui retombe naturellement sur les écrans "introuvable" déjà
/// prévus pour un id valide mais absent (`AnimalProfileScreen`,
/// `TreatmentFormScreen`...) — pas besoin d'un chemin d'erreur séparé.
int _parseIdOrFallback(GoRouterState state, String key) =>
    _tryParseId(state, key) ?? -1;

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
              redirect: (context, state) => _requireValidId(state, 'id'),
              builder: (context, state) => AnimalProfileScreen(
                animalId: _parseIdOrFallback(state, 'id'),
              ),
              routes: [
                GoRoute(
                  path: 'vaccinations',
                  name: 'vaccinationsList',
                  builder: (context, state) => VaccinationsListScreen(
                    animalId: _parseIdOrFallback(state, 'id'),
                  ),
                  routes: [
                    GoRoute(
                      path: 'new',
                      name: 'createVaccination',
                      builder: (context, state) => VaccinationFormScreen(
                        animalId: _parseIdOrFallback(state, 'id'),
                      ),
                    ),
                    GoRoute(
                      // Même remarque 'new' avant ':vaccinationId' que
                      // pour /animals ci-dessus.
                      path: ':vaccinationId',
                      name: 'editVaccination',
                      redirect: (context, state) =>
                          _requireValidId(state, 'vaccinationId'),
                      builder: (context, state) => VaccinationFormScreen(
                        animalId: _parseIdOrFallback(state, 'id'),
                        vaccinationId: _parseIdOrFallback(
                          state,
                          'vaccinationId',
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
                    animalId: _parseIdOrFallback(state, 'id'),
                  ),
                  routes: [
                    GoRoute(
                      path: 'new',
                      name: 'createTreatment',
                      builder: (context, state) => TreatmentFormScreen(
                        animalId: _parseIdOrFallback(state, 'id'),
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
                      redirect: (context, state) =>
                          _requireValidId(state, 'treatmentId'),
                      builder: (context, state) => TreatmentFormScreen(
                        animalId: _parseIdOrFallback(state, 'id'),
                        treatmentId: _parseIdOrFallback(state, 'treatmentId'),
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
