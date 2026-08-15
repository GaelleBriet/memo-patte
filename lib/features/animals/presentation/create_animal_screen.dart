import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/animal_repository_provider.dart';
import 'animal_form_fields.dart';
import '../../../core/widgets/gradient_app_bar.dart';

/// Écran "Créer un profil animal" (ticket 1.2).
///
/// Les champs du formulaire (nom, espèce, race, poids initial, date de
/// naissance) sont partagés avec l'écran de profil/édition (ticket 1.4)
/// via [AnimalFormFields] — voir ce fichier pour le détail des règles de
/// validation et la décision de ne pas gérer de photo pour l'instant.
class CreateAnimalScreen extends ConsumerStatefulWidget {
  const CreateAnimalScreen({super.key});

  @override
  ConsumerState<CreateAnimalScreen> createState() => _CreateAnimalScreenState();
}

class _CreateAnimalScreenState extends ConsumerState<CreateAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fieldsKey = GlobalKey<AnimalFormFieldsState>();
  bool _submitting = false;

  Future<void> _submit() async {
    final values = _fieldsKey.currentState?.validateAndGetValues();
    if (values == null) return;

    setState(() => _submitting = true);
    try {
      await ref
          .read(animalRepositoryProvider)
          .createAnimal(
            name: values.name,
            species: values.species,
            breed: values.breed,
            birthDate: values.birthDate,
            initialWeightKg: values.initialWeightKg,
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
      appBar: const GradientAppBar(title: Text('Créer un profil animal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AnimalFormFields(key: _fieldsKey, formKey: _formKey),
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
