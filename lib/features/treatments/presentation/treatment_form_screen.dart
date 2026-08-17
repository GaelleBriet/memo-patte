import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../notifications/data/first_reminder_source.dart';
import '../../notifications/data/notification_permission_provider.dart';
import '../../notifications/presentation/notification_priming_screen.dart';
import '../data/treatment_provider.dart';
import '../data/treatment_repository_provider.dart';
import '../domain/reminder_times.dart';
import '../domain/treatment_frequency.dart';

/// Formulaire ajout/édition d'un traitement (ticket 4.2). Même principe
/// que `VaccinationFormScreen`, avec la fréquence récurrente à la place
/// de la prochaine échéance (calculée, pas saisie — voir
/// `treatment_table.dart`).
///
/// Deux familles de fréquence, voir [TreatmentFrequency.usesReminderTimes]
/// (ajouté le 2026-08-17) : cycle long (mois/trimestre/semestre/an), où
/// seule la date de dernière administration + la fréquence comptent, ou
/// heure(s) fixe(s) par jour (médicament pris 1 ou plusieurs fois par
/// jour), où une ou plusieurs heures de rappel doivent être choisies
/// ([_reminderTimes]) — la section "Heure(s) de rappel" ne s'affiche que
/// pour la deuxième famille.
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

  /// Minutes depuis minuit, triées, sans doublon — voir
  /// `domain/reminder_times.dart`. N'a de sens que si
  /// `_frequency.usesReminderTimes` ; conservée même quand on bascule
  /// vers un cycle long (pas remise à zéro), pour ne pas perdre la
  /// saisie si l'utilisateur revient en arrière sur son choix de
  /// fréquence.
  late List<int> _reminderTimes = decodeReminderTimes(
    widget.treatment?.reminderTimes,
  );
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

  /// Fréquence [TreatmentFrequency.daily] : une seule heure, un nouveau
  /// choix remplace l'ancien plutôt que de s'ajouter (voir
  /// [_addReminderTime] pour `severalTimesDaily`, qui accumule).
  Future<void> _pickSingleReminderTime() async {
    final initial = _reminderTimes.isNotEmpty
        ? TimeOfDay(
            hour: _reminderTimes.first ~/ 60,
            minute: _reminderTimes.first % 60,
          )
        : const TimeOfDay(hour: 8, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() => _reminderTimes = [picked.hour * 60 + picked.minute]);
    }
  }

  Future<void> _addReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked == null) return;
    final minute = picked.hour * 60 + picked.minute;
    if (_reminderTimes.contains(minute)) return; // Déjà choisie.
    setState(() => _reminderTimes = ([..._reminderTimes, minute]..sort()));
  }

  void _removeReminderTime(int minute) {
    setState(
      () => _reminderTimes = _reminderTimes.where((m) => m != minute).toList(),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_frequency.usesReminderTimes && _reminderTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis au moins une heure de rappel.')),
      );
      return;
    }

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
          reminderTimes: _reminderTimes,
        );
      } else {
        await repository.updateTreatment(
          treatment.copyWith(
            name: _nameController.text.trim(),
            date: _date,
            frequency: _frequency,
            reminderTimes: Value(
              _frequency.usesReminderTimes
                  ? encodeReminderTimes(_reminderTimes)
                  : null,
            ),
            // Toujours recalculée à partir de la saisie courante, jamais
            // laissée telle quelle : modifier la date, la fréquence ou
            // les heures de rappel doit faire glisser la prochaine
            // échéance en conséquence. `TreatmentRepository.updateTreatment`
            // fait confiance à cette valeur (contrairement à
            // `notificationId`/`reminderNotificationIds`) — voir son
            // commentaire pour pourquoi (la réconciliation en dépend).
            nextDueDate: _frequency.usesReminderTimes
                ? nextReminderDateTime(_reminderTimes, DateTime.now())
                : _frequency.nextOccurrenceAfter(_date),
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
                title: Text(
                  _frequency.usesReminderTimes
                      ? 'Date de début du traitement *'
                      : 'Date de la dernière administration *',
                ),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final frequency in TreatmentFrequency.values)
                    _FrequencyChip(
                      label: _shortLabel(frequency),
                      selected: _frequency == frequency,
                      onTap: () => setState(() => _frequency = frequency),
                    ),
                ],
              ),
              if (_frequency.usesReminderTimes) ...[
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _frequency == TreatmentFrequency.daily
                        ? 'Heure de rappel *'
                        : 'Heures de rappel *',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 4),
                if (_frequency == TreatmentFrequency.daily)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _reminderTimes.isEmpty
                          ? 'Choisir une heure'
                          : formatMinuteOfDay(_reminderTimes.first),
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: _pickSingleReminderTime,
                  )
                else ...[
                  for (final minute in _reminderTimes)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time),
                      title: Text(formatMinuteOfDay(minute)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Retirer cette heure',
                        onPressed: () => _removeReminderTime(minute),
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _addReminderTime,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter une heure'),
                    ),
                  ),
                ],
                if (_reminderTimes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Prochain rappel : '
                      '${describeUpcomingReminder(nextReminderDateTime(_reminderTimes, DateTime.now()), DateTime.now())}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ] else ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Prochaine échéance : '
                    '${_formatDate(_frequency.nextOccurrenceAfter(_date))}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
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

/// Chip de sélection de fréquence — 6 options depuis le 2026-08-17
/// (ajout de `daily`/`severalTimesDaily`), trop pour un `SegmentedButton`
/// sur une largeur de téléphone (déjà cramé à 4). `Wrap` + chips maison
/// plutôt qu'un `DropdownButtonFormField` : les fréquences sont peu
/// nombreuses et se comparent d'un coup d'œil, cohérent avec le
/// différenciant "saisie rapide" (pas de menu à ouvrir). Style calqué sur
/// le thème `SegmentedButton` existant (`AppTheme.light`,
/// `segmentedButtonTheme`) pour rester visuellement cohérent malgré le
/// changement de widget.
class _FrequencyChip extends StatelessWidget {
  const _FrequencyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.primaryTeal : AppTheme.cardSurface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppTheme.primaryTeal : AppTheme.divider,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppTheme.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Libellés compacts pour les chips de fréquence — [TreatmentFrequencyLabel.label]
/// reste le libellé complet utilisé en lecture (`TreatmentCard`).
String _shortLabel(TreatmentFrequency frequency) => switch (frequency) {
  TreatmentFrequency.monthly => '1 mois',
  TreatmentFrequency.quarterly => '3 mois',
  TreatmentFrequency.biannual => '6 mois',
  TreatmentFrequency.annual => '1 an',
  TreatmentFrequency.daily => '1×/jour',
  TreatmentFrequency.severalTimesDaily => 'Plusieurs/jour',
};

String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
