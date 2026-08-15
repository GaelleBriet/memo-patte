import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/light_status_bar.dart';
import '../../../core/widgets/straddling_hero.dart';
import '../../../core/widgets/surface_card.dart';
import '../../vaccinations/data/vaccinations_list_provider.dart';
import '../../vaccinations/domain/vaccination_status.dart';
import '../../vaccinations/presentation/vaccination_card.dart';
import '../data/animal_provider.dart';
import '../data/animal_repository_provider.dart';
import '../data/animals_list_provider.dart';
import '../data/selected_animal_provider.dart';
import '../domain/animal_species.dart';
import 'animal_chip_selector.dart';
import 'animal_form_fields.dart';

/// Écran "Profil animal" (ticket 1.4), restylé en "Carnet de santé"
/// pour coller à `docs/design/PetCare - Ma Vision` (ticket 6.4) : hero
/// dégradé avec avatar/nom/âge, sélecteur d'animal, carte de stat, puis
/// un aperçu du carnet — pour l'instant seulement la section Vaccins
/// (épic 3 faite) ; Traitement en cours et Suivi de poids
/// apparaîtront quand les épics 4 et 5 seront faites, pas avant (pas de
/// section vide/placeholder pour une épic pas encore attaquée).
///
/// Pas de bouton "Exporter le carnet" (export PDF explicitement hors
/// scope, `06-mvp-scope.md`), contrairement à la maquette.
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

    return LightStatusBar(
      child: Scaffold(
        body: animalAsync.when(
          data: (animal) => animal == null
              ? const Center(child: Text('Animal introuvable.'))
              : _AnimalProfileBody(animalId: animalId, animal: animal),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Erreur de chargement : $error')),
        ),
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

  @override
  void initState() {
    super.initState();
    // Synchronise "l'animal courant" (ticket 6.0/6.2) sur celui dont on
    // affiche le Carnet de santé — quel que soit le chemin qui a mené
    // ici (chip, onglet Carnet de la barre du bas...), l'accueil doit
    // refléter le même animal au prochain passage. `addPostFrameCallback`
    // : modifier un provider pendant `initState`/le premier `build` de
    // cet écran est trop tôt (Riverpod l'interdit pendant un build en
    // cours ailleurs dans l'arbre).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(selectedAnimalIdProvider.notifier).state = widget.animalId;
      }
    });
  }

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
    return _editing ? _buildEditMode(context) : _buildReadMode(context);
  }

  Widget _buildReadMode(BuildContext context) {
    final animal = widget.animal;
    final vaccinationsAsync = ref.watch(
      vaccinationsListProvider(widget.animalId),
    );
    final animalsAsync = ref.watch(animalsListProvider);

    return ListView(
      // Voir le commentaire équivalent dans `home_screen.dart` : sans
      // `padding: EdgeInsets.zero`, `ListView` ajoute tout seul un
      // padding haut = hauteur de la barre de statut avant son premier
      // enfant, poussant le hero sous la barre au lieu de l'étendre
      // derrière elle (le hero gère déjà cet inset lui-même).
      padding: EdgeInsets.zero,
      children: [
        StraddlingHero(
          hero: _CarnetHero(
            animal: animal,
            onEditTap: () => setState(() => _editing = true),
          ),
          chips: AnimalChipSelector(
            animals: animalsAsync.value ?? [animal],
            selectedAnimalId: widget.animalId,
            onSelect: (id) {
              ref.read(selectedAnimalIdProvider.notifier).state = id;
              context.goNamed(
                'animalProfile',
                pathParameters: {'id': id.toString()},
              );
            },
            onAdd: () => context.goNamed('createAnimal'),
          ),
        ),
        const SizedBox(height: 24), // = overlap de StraddlingHero
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _RemindersStat(
            count: vaccinationsAsync.value == null
                ? null
                : _dueVaccinations(vaccinationsAsync.value!).length,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SurfaceCard(
            child: Column(
              children: [
                _ProfileRow(label: 'Espèce', value: animal.species.label),
                _ProfileRow(
                  label: 'Race',
                  value: animal.breed ?? 'Non renseignée',
                ),
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
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Vaccins', style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () => context.goNamed(
                  'vaccinationsList',
                  pathParameters: {'id': widget.animalId.toString()},
                ),
                child: const Text('Voir tout'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: vaccinationsAsync.when(
            data: (vaccinations) => vaccinations.isEmpty
                ? _VaccinesEmptyCta(animalId: widget.animalId)
                : Column(
                    children: [
                      for (final vaccination in _preview(vaccinations))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: VaccinationCard(
                            vaccination: vaccination,
                            onTap: () => context.goNamed(
                              'editVaccination',
                              pathParameters: {
                                'id': widget.animalId.toString(),
                                'vaccinationId': vaccination.id.toString(),
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Text('Erreur de chargement : $error'),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEditMode(BuildContext context) {
    final animal = widget.animal;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
      ),
    );
  }
}

/// Vaccins qui appellent l'attention (à venir ou en retard) — c'est ce
/// nombre-là qui compte pour la carte de stat "rappels", pas le total de
/// vaccins enregistrés.
List<Vaccination> _dueVaccinations(List<Vaccination> vaccinations) {
  return vaccinations
      .where(
        (v) =>
            VaccinationStatus.fromNextDueDate(v.nextDueDate, DateTime.now()) !=
            VaccinationStatus.upToDate,
      )
      .toList();
}

/// Aperçu du carnet : priorité aux vaccins qui appellent l'attention,
/// puis aux plus récents — plafonné à 3 lignes, la liste complète reste
/// à un tap ("Voir tout").
List<Vaccination> _preview(List<Vaccination> vaccinations) {
  final sorted = [...vaccinations]
    ..sort((a, b) {
      int rank(Vaccination v) => switch (VaccinationStatus.fromNextDueDate(
        v.nextDueDate,
        DateTime.now(),
      )) {
        VaccinationStatus.overdue => 0,
        VaccinationStatus.dueSoon => 1,
        VaccinationStatus.upToDate => 2,
      };
      final byStatus = rank(a).compareTo(rank(b));
      return byStatus != 0 ? byStatus : b.date.compareTo(a.date);
    });
  return sorted.take(3).toList();
}

/// Hero dégradé du Carnet de santé : avatar, nom, "espèce • âge", et le
/// point d'entrée vers l'édition (remplace l'ancien bouton "Modifier" en
/// bas de page).
class _CarnetHero extends StatelessWidget {
  const _CarnetHero({required this.animal, required this.onEditTap});

  final Animal animal;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    // Padding haut dynamique : le dégradé doit pouvoir peindre derrière
    // la barre de statut (edge-to-edge + couleur de la barre système
    // réglées une fois pour toute l'app dans `main.dart`) sans que
    // l'icône retour ne parte elle aussi sous les icônes système.
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      decoration: AppTheme.headerGradient,
      padding: EdgeInsets.only(top: topInset),
      // Hauteur fixe partagée avec l'accueil (`AppTheme.heroBodyHeight`)
      // — voir son commentaire. Pas de padding bas explicite : contenu
      // aligné en haut (comportement par défaut de `Column`), l'espace
      // restant sert de zone de respiration pour le chevauchement des
      // chips, comme sur l'accueil.
      child: SizedBox(
        height: AppTheme.heroBodyHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Le hero remplace l'AppBar par défaut (voir plus bas dans
              // le fichier) : le retour automatique qu'elle fournissait
              // doit être recréé ici à la main, sans quoi cet écran
              // devient un cul-de-sac de navigation.
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: 'Retour',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 16, 0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.mintPale,
                      child: Icon(
                        Icons.pets,
                        color: AppTheme.tealOnMint,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            animal.name,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            animal.birthDate == null
                                ? animal.species.label
                                : '${animal.species.label} • ${_formatAge(animal.birthDate!)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onEditTap,
                      icon: const Icon(Icons.edit, color: Colors.white),
                      tooltip: 'Modifier',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemindersStat extends StatelessWidget {
  const _RemindersStat({required this.count});

  /// `null` tant que le nombre n'est pas encore connu (chargement).
  final int? count;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          const IconChip(icon: Icons.vaccines_outlined),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count == null ? '—' : '$count',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'rappel(s)',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VaccinesEmptyCta extends StatelessWidget {
  const _VaccinesEmptyCta({required this.animalId});

  final int animalId;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: () => context.goNamed(
        'createVaccination',
        pathParameters: {'id': animalId.toString()},
      ),
      child: const Row(
        children: [
          Icon(Icons.add_circle_outline, color: AppTheme.primaryTeal),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aucun vaccin enregistré — appuie pour en ajouter un.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
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

/// "4 mois" / "1 an" / "3 ans" — pas de dépendance `intl` pour un seul
/// calcul d'âge, même choix que le reste du code (voir
/// `home_screen.dart` pour l'en-tête de date).
String _formatAge(DateTime birthDate) {
  final now = DateTime.now();
  var months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
  if (now.day < birthDate.day) months -= 1;
  if (months < 1) return 'moins d\'un mois';
  if (months < 12) return '$months mois';
  final years = months ~/ 12;
  return years > 1 ? '$years ans' : '1 an';
}
