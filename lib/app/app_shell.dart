import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/animals/data/animals_list_provider.dart';
import '../features/animals/data/selected_animal_provider.dart';
import 'theme.dart';

/// Coquille de navigation persistante (ticket 6.0) : la barre du bas de
/// `docs/design/PetCare - Ma Vision`, en pilule sombre avec pastille
/// sarcelle sur l'onglet actif.
///
/// 2 onglets seulement — Accueil, Carnet — pas les 4 de la maquette :
/// Documents et Finances sont hors scope v1 (décision du 2026-08-15 dans
/// `decisions-log.md`, cohérente avec celle du 2026-08-13). Pas
/// d'onglet désactivé/« bientôt » à leur place non plus — seuls les
/// onglets qui mènent à quelque chose apparaissent.
///
/// L'onglet Carnet n'a plus de route fixe depuis la suppression de
/// l'écran "liste des animaux" (2026-08-15) : il mène directement au
/// profil de l'animal courant (`selectedAnimalIdProvider`, par défaut le
/// premier créé) — voir [_onCarnetTap]. C'est pour ça que cet onglet ne
/// passe pas par `navigationShell.goBranch` comme Accueil : `goBranch`
/// retourne à la dernière position connue de la branche, pas à une route
/// choisie dynamiquement à chaque tap.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  /// Fourni par le `StatefulShellRoute.indexedStack` du router : porte
  /// l'état de navigation propre à chaque branche (chaque onglet garde sa
  /// propre pile, indépendamment des autres — cf. doc go_router).
  final StatefulNavigationShell navigationShell;

  void _onCarnetTap(BuildContext context, WidgetRef ref) {
    final animals = ref.read(animalsListProvider).value ?? const [];
    if (animals.isEmpty) {
      // Rien à afficher : la création est la seule action sensée.
      context.goNamed('createAnimal');
      return;
    }

    // `animals` déjà trié par date de création croissante
    // (`AnimalDao.watchAll`) : `.first` = "le premier animal créé", le
    // même défaut que l'accueil (`home_screen.dart`).
    final selectedId = ref.read(selectedAnimalIdProvider) ?? animals.first.id;
    context.goNamed(
      'animalProfile',
      pathParameters: {'id': selectedId.toString()},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `SafeArea(minimum: ...)` prend le *maximum* entre la valeur donnée
    // et l'inset système du bas (zone de geste...), il ne s'additionne
    // pas à lui — sur un appareil où cet inset dépasse déjà la valeur
    // demandée, `SafeArea` ne changeait donc rien du tout, pilule
    // toujours collée malgré le réglage (signalé le 2026-08-16). Ici on
    // veut une marge *en plus* de l'inset système, systématiquement :
    // padding = inset système + marge fixe, additionnés, pas maximisés.
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset + 16),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.ink,
            borderRadius: BorderRadius.circular(999),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavIcon(
                icon: Icons.home_rounded,
                label: 'Accueil',
                selected: navigationShell.currentIndex == 0,
                // `initialLocation: true` en retapant l'onglet déjà
                // actif : revient à sa route racine plutôt que de ne
                // rien faire — comportement standard d'une bottom nav.
                onTap: () => navigationShell.goBranch(
                  0,
                  initialLocation: navigationShell.currentIndex == 0,
                ),
              ),
              _NavIcon(
                icon: Icons.pets_rounded,
                label: 'Carnet',
                selected: navigationShell.currentIndex == 1,
                onTap: () => _onCarnetTap(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryTeal : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
