import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/error_display.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../animals/data/animal_provider.dart';
import '../data/treatment_repository_provider.dart';
import '../data/treatments_list_provider.dart';
import 'treatment_card.dart';

/// Écran "Traitements d'un animal" (ticket 4.3), même principe que
/// `VaccinationsListScreen` — voir `TreatmentCard` pour le rendu de
/// chaque ligne, partagé avec l'aperçu inline du Carnet de santé.
///
/// Sélectionner un traitement ouvre le formulaire d'édition (ticket 4.2).
class TreatmentsListScreen extends ConsumerStatefulWidget {
  const TreatmentsListScreen({super.key, required this.animalId});

  final int animalId;

  @override
  ConsumerState<TreatmentsListScreen> createState() =>
      _TreatmentsListScreenState();
}

class _TreatmentsListScreenState extends ConsumerState<TreatmentsListScreen> {
  @override
  void initState() {
    super.initState();
    // Reprogrammation automatique des échéances passées (ticket 4.4) :
    // déclenchée ici, à la consultation de l'écran — voir le commentaire
    // de `TreatmentRepository.reconcileOverdueTreatments` pour pourquoi
    // (pas de service en arrière-plan possible). `addPostFrameCallback` :
    // ce n'est pas un `setState`, mais `ref.read` d'un repository qui va
    // lui-même écrire en base ne doit pas se faire pendant le premier
    // `build` de cet écran.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(treatmentRepositoryProvider)
            .reconcileOverdueTreatments(widget.animalId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final treatmentsAsync = ref.watch(treatmentsListProvider(widget.animalId));
    final animal = ref.watch(animalProvider(widget.animalId)).value;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          animal == null
              ? l10n.treatmentsListTitle
              : l10n.treatmentsListTitleWithName(animal.name),
        ),
      ),
      body: treatmentsAsync.when(
        data: (treatments) => treatments.isEmpty
            ? const _EmptyState()
            : _TreatmentsList(
                animalId: widget.animalId,
                treatments: treatments,
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorDisplay(
          error: error,
          stackTrace: stackTrace,
          loggerName: 'TreatmentsListScreen',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed(
          'createTreatment',
          pathParameters: {'id': widget.animalId.toString()},
        ),
        tooltip: l10n.treatmentsListAddTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TreatmentsList extends ConsumerWidget {
  const _TreatmentsList({required this.animalId, required this.treatments});

  final int animalId;
  final List<Treatment> treatments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: treatments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final treatment = treatments[index];
        return TreatmentCard(
          treatment: treatment,
          onTap: () => context.goNamed(
            'editTreatment',
            pathParameters: {
              'id': animalId.toString(),
              'treatmentId': treatment.id.toString(),
            },
          ),
          onDelete: () => ref
              .read(treatmentRepositoryProvider)
              .deleteTreatment(treatment.id),
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
            const IconChip(icon: Icons.medication_outlined, size: 56),
            const SizedBox(height: 16),
            Text(
              'Aucun traitement enregistré',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Appuie sur + pour ajouter un vermifuge ou un '
              'antiparasitaire, même fait il y a longtemps.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
