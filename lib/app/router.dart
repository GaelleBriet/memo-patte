import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Router minimal de l'app : une seule route pour l'instant, vers un
/// écran d'accueil vide.
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
    );
  }
}
