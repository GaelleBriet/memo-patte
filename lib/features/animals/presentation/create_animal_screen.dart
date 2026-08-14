import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/animal_repository_provider.dart';
import '../domain/animal_species.dart';

/// Écran "Créer un profil animal" (ticket 1.2).
///
/// Seuls le nom et l'espèce sont obligatoires (cohérent avec le modèle de
/// données du ticket 1.1) : race, date de naissance et poids initial
/// restent facultatifs, un propriétaire d'animal adopté/trouvé ne les
/// connaît pas toujours (différenciant "saisie rapide",
/// `docs/product/04-differenciation.md`).
///
/// Pas de sélection de photo dans ce ticket : le champ `photoPath` du
/// modèle reste facultatif et non renseigné pour l'instant — ajouter un
/// sélecteur d'image est un morceau à part (nouvelle dépendance,
/// permissions plateforme), hors du scope "formulaire + validation" de ce
/// ticket. À trancher séparément si besoin.
class CreateAnimalScreen extends ConsumerStatefulWidget {
  const CreateAnimalScreen({super.key});

  @override
  ConsumerState<CreateAnimalScreen> createState() => _CreateAnimalScreenState();
}

class _CreateAnimalScreenState extends ConsumerState<CreateAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();

  AnimalSpecies? _species;
  DateTime? _birthDate;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(now.year - 40),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _submit() async {
    // Validation manuelle en plus de celle du Form : la sélection
    // d'espèce n'est pas un TextFormField, elle n'est donc pas couverte
    // par `_formKey.currentState.validate()`.
    if (_species == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choisis une espèce.')));
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _submitting = true);
    try {
      final weightText = _weightController.text.trim();
      await ref
          .read(animalRepositoryProvider)
          .createAnimal(
            name: _nameController.text.trim(),
            species: _species!,
            breed: _breedController.text.trim().isEmpty
                ? null
                : _breedController.text.trim(),
            birthDate: _birthDate,
            initialWeightKg: weightText.isEmpty
                ? null
                : double.parse(weightText.replaceAll(',', '.')),
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un profil animal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom *'),
              textCapitalization: TextCapitalization.words,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Le nom est obligatoire.'
                  : null,
            ),
            const SizedBox(height: 16),
            Text('Espèce *', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<AnimalSpecies>(
              segments: [
                for (final species in AnimalSpecies.values)
                  ButtonSegment(
                    value: species,
                    label: Text(species.label),
                    icon: const Icon(Icons.pets),
                  ),
              ],
              selected: _species == null ? const {} : {_species!},
              emptySelectionAllowed: true,
              onSelectionChanged: (selection) {
                setState(() => _species = selection.firstOrNull);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _breedController,
              decoration: const InputDecoration(labelText: 'Race (facultatif)'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Poids initial en kg (facultatif)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final parsed = double.tryParse(
                  value.trim().replaceAll(',', '.'),
                );
                if (parsed == null || parsed <= 0) {
                  return 'Poids invalide.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date de naissance (facultatif)'),
              subtitle: Text(
                _birthDate == null
                    ? 'Non renseignée'
                    : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickBirthDate,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Créer le profil'),
            ),
          ],
        ),
      ),
    );
  }
}
