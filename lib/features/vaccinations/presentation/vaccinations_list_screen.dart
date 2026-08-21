import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/error_display.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../core/widgets/surface_card.dart';
import '../../animals/data/animal_provider.dart';
import '../data/vaccination_repository_provider.dart';
import '../data/vaccinations_list_provider.dart';
import 'vaccination_card.dart';

/// Écran "Vaccins d'un animal" (ticket 3.3), avec statut visuel par
/// vaccin — voir `VaccinationCard` pour le rendu de chaque ligne, partagé
/// avec l'aperçu inline du Carnet de santé (ticket 6.4).
///
/// Sélectionner un vaccin ouvre le formulaire d'édition (ticket 3.2).
class VaccinationsListScreen extends ConsumerWidget {
  const VaccinationsListScreen({super.key, required this.animalId});

  final int animalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccinationsAsync = ref.watch(vaccinationsListProvider(animalId));
    final animal = ref.watch(animalProvider(animalId)).value;

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(animal == null ? 'Vaccins' : 'Vaccins de ${animal.name}'),
      ),
      body: vaccinationsAsync.when(
        data: (vaccinations) => vaccinations.isEmpty
            ? const _EmptyState()
            : _VaccinationsList(animalId: animalId, vaccinations: vaccinations),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorDisplay(
          error: error,
          stackTrace: stackTrace,
          loggerName: 'VaccinationsListScreen',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed(
          'createVaccination',
          pathParameters: {'id': animalId.toString()},
        ),
        tooltip: 'Ajouter un vaccin',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _VaccinationsList extends ConsumerWidget {
  const _VaccinationsList({required this.animalId, required this.vaccinations});

  final int animalId;
  final List<Vaccination> vaccinations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vaccinations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final vaccination = vaccinations[index];
        return VaccinationCard(
          vaccination: vaccination,
          onTap: () => context.goNamed(
            'editVaccination',
            pathParameters: {
              'id': animalId.toString(),
              'vaccinationId': vaccination.id.toString(),
            },
          ),
          onDelete: () => ref
              .read(vaccinationRepositoryProvider)
              .deleteVaccination(vaccination.id),
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
            const IconChip(icon: Icons.vaccines_outlined, size: 56),
            const SizedBox(height: 16),
            Text(
              'Aucun vaccin enregistré',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Appuie sur + pour ajouter un vaccin, même fait il y a '
              'longtemps.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
