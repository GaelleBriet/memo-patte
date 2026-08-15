import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../core/widgets/surface_card.dart';
import '../data/animals_list_provider.dart';
import '../domain/animal_species.dart';

/// Écran "Liste des animaux" (ticket 1.3), au style carte de
/// `docs/design/PetCare - Ma Vision` : une carte blanche arrondie par
/// animal, avatar sur pastille menthe.
///
/// Sélectionner un animal ouvre son profil (lecture/édition, ticket 1.4).
class AnimalsListScreen extends ConsumerWidget {
  const AnimalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsync = ref.watch(animalsListProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: Text('Mes animaux')),
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
      padding: const EdgeInsets.all(16),
      itemCount: animals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final animal = animals[index];
        return SurfaceCard(
          onTap: () => context.goNamed(
            'animalProfile',
            pathParameters: {'id': animal.id.toString()},
          ),
          child: Row(
            children: [
              const IconChip(icon: Icons.pets),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      animal.species.label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
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
            const IconChip(icon: Icons.pets, size: 56),
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
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
