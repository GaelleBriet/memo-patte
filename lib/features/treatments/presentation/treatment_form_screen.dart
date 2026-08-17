import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../notifications/data/first_reminder_source.dart';
import '../../notifications/data/notification_permission_provider.dart';
import '../../notifications/presentation/notification_priming_screen.dart';
import '../data/treatment_provider.dart';
import '../data/treatment_repository_provider.dart';
import '../domain/treatment_frequency.dart';

/// Formulaire ajout/édition d'un traitement (ticket 4.2). Même principe
/// que `VaccinationFormScreen`, avec la fréquence récurrente à la place
/// de la prochaine échéance (calculée, pas saisie — voir
/// `treatment_table.dart`).
///
/// [treatmentId] absent = création, présent = édition. La date de
/// dernière administration peut être antérieure à aujourd'hui — même
/// pain point identifié que pour les vaccins
/// (`docs/product/03-pain-points.md`).
///
/// [initialName] préremplit le nom à la création (utilisé par le
/// raccourci "Antiparasitaire" de l'accueil, ticket 6.2/4.2) ; ignoré en
/// édition.
///
/// Comme `VaccinationFormScreen`, c'est ici que l'écran de priming
/// (ticket 2.2) peut se déclencher — voir
/// [_TreatmentFormBodyState._submit] et `first_reminder_source.dart`.
class TreatmentFormScreen extends ConsumerWidget {
  const TreatmentFormScreen({
    super.key,
    required this.animalId,
    this.treatmentId,
    this.initialName,
  });

  final int animalId;
  final int? treatmentId;
  final String? initialName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treatmentId = this.treatmentId;
    if (treatmentId == null) {
      return _TreatmentFormScaffold(
        animalId: animalId,
        treatment: null,
        initialName: initialName,
      );
    }

    final treatmentAsync = ref.watch(treatmentProvider(treatmentId));
    return treatmentAsync.when(
      data: (treatment) => treatment == null
          ? Scaffold(
              appBar: const GradientAppBar(
                title: Text('Modifier le traitement'),
              ),
              body: const Center(child: Text('Traitement introuvable.')),
            )
          : _TreatmentFormScaffold(animalId: animalId, treatment: treatment),
      loading: () => Scaffold(
        appBar: const GradientAppBar(title: Text('Modifier le traitement')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: const GradientAppBar(title: Text('Modifier le traitement')),
        body: Center(child: Text('Erreur de chargement : $error')),
      ),
    );
  }
}

class _TreatmentFormScaffold extends ConsumerStatefulWidget {
  const _TreatmentFormScaffold({
    required this.animalId,
    required this.treatment,
    this.initialName,
  });

  final int animalId;

  /// `null` en création.
  final Treatment? treatment;
  final String? initialName;

  @override
  ConsumerState<_TreatmentFormScaffold> createState() =>
      _TreatmentFormBodyState();
}

class _TreatmentFormBodyState extends ConsumerState<_TreatmentFormScaffold> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.treatment?.name ?? widget.initialName ?? '',
  );
  late DateTime _date = widget.treatment?.date ?? DateTime.now();
  late TreatmentFrequency _frequency =
      widget.treatment?.frequency ?? TreatmentFrequency.monthly;
  bool _submitting = false;

  bool get _isEditing => widget.treatment != null;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 40),
      // Pas de date d'administration future : même raisonnement que
      // `VaccinationFormScreen` — la saisie rétroactive est le cas
      // d'usage à couvrir, pas un traitement pas encore fait.
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      final repository = ref.read(treatmentRepositoryProvider);
      final treatment = widget.treatment;

      if (treatment == null) {
        // Priming avant la création du *premier* vaccin ou traitement —
        // voir `VaccinationFormScreen._submit` pour l'explication
        // complète de cette décision, partagée via
        // `first_reminder_source.dart`.
        if (await isFirstReminderSource(ref)) {
          final granted = await ref.read(
            notificationPermissionStatusProvider.future,
          );
          if (!granted && mounted) {
            await Navigator.of(context, rootNavigator: true).push<bool>(
              MaterialPageRoute(
                builder: (_) => const NotificationPrimingScreen(),
              ),
            );
          }
        }

        await repository.createTreatment(
          animalId: widget.animalId,
          name: _nameController.text.trim(),
          date: _date,
          frequency: _frequency,
        );
      } else {
        await repository.updateTreatment(
          treatment.copyWith(
            name: _nameController.text.trim(),
            date: _date,
            frequency: _frequency,
            // Toujours recalculée à partir de date + fréquence, jamais
            // laissée telle quelle : modifier l'une ou l'autre doit
            // faire glisser la prochaine échéance en conséquence (voir
            // `treatment_table.dart`, `nextDueDate` n'est jamais saisie
            // à la main).
            nextDueDate: _frequency.nextOccurrenceAfter(_date),
          ),
        );
        ref.invalidate(treatmentProvider(treatment.id));
      }

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
      appBar: GradientAppBar(
        title: Text(
          _isEditing ? 'Modifier le traitement' : 'Ajouter un traitement',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du traitement *',
                  hintText: 'Bravecto, Vermifuge...',
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Le nom du traitement est obligatoire.'
                    : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date de la dernière administration *'),
                subtitle: Text(_formatDate(_date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Fréquence *',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TreatmentFrequency>(
                segments: [
                  for (final frequency in TreatmentFrequency.values)
                    ButtonSegment(
                      value: frequency,
                      label: Text(_shortLabel(frequency)),
                    ),
                ],
                selected: {_frequency},
                onSelectionChanged: (selection) =>
                    setState(() => _frequency = selection.first),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Prochaine échéance : '
                  '${_formatDate(_frequency.nextOccurrenceAfter(_date))}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
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
                    : Text(
                        _isEditing ? 'Enregistrer' : 'Ajouter le traitement',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Libellés compacts pour le `SegmentedButton` (4 segments côte à côte,
/// pas la place pour "Tous les 3 mois") — [TreatmentFrequencyLabel.label]
/// reste le libellé complet utilisé en lecture (`TreatmentCard`).
String _shortLabel(TreatmentFrequency frequency) => switch (frequency) {
  TreatmentFrequency.monthly => '1 mois',
  TreatmentFrequency.quarterly => '3 mois',
  TreatmentFrequency.biannual => '6 mois',
  TreatmentFrequency.annual => '1 an',
};

String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
