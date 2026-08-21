import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../domain/animal_species.dart';

/// Valeurs saisies dans [AnimalFormFields], une fois validées.
class AnimalFormValues {
  const AnimalFormValues({
    required this.name,
    required this.species,
    this.breed,
    this.birthDate,
    this.initialWeightKg,
  });

  final String name;
  final AnimalSpecies species;
  final String? breed;
  final DateTime? birthDate;
  final double? initialWeightKg;
}

/// Champs du formulaire animal (nom, espèce, race, poids initial, date de
/// naissance), partagés entre la création (ticket 1.2) et l'édition
/// (ticket 1.4) — mêmes champs, mêmes règles de validation. Extrait ici
/// pour que les deux écrans ne divergent pas silencieusement au fil des
/// tickets suivants.
///
/// Toujours pas de sélection de photo (voir `create_animal_screen.dart`
/// pour le contexte de cette décision).
class AnimalFormFields extends StatefulWidget {
  const AnimalFormFields({
    super.key,
    required this.formKey,
    this.initialName = '',
    this.initialSpecies,
    this.initialBreed,
    this.initialBirthDate,
    this.initialWeightKg,
  });

  final GlobalKey<FormState> formKey;
  final String initialName;
  final AnimalSpecies? initialSpecies;
  final String? initialBreed;
  final DateTime? initialBirthDate;
  final double? initialWeightKg;

  @override
  State<AnimalFormFields> createState() => AnimalFormFieldsState();
}

class AnimalFormFieldsState extends State<AnimalFormFields> {
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _breedController = TextEditingController(
    text: widget.initialBreed ?? '',
  );
  late final _weightController = TextEditingController(
    text: widget.initialWeightKg?.toString() ?? '',
  );
  late AnimalSpecies? _species = widget.initialSpecies;
  late DateTime? _birthDate = widget.initialBirthDate;

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

  /// Valide le formulaire — y compris l'espèce, qui n'est pas un
  /// `TextFormField` et donc pas couverte par `Form.validate()` — et
  /// retourne les valeurs saisies, ou `null` si invalide (un message
  /// explicatif est déjà affiché à l'utilisateur dans ce cas).
  AnimalFormValues? validateAndGetValues() {
    if (_species == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.animalFormSpeciesRequired),
        ),
      );
      return null;
    }
    if (!(widget.formKey.currentState?.validate() ?? false)) {
      return null;
    }
    final weightText = _weightController.text.trim();
    return AnimalFormValues(
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: l10n.animalFormNameLabel),
            textCapitalization: TextCapitalization.words,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? l10n.animalFormNameRequired
                : null,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.animalFormSpeciesLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<AnimalSpecies>(
            segments: [
              for (final species in AnimalSpecies.values)
                ButtonSegment(
                  value: species,
                  label: Text(species.label(context)),
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
            decoration: InputDecoration(labelText: l10n.animalFormBreedLabel),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _weightController,
            decoration: InputDecoration(labelText: l10n.animalFormWeightLabel),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
              if (parsed == null || parsed <= 0) {
                return l10n.animalFormWeightInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.animalFormBirthDateLabel),
            subtitle: Text(
              _birthDate == null
                  ? l10n.animalFormBirthDateNotProvided
                  : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickBirthDate,
          ),
        ],
      ),
    );
  }
}
