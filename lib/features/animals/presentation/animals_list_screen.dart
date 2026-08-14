import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../data/animals_list_provider.dart';
import '../domain/animal_species.dart';

/// Écran "Liste des animaux" (ticket 1.3).
///
/// Sélectionner un animal n'ouvre pas encore de vrai profil — l'écran
/// "Profil animal" (lecture/édition) arrive au ticket 1.4. En attendant,
/// le tap affiche juste une confirmation visuelle plutôt que de router
/// vers un écran qui n'existe pas, pour garder l'app entièrement
/// fonctionnelle à chaque ticket (pas d'état intermédiaire cassé).
class AnimalsListScreen extends ConsumerWidget {
  const AnimalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsync = ref.watch(animalsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes animaux')),
      body: animalsAsync.when(
        data: (animals) => animals.isEmpty
            ? const _EmptyState()
            : _AnimalsList(animals: animals),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Erreur de chargement : $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed('createAnimal'),
        tooltip: 'Créer un profil animal',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AnimalsList extends StatelessWidget {
  const _AnimalsList({required this.animals});

  final List<Animal> animals;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: animals.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final animal = animals[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.pets)),
          title: Text(animal.name),
          subtitle: Text(animal.species.label),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil détaillé à venir (ticket 1.4).'),
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pets, size: 48),
            const SizedBox(height: 16),
            Text(
              'Aucun animal pour l\'instant',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Appuie sur + pour créer le profil de ton premier compagnon.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
