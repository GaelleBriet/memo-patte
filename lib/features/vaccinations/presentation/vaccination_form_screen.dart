// `show Value` : seul le wrapper de champ nullable de Drift est utile ici
// (pour `copyWith(nextDueDate: ...)`), et l'import complet ferait entrer
// le `Column` de Drift en collision avec celui de Flutter.
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/error_display.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../notifications/data/first_reminder_source.dart';
import '../../notifications/data/notification_permission_provider.dart';
import '../../notifications/presentation/notification_priming_screen.dart';
import '../data/vaccination_provider.dart';
import '../data/vaccination_repository_provider.dart';

/// Formulaire ajout/édition d'un vaccin (ticket 3.2).
///
/// [vaccinationId] absent = création, présent = édition du vaccin
/// existant. La date d'administration peut être antérieure à aujourd'hui
/// — saisie rétroactive, pain point identifié
/// (`docs/product/03-pain-points.md`).
///
/// C'est aussi ici que l'écran de priming (ticket 2.2) trouve son vrai
/// point d'entrée : juste avant la création du *premier* vaccin (décision
/// du 2026-08-14 dans `decisions-log.md`), voir [_VaccinationFormBodyState._submit].
class VaccinationFormScreen extends ConsumerWidget {
  const VaccinationFormScreen({
    super.key,
    required this.animalId,
    this.vaccinationId,
  });

  final int animalId;
  final int? vaccinationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccinationId = this.vaccinationId;
    if (vaccinationId == null) {
      return _VaccinationFormScaffold(animalId: animalId, vaccination: null);
    }

    final vaccinationAsync = ref.watch(vaccinationProvider(vaccinationId));
    return vaccinationAsync.when(
      data: (vaccination) => vaccination == null
          ? Scaffold(
              appBar: const GradientAppBar(title: Text('Modifier le vaccin')),
              body: const Center(child: Text('Vaccin introuvable.')),
            )
          : _VaccinationFormScaffold(
              animalId: animalId,
              vaccination: vaccination,
            ),
      loading: () => Scaffold(
        appBar: const GradientAppBar(title: Text('Modifier le vaccin')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: const GradientAppBar(title: Text('Modifier le vaccin')),
        body: ErrorDisplay(
          error: error,
          stackTrace: stackTrace,
          loggerName: 'VaccinationFormScreen.vaccination',
        ),
      ),
    );
  }
}

class _VaccinationFormScaffold extends ConsumerStatefulWidget {
  const _VaccinationFormScaffold({
    required this.animalId,
    required this.vaccination,
  });

  final int animalId;

  /// `null` en création.
  final Vaccination? vaccination;

  @override
  ConsumerState<_VaccinationFormScaffold> createState() =>
      _VaccinationFormBodyState();
}

class _VaccinationFormBodyState
    extends ConsumerState<_VaccinationFormScaffold> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.vaccination?.name ?? '',
  );
  late DateTime _date = widget.vaccination?.date ?? DateTime.now();
  late DateTime? _nextDueDate = widget.vaccination?.nextDueDate;
  bool _submitting = false;

  bool get _isEditing => widget.vaccination != null;

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
      // Pas de date d'administration future : un vaccin pas encore fait
      // n'a rien à faire dans le carnet (la saisie rétroactive, elle, est
      // le cas d'usage à couvrir).
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickNextDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate ?? now,
      // Échéance passée autorisée : saisir rétroactivement un vaccin déjà
      // en retard est précisément ce que le statut visuel (ticket 3.3)
      // doit refléter.
      firstDate: DateTime(now.year - 40),
      lastDate: DateTime(now.year + 40),
    );
    if (picked != null) {
      setState(() => _nextDueDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      final repository = ref.read(vaccinationRepositoryProvider);
      final vaccination = widget.vaccination;

      if (vaccination == null) {
        // Priming avant la création du *premier* vaccin ou traitement
        // (décision du 2026-08-14) : uniquement si rien n'existe encore
        // et que la permission n'est pas déjà accordée. Quoi que réponde
        // l'utilisateur (refus OS ou "Plus tard"), la création se
        // poursuit — l'app ne bloque jamais sur cette permission ; en cas
        // de refus, le bandeau de l'accueil (ticket 2.3) prend le relais.
        if (await isFirstReminderSource(ref)) {
          final granted = await ref.read(
            notificationPermissionStatusProvider.future,
          );
          if (!granted && mounted) {
            // `rootNavigator: true` : ce formulaire vit dans la pile
            // interne de la branche "Carnet" de la coquille de nav
            // (ticket 6.0) — un push "normal" resterait sous la bottom
            // nav bar. Ici on veut un écran plein cadre, au-dessus de
            // toute la coquille.
            await Navigator.of(context, rootNavigator: true).push<bool>(
              MaterialPageRoute(
                builder: (_) => const NotificationPrimingScreen(),
              ),
            );
          }
        }

        await repository.createVaccination(
          animalId: widget.animalId,
          name: _nameController.text.trim(),
          date: _date,
          nextDueDate: _nextDueDate,
        );
      } else {
        await repository.updateVaccination(
          vaccination.copyWith(
            name: _nameController.text.trim(),
            date: _date,
            nextDueDate: Value(_nextDueDate),
          ),
        );
        ref.invalidate(vaccinationProvider(vaccination.id));
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
        title: Text(_isEditing ? 'Modifier le vaccin' : 'Ajouter un vaccin'),
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
                  labelText: 'Nom du vaccin *',
                  hintText: 'Rage, CHPPiL...',
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Le nom du vaccin est obligatoire.'
                    : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date du vaccin *'),
                subtitle: Text(_formatDate(_date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Prochaine échéance (facultatif)'),
                subtitle: Text(
                  _nextDueDate == null
                      ? 'Non renseignée'
                      : _formatDate(_nextDueDate!),
                ),
                trailing: _nextDueDate == null
                    ? const Icon(Icons.calendar_today)
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Effacer l\'échéance',
                        onPressed: () => setState(() => _nextDueDate = null),
                      ),
                onTap: _pickNextDueDate,
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
                    : Text(_isEditing ? 'Enregistrer' : 'Ajouter le vaccin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
