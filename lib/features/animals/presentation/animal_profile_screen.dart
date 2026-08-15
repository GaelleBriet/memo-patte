import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/animal_provider.dart';
import '../data/animal_repository_provider.dart';
import '../domain/animal_species.dart';
import 'animal_form_fields.dart';

/// Écran "Profil animal" — lecture puis édition (ticket 1.4).
///
/// Pas de suppression de profil dans ce ticket : le texte de `02-tickets-v1.md`
/// ne mentionne que "lecture + édition", la suppression est laissée de
/// côté volontairement plutôt qu'ajoutée par anticipation.
class AnimalProfileScreen extends ConsumerWidget {
  const AnimalProfileScreen({super.key, required this.animalId});

  final int animalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalAsync = ref.watch(animalProvider(animalId));

    return Scaffold(
      appBar: AppBar(title: const Text('Profil animal')),
      body: animalAsync.when(
        data: (animal) => animal == null
            ? const Center(child: Text('Animal introuvable.'))
            : _AnimalProfileBody(animalId: animalId, animal: animal),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Erreur de chargement : $error')),
      ),
    );
  }
}

class _AnimalProfileBody extends ConsumerStatefulWidget {
  const _AnimalProfileBody({required this.animalId, required this.animal});

  final int animalId;
  final Animal animal;

  @override
  ConsumerState<_AnimalProfileBody> createState() => _AnimalProfileBodyState();
}

class _AnimalProfileBodyState extends ConsumerState<_AnimalProfileBody> {
  final _formKey = GlobalKey<FormState>();
  final _fieldsKey = GlobalKey<AnimalFormFieldsState>();
  bool _editing = false;
  bool _submitting = false;

  Future<void> _save() async {
    final values = _fieldsKey.currentState?.validateAndGetValues();
    if (values == null) return;

    setState(() => _submitting = true);
    try {
      final updated = Animal(
        id: widget.animal.id,
        name: values.name,
        species: values.species,
        breed: values.breed,
        birthDate: values.birthDate,
        initialWeightKg: values.initialWeightKg,
        createdAt: widget.animal.createdAt,
      );
      await ref.read(animalRepositoryProvider).updateAnimal(updated);
      ref.invalidate(animalProvider(widget.animalId));
      if (mounted) {
        setState(() => _editing = false);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _editing ? _buildEditMode(context) : _buildReadMode(context),
    );
  }

  Widget _buildReadMode(BuildContext context) {
    final animal = widget.animal;
    return ListView(
      children: [
        Text(animal.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        _ProfileRow(label: 'Espèce', value: animal.species.label),
        _ProfileRow(label: 'Race', value: animal.breed ?? 'Non renseignée'),
        _ProfileRow(
          label: 'Date de naissance',
          value: animal.birthDate == null
              ? 'Non renseignée'
              : '${animal.birthDate!.day}/${animal.birthDate!.month}/${animal.birthDate!.year}',
        ),
        _ProfileRow(
          label: 'Poids initial',
          value: animal.initialWeightKg == null
              ? 'Non renseigné'
              : '${animal.initialWeightKg} kg',
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => setState(() => _editing = true),
          icon: const Icon(Icons.edit),
          label: const Text('Modifier'),
        ),
      ],
    );
  }

  Widget _buildEditMode(BuildContext context) {
    final animal = widget.animal;
    return SingleChildScrollView(
      child: Column(
        children: [
          AnimalFormFields(
            key: _fieldsKey,
            formKey: _formKey,
            initialName: animal.name,
            initialSpecies: animal.species,
            initialBreed: animal.breed,
            initialBirthDate: animal.birthDate,
            initialWeightKg: animal.initialWeightKg,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _submitting
                      ? null
                      : () => setState(() => _editing = false),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _submitting ? null : _save,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
