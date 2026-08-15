import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../core/widgets/surface_card.dart';
import '../../animals/data/animal_provider.dart';
import '../data/vaccinations_list_provider.dart';
import '../domain/vaccination_status.dart';

/// Écran "Vaccins d'un animal" (ticket 3.3), avec statut visuel par
/// vaccin (à jour / à venir / en retard — voir [VaccinationStatus]).
///
/// Style : cartes de la section "Vaccins" du Carnet de santé de
/// `docs/design/PetCare - Ma Vision` — barre d'accent 4 px colorée par
/// statut à gauche, pilule d'action ou coche à droite.
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
        error: (error, stackTrace) =>
            Center(child: Text('Erreur de chargement : $error')),
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

class _VaccinationsList extends StatelessWidget {
  const _VaccinationsList({required this.animalId, required this.vaccinations});

  final int animalId;
  final List<Vaccination> vaccinations;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vaccinations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final vaccination = vaccinations[index];
        final status = VaccinationStatus.fromNextDueDate(
          vaccination.nextDueDate,
          DateTime.now(),
        );
        return SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          onTap: () => context.goNamed(
            'editVaccination',
            pathParameters: {
              'id': animalId.toString(),
              'vaccinationId': vaccination.id.toString(),
            },
          ),
          child: Row(
            children: [
              _StatusAccentBar(status: status),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaccination.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vaccination.nextDueDate == null
                          ? 'Fait le ${_formatDate(vaccination.date)}'
                          : 'Fait le ${_formatDate(vaccination.date)} — '
                                'échéance le '
                                '${_formatDate(vaccination.nextDueDate!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusTrailing(status: status),
            ],
          ),
        );
      },
    );
  }
}

/// Barre verticale d'accent du design (4 px de large, coins arrondis),
/// colorée par statut.
class _StatusAccentBar extends StatelessWidget {
  const _StatusAccentBar({required this.status});

  final VaccinationStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 36,
      decoration: BoxDecoration(
        color: status.accentColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Côté droit de la carte, comme dans le design : pilule pleine quand le
/// statut appelle l'attention ("En retard", "À venir"), simple coche
/// sarcelle quand tout est à jour. Toujours libellé + couleur (ou icône
/// + libellé sémantique), jamais la couleur seule — lisible en cas de
/// daltonisme, la passe d'accessibilité du ticket 9.3 n'aura rien à
/// reprendre ici.
class _StatusTrailing extends StatelessWidget {
  const _StatusTrailing({required this.status});

  final VaccinationStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == VaccinationStatus.upToDate) {
      return Semantics(
        label: status.label,
        child: const Icon(Icons.check_circle, color: AppTheme.primaryTeal),
      );
    }

    final onAccent = switch (status) {
      // Rouge foncé : texte blanc. Sable ambré, clair : texte encre.
      VaccinationStatus.overdue => Colors.white,
      _ => AppTheme.ink,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.accentColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: onAccent,
        ),
      ),
    );
  }
}

extension on VaccinationStatus {
  Color get accentColor => switch (this) {
    VaccinationStatus.upToDate => AppTheme.validTeal,
    VaccinationStatus.dueSoon => AppTheme.sandAmber,
    VaccinationStatus.overdue => AppTheme.alertRed,
  };
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

String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
