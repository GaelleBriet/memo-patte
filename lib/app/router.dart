import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/animals/presentation/create_animal_screen.dart';

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
          path: 'animals/new',
          name: 'createAnimal',
          builder: (context, state) => const CreateAnimalScreen(),
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
      appBar: AppBar(title: const Text('MémoPatte')),
      body: const Center(child: Text('Écran d\'accueil à venir')),
      // Point d'entrée temporaire vers l'écran de création de profil
      // (ticket 1.2) pour pouvoir le tester en conditions réelles tant que
      // le vrai écran d'accueil (ticket 6.2) et l'écran liste (ticket 1.3)
      // n'existent pas encore. À retirer quand l'un des deux le remplace.
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed('createAnimal'),
        tooltip: 'Créer un profil animal',
        child: const Icon(Icons.add),
      ),
    );
  }
}
