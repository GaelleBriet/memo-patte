import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/due_status.dart';
import '../../../core/widgets/delete_confirmation_sheet.dart';
import '../../../core/widgets/error_display.dart';
import '../../../core/widgets/light_status_bar.dart';
import '../../../core/widgets/straddling_hero.dart';
import '../../../core/widgets/surface_card.dart';
import '../../animals/data/animals_list_provider.dart';
import '../../animals/data/selected_animal_provider.dart';
import '../../animals/presentation/animal_chip_selector.dart';
import '../../notifications/presentation/notification_permission_banner.dart';
import '../../treatments/data/treatment_repository_provider.dart';
import '../../vaccinations/data/vaccination_repository_provider.dart';
import '../data/home_reminders_provider.dart';
import '../domain/home_reminder.dart';

/// Écran d'accueil réel (ticket 6.2), conforme à
/// `docs/design/PetCare - Ma Vision`. Remplace `_HomePlaceholder`
/// (bouchon du ticket 0.3).
///
/// Centré sur un seul animal à la fois (décision du 2026-08-15) : par
/// défaut le premier créé, switch via les chips du sélecteur
/// ([AnimalChipSelector], état partagé dans [selectedAnimalIdProvider])
/// — pas de navigation, l'accueil se recompose juste sur l'animal choisi.
///
/// Contenu volontairement réduit par rapport à la maquette tant que les
/// épics dont il dépend ne sont pas toutes faites (voir
/// `home_reminders_provider.dart`) :
/// - "À faire aujourd'hui" : vaccins et traitements (épics 3 et 4,
///   toutes les deux faites) — pas de vermifuges "one-off" hors
///   traitement récurrent, ce n'est pas un concept séparé dans ce
///   schéma (voir `01-architecture.md`).
/// - Pas de carte de poids (épic 5 `weight` pas faite) ni "documents"
///   (hors scope v1).
/// - "Actions rapides" : rappel de vaccin, nouveau traitement,
///   antiparasitaire (raccourci vers un traitement pré-nommé) — pas de
///   bouton qui ne mène nulle part, même principe que la coquille de nav
///   du ticket 6.0.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsync = ref.watch(animalsListProvider);

    return LightStatusBar(
      child: Scaffold(
        body: animalsAsync.when(
          data: (animals) => animals.isEmpty
              ? const _HomeEmptyState()
              : _HomeContent(animals: animals),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => ErrorDisplay(
            error: error,
            stackTrace: stackTrace,
            loggerName: 'HomeScreen.animals',
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.animals});

  final List<Animal> animals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `animals` est déjà trié par date de création croissante
    // (`AnimalDao.watchAll`) : `.first` est bien "le premier animal
    // créé", le défaut voulu par la décision du 2026-08-15.
    final selectedId = ref.watch(selectedAnimalIdProvider) ?? animals.first.id;
    final remindersAsync = ref.watch(homeRemindersProvider(selectedId));

    return ListView(
      // `padding: EdgeInsets.zero` explicite : sans ça, `ListView` (via
      // `ScrollView.buildSlivers`) insère tout seul un padding haut égal
      // à `MediaQuery.padding.top` (la hauteur de la barre de statut)
      // avant même son premier enfant — le vrai bug derrière le hero qui
      // ne couvrait pas la barre de statut. Le hero gère déjà cet inset
      // lui-même via `MediaQuery.paddingOf` (voir `_HomeHero`) ; laisser
      // `ListView` en ajouter un deuxième par-dessus poussait tout le
      // dégradé sous la barre au lieu de l'étendre derrière elle.
      padding: EdgeInsets.zero,
      children: [
        StraddlingHero(
          hero: _HomeHero(),
          chips: AnimalChipSelector(
            animals: animals,
            selectedAnimalId: selectedId,
            onSelect: (id) =>
                ref.read(selectedAnimalIdProvider.notifier).state = id,
            onAdd: () => context.goNamed('createAnimal'),
          ),
        ),
        const SizedBox(height: 24), // = overlap de StraddlingHero
        const NotificationPermissionBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text(
            'À faire aujourd\'hui',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: remindersAsync.when(
            data: (reminders) => reminders.isEmpty
                ? const _NoReminders()
                : Column(
                    children: [
                      for (final reminder in reminders)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ReminderCard(reminder: reminder),
                        ),
                    ],
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => ErrorDisplay(
              error: error,
              stackTrace: stackTrace,
              loggerName: 'HomeScreen.reminders',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: _StatsRow(animalId: selectedId),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: _QuickActions(animalId: selectedId),
        ),
      ],
    );
  }
}

/// Bandeau dégradé "Bonjour" — les chips vivent à côté (voir
/// [StraddlingHero] dans `_HomeContent`), pas dedans : la maquette les
/// pose à cheval sur le bord inférieur du hero, pas entièrement dessus
/// (ajusté le 2026-08-15, la première version les mettait dans le hero).
class _HomeHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Padding haut dynamique (pas une valeur fixe) : le dégradé doit
    // pouvoir peindre derrière la barre de statut (edge-to-edge +
    // couleur de la barre système réglées une fois pour toute l'app
    // dans `main.dart`, pas ici) sans que le *contenu* du hero
    // ("Bonjour"...) ne parte lui aussi sous les icônes système.
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      decoration: AppTheme.headerGradient,
      padding: EdgeInsets.only(top: topInset),
      // Hauteur fixe partagée avec le Carnet de santé
      // (`AppTheme.heroBodyHeight`) plutôt que déduite du contenu : pas
      // de padding bas explicite ici, l'espace restant sous le texte
      // (contenu aligné en haut, comportement par défaut de `Column`)
      // sert de zone de respiration pour le chevauchement des chips.
      child: SizedBox(
        height: AppTheme.heroBodyHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatToday(),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                'Bonjour',
                style: Theme.of(context).textTheme.headlineLarge
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard({required this.reminder});

  final HomeReminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = reminder.status == DueStatus.overdue
        ? AppTheme.alertRed
        : AppTheme.sandAmber;

    // Route nommée + nom du paramètre d'id selon la source du rappel —
    // vaccin ou traitement, voir [ReminderKind].
    final (routeName, idParam) = switch (reminder.kind) {
      ReminderKind.vaccination => ('editVaccination', 'vaccinationId'),
      ReminderKind.treatment => ('editTreatment', 'treatmentId'),
    };

    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => context.goNamed(
        routeName,
        pathParameters: {
          'id': reminder.animalId.toString(),
          idParam: reminder.sourceId.toString(),
        },
      ),
      // Appui long → suppression, même feuille de confirmation que
      // `VaccinationCard`/`TreatmentCard` (`delete_confirmation_sheet.dart`)
      // — ajouté le 2026-08-17 pour que le geste soit disponible partout
      // où un rappel apparaît, pas seulement sur ses écrans dédiés.
      onLongPress: () async {
        final confirmed = await showDeleteConfirmationSheet(
          context,
          title: reminder.kind == ReminderKind.vaccination
              ? 'Supprimer ce vaccin ?'
              : 'Supprimer ce traitement ?',
          message:
              '"${reminder.detail}" sera définitivement supprimé, ainsi '
              'que son rappel programmé.',
        );
        if (!confirmed) return;
        switch (reminder.kind) {
          case ReminderKind.vaccination:
            await ref
                .read(vaccinationRepositoryProvider)
                .deleteVaccination(reminder.sourceId);
            break;
          case ReminderKind.treatment:
            await ref
                .read(treatmentRepositoryProvider)
                .deleteTreatment(reminder.sourceId);
            break;
        }
      },
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reminder.detail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Heure de rappel (traitement à fréquence quotidienne
          // uniquement, voir `HomeReminder.reminderTimeLabel`) — ajouté
          // le 2026-08-17.
          if (reminder.reminderTimeLabel != null) ...[
            const SizedBox(width: 8),
            _ReminderTimePill(label: reminder.reminderTimeLabel!),
          ],
        ],
      ),
    );
  }
}

/// Pastille "08:00" à droite d'une carte de rappel — mêmes teintes que
/// [IconChip] (fond menthe, texte sarcelle foncé) pour rester dans le
/// même vocabulaire visuel que le reste de l'accueil.
class _ReminderTimePill extends StatelessWidget {
  const _ReminderTimePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.mintPale,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 12, color: AppTheme.tealOnMint),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.tealOnMint,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoReminders extends StatelessWidget {
  const _NoReminders();

  @override
  Widget build(BuildContext context) {
    return const SurfaceCard(
      child: Text(
        'Rien à signaler pour l\'instant — tous les rappels sont à jour.',
        style: TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }
}

/// Une seule carte de stat pour l'instant (nombre de rappels de l'animal
/// affiché) — voir le commentaire de classe de [HomeScreen] pour
/// pourquoi poids/documents n'y sont pas encore.
class _StatsRow extends ConsumerWidget {
  const _StatsRow({required this.animalId});

  final int animalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(homeRemindersProvider(animalId)).value?.length ?? 0;
    return SurfaceCard(
      child: Row(
        children: [
          const IconChip(icon: Icons.vaccines_outlined),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
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

/// 3 cartes compactes en ligne (icône au-dessus du libellé), comme sur
/// la maquette — pas la pleine largeur empilée du premier rendu (ticket
/// 6.2), qui ne passait plus à l'échelle une fois "Nouveau traitement"
/// et "Antiparasitaire" ajoutés (ticket 4.2).
///
/// "Antiparasitaire" mène au même formulaire que "Nouveau traitement",
/// juste avec le nom pré-rempli — pas un type de traitement distinct
/// dans le modèle (`treatment_table.dart` n'a qu'un `name` libre, comme
/// les vaccins), seulement un raccourci de saisie.
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.animalId});

  final int animalId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions rapides', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        // `IntrinsicHeight` : les 3 cartes doivent faire la même hauteur
        // même si leur libellé ne retourne pas à la ligne au même
        // endroit ("Antiparasitaire", un seul mot, tient plus souvent
        // sur une ligne que "Nouveau traitement"/"Rappel de vaccin").
        // Sans ça, chaque `SurfaceCard` se dimensionne à son contenu
        // (`Column` en `mainAxisSize.min`) indépendamment des deux
        // autres — bug remonté le 2026-08-17.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.medication_outlined,
                  label: 'Nouveau traitement',
                  onTap: () => context.goNamed(
                    'createTreatment',
                    pathParameters: {'id': animalId.toString()},
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.vaccines_outlined,
                  label: 'Rappel de vaccin',
                  onTap: () => context.goNamed(
                    'createVaccination',
                    pathParameters: {'id': animalId.toString()},
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.pest_control_outlined,
                  label: 'Antiparasitaire',
                  onTap: () => context.goNamed(
                    'createTreatment',
                    pathParameters: {'id': animalId.toString()},
                    queryParameters: const {'name': 'Antiparasitaire'},
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconChip(icon: icon),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// État vide (ticket 6.3) : aucun animal créé.
class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Column(
      children: [
        Container(
          decoration: AppTheme.headerGradient,
          padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 32),
          width: double.infinity,
          child: const Text(
            'Bonjour',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const IconChip(icon: Icons.pets, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Bienvenue sur MémoPatte',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crée le profil de ton premier compagnon pour '
                    'commencer à suivre ses rappels.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.goNamed('createAnimal'),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer un profil animal'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const _weekdays = [
  'Lundi',
  'Mardi',
  'Mercredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche',
];

const _months = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

/// Pas de dépendance `intl` pour un seul en-tête de date : même choix que
/// le reste du code (dates formatées à la main, ex.
/// `vaccination_form_screen.dart`).
String _formatToday() {
  final now = DateTime.now();
  return '${_weekdays[now.weekday - 1]} ${now.day} ${_months[now.month - 1]}';
}
