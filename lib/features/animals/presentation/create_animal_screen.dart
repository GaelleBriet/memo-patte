import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      final id = await ref
          .read(animalRepositoryProvider)
          .createAnimal(
            name: values.name,
            species: values.species,
            breed: values.breed,
            birthDate: values.birthDate,
            initialWeightKg: values.initialWeightKg,
          );
      if (mounted) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        } else {
          // Premier animal créé (aucune page précédente à laquelle
          // revenir dans la branche Carnet — même cause que le bug du
          // bouton retour de `AnimalProfileScreen` : `/animals/new` est
          // une route soeur de `/animals/:id`, pas imbriquée dessous,
          // voir `router.dart`). Atteint ici via `AppShell._onCarnetTap`
          // ou `_HomeEmptyState` quand aucun animal n'existe encore : un
          // `pop()` nu plantait sur un écran noir. Direction le profil
          // qui vient d'être créé plutôt qu'un retour dans le vide.
          context.goNamed('animalProfile', pathParameters: {'id': '$id'});
        }
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
