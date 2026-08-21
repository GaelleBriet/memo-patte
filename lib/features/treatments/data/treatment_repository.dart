import 'package:drift/drift.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show DateTimeComponents;

import '../../../core/database/app_database.dart';
import '../../../core/notifications/notification_service.dart';
import '../../animals/data/animal_dao.dart';
import '../domain/reminder_times.dart';
import '../domain/treatment_frequency.dart';
import 'treatment_dao.dart';

/// Point d'entrée métier pour les traitements (tickets 4.1 et 4.4) —
/// même rôle que `VaccinationRepository`, avec en plus le cycle de
/// rappel récurrent propre aux traitements (voir
/// [reconcileOverdueTreatments]) et, depuis le 2026-08-17, les
/// fréquences à heure(s) de rappel fixe(s)
/// (`TreatmentFrequency.daily`/`severalTimesDaily`, voir
/// [_scheduleReminderTimes]).
class TreatmentRepository {
  TreatmentRepository(this._dao, this._animalDao, this._notificationService);

  final TreatmentDao _dao;
  final AnimalDao _animalDao;
  final NotificationService _notificationService;

  /// Même principe que `VaccinationRepository.notificationIdFor`
  /// (`id * 10 + 1`) mais décalé de `+ 2` : sans ce décalage, le
  /// traitement n°1 et le vaccin n°1 partageraient le même identifiant
  /// de notification et s'annuleraient mutuellement.
  ///
  /// Réservé aux cycles longs (`frequency.usesReminderTimes == false`) :
  /// un seul rappel actif par traitement. Voir [notificationIdForSlot]
  /// pour les fréquences à heure(s) fixe(s).
  static int notificationIdFor(int treatmentId) => treatmentId * 10 + 2;

  /// Identifiant de notification pour la [slot]-ième heure de rappel
  /// d'un traitement à fréquence quotidienne (`daily`/`severalTimesDaily`,
  /// ajoutées le 2026-08-17) — ces fréquences peuvent avoir plusieurs
  /// notifications actives en même temps (une par heure choisie), donc
  /// [notificationIdFor] (un seul id par traitement) ne suffit plus.
  ///
  /// Multiplicateur x1000 (au lieu de x10 pour [notificationIdFor]) :
  /// pour des volumes de données réalistes (jusqu'à quelques milliers de
  /// lignes), cette plage ne chevauche ni celle des vaccins (`id*10+1`)
  /// ni celle des traitements à cycle long (`id*10+2`) — voir le test de
  /// non-collision.
  static int notificationIdForSlot(int treatmentId, int slot) =>
      treatmentId * 1000 + slot * 10 + 2;

  /// Même heure de déclenchement que les vaccins — voir
  /// `VaccinationRepository.notificationHour`. Ne s'applique qu'aux
  /// cycles longs : les fréquences à heure(s) fixe(s) utilisent l'heure
  /// choisie par l'utilisateur, pas celle-ci.
  static const notificationHour = 9;

  Stream<List<Treatment>> watchForAnimal(int animalId) =>
      _dao.watchForAnimal(animalId);

  /// Lecture ponctuelle — voir `TreatmentDao.getForAnimal` (déjà
  /// consommée en interne par [reconcileOverdueTreatments]). Exposée
  /// publiquement pour `AnimalRepository.deleteAnimal`, qui annule les
  /// notifications des traitements d'un animal avant sa suppression.
  Future<List<Treatment>> getForAnimal(int animalId) =>
      _dao.getForAnimal(animalId);

  Future<Treatment?> getTreatment(int id) => _dao.getById(id);

  /// Voir `VaccinationRepository.hasAnyVaccinations` — détection du
  /// "premier vaccin ou traitement" pour l'écran de priming (ticket 2.2),
  /// maintenant que l'épic 4 est la deuxième source à devoir y participer
  /// (voir `features/notifications/data/first_reminder_source.dart`).
  Future<bool> hasAnyTreatments() => _dao.hasAny();

  /// Crée le traitement — [nextDueDate] est toujours calculée ici,
  /// jamais saisie par l'utilisateur (contrairement au vaccin, cf.
  /// `treatment_table.dart`) : à partir de `date` + [frequency] pour un
  /// cycle long, ou de [reminderTimes] pour une fréquence quotidienne
  /// (voir [_computeNextDueDate]). Programme le(s) rappel(s)
  /// correspondant(s) (ticket 4.4, étendu le 2026-08-17).
  ///
  /// [reminderTimes] : heures de rappel en minutes depuis minuit,
  /// requises (au moins une) si `frequency.usesReminderTimes`, ignorées
  /// sinon.
  Future<int> createTreatment({
    required int animalId,
    required String name,
    required DateTime date,
    required TreatmentFrequency frequency,
    List<int> reminderTimes = const [],
  }) async {
    final nextDueDate = _computeNextDueDate(
      frequency: frequency,
      date: date,
      reminderTimes: reminderTimes,
    );
    final id = await _dao.insertTreatment(
      TreatmentsCompanion.insert(
        animalId: animalId,
        name: name,
        date: date,
        frequency: frequency,
        nextDueDate: nextDueDate,
        reminderTimes: Value.absentIfNull(
          frequency.usesReminderTimes
              ? encodeReminderTimes(reminderTimes)
              : null,
        ),
      ),
    );

    if (frequency.usesReminderTimes) {
      final ids = await _scheduleReminderTimes(
        treatmentId: id,
        animalId: animalId,
        name: name,
        reminderTimes: reminderTimes,
      );
      if (ids.isNotEmpty) {
        final created = await _dao.getById(id);
        await _dao.updateTreatment(
          created!
              .copyWith(reminderNotificationIds: Value(_encodeIds(ids)))
              .toCompanion(false),
        );
      }
    } else {
      final notificationId = await _scheduleIfDue(
        treatmentId: id,
        animalId: animalId,
        name: name,
        nextDueDate: nextDueDate,
      );
      if (notificationId != null) {
        final created = await _dao.getById(id);
        await _dao.updateTreatment(
          created!
              .copyWith(notificationId: Value(notificationId))
              .toCompanion(false),
        );
      }
    }
    return id;
  }

  /// Met à jour le traitement et reprogramme son/ses rappel(s) — même
  /// principe annuler-puis-reprogrammer que
  /// `VaccinationRepository.updateVaccination`, étendu aux deux
  /// mécaniques possibles (cycle long ou heure(s) fixe(s)) : les deux
  /// annulations sont faites systématiquement, la fréquence ayant pu
  /// changer de famille entre-temps (ex. mensuel → 2 fois par jour).
  ///
  /// [notificationId] et [reminderNotificationIds] portés par [treatment]
  /// sont ignorés et réécrits ici (même logique que l'ancienne version de
  /// cette méthode pour [notificationId] seul). [nextDueDate] en
  /// revanche est pris tel quel, PAS recalculé : contrairement à
  /// [createTreatment] (toujours une création "à blanc"), l'appelant
  /// peut avoir une raison précise de faire porter à [treatment] une
  /// échéance différente de "`date` + `frequency` appliqués une fois" —
  /// notamment [reconcileOverdueTreatments], qui avance `nextDueDate` de
  /// plusieurs cycles sans toucher à `date`. Recalculer ici écraserait
  /// silencieusement ce travail (bug constaté le 2026-08-17 en ajoutant
  /// les fréquences à heure(s) fixe(s) : la réconciliation multi-cycles
  /// des cycles longs cessait d'avancer `nextDueDate`). Le formulaire
  /// (`TreatmentFormScreen._submit`) calcule donc lui-même la bonne
  /// valeur avant d'appeler cette méthode, pour les deux familles de
  /// fréquence.
  Future<bool> updateTreatment(Treatment treatment) async {
    final previous = await _dao.getById(treatment.id);
    if (previous?.notificationId != null) {
      await _notificationService.cancelNotification(previous!.notificationId!);
    }
    await _cancelReminderTimes(previous?.reminderNotificationIds);

    int? notificationId;
    String? reminderNotificationIdsCsv;
    if (treatment.frequency.usesReminderTimes) {
      final ids = await _scheduleReminderTimes(
        treatmentId: treatment.id,
        animalId: treatment.animalId,
        name: treatment.name,
        reminderTimes: decodeReminderTimes(treatment.reminderTimes),
      );
      reminderNotificationIdsCsv = ids.isEmpty ? null : _encodeIds(ids);
    } else {
      notificationId = await _scheduleIfDue(
        treatmentId: treatment.id,
        animalId: treatment.animalId,
        name: treatment.name,
        nextDueDate: treatment.nextDueDate,
      );
    }

    // `toCompanion(false)` et pas `true` : même leçon que pour les
    // vaccins (ticket 1.5 à l'origine) — une édition doit pouvoir
    // repasser `notificationId`/`reminderNotificationIds` à null, pas
    // seulement "ne pas y toucher".
    return _dao.updateTreatment(
      treatment
          .copyWith(
            notificationId: Value(notificationId),
            reminderNotificationIds: Value(reminderNotificationIdsCsv),
          )
          .toCompanion(false),
    );
  }

  /// Reprogrammation automatique des traitements dont l'échéance
  /// affichée est passée (ticket 4.4, "reprogrammation automatique à
  /// chaque échéance passée"). Sans service en arrière-plan — une app
  /// mobile pure, hors scope v1 — ce recalage se fait quand l'app est
  /// ouverte / l'écran du traitement consulté, pas par un vrai cron :
  /// voir les appelants (`AnimalProfileScreen`, `TreatmentsListScreen`).
  ///
  /// Deux mécaniques, voir [TreatmentFrequency.usesReminderTimes] :
  /// - Cycle long : avance `nextDueDate` par pas de [TreatmentFrequency]
  ///   jusqu'à retomber dans le futur, et reprogramme la notification en
  ///   conséquence (comportement d'origine, inchangé).
  /// - Heure(s) fixe(s) (ajouté le 2026-08-17) : seule la date affichée
  ///   doit rattraper "maintenant" (tri de l'accueil, `TreatmentCard') —
  ///   le rappel lui-même n'a pas besoin d'être reprogrammé, il se répète
  ///   déjà nativement côté OS (`matchDateTimeComponents`, voir
  ///   [_scheduleReminderTimes]).
  Future<void> reconcileOverdueTreatments(int animalId) async {
    final now = DateTime.now();
    final current = await _dao.getForAnimal(animalId);

    for (final treatment in current) {
      if (!treatment.nextDueDate.isBefore(now)) continue;

      if (treatment.frequency.usesReminderTimes) {
        final next = nextReminderDateTime(
          decodeReminderTimes(treatment.reminderTimes),
          now,
        );
        await _dao.updateTreatment(
          treatment.copyWith(nextDueDate: next).toCompanion(false),
        );
        continue;
      }

      var next = treatment.nextDueDate;
      while (!next.isAfter(now)) {
        next = treatment.frequency.nextOccurrenceAfter(next);
      }
      await updateTreatment(treatment.copyWith(nextDueDate: next));
    }
  }

  /// Supprime le traitement (ticket "appui long" du 2026-08-17) — même
  /// principe que `VaccinationRepository.deleteVaccination` : annule
  /// d'abord le(s) rappel(s) programmé(s) s'il y en a, quelle que soit
  /// la mécanique (cycle long ou heure(s) fixe(s)).
  Future<void> deleteTreatment(int id) async {
    final treatment = await _dao.getById(id);
    if (treatment?.notificationId != null) {
      await _notificationService.cancelNotification(treatment!.notificationId!);
    }
    await _cancelReminderTimes(treatment?.reminderNotificationIds);
    await _dao.deleteTreatment(id);
  }

  /// Prochaine échéance : `date` + [frequency] pour un cycle long,
  /// prochaine heure de [reminderTimes] à partir de maintenant sinon —
  /// voir le commentaire de classe de [TreatmentFrequency] pour pourquoi
  /// ces deux calculs ne se recoupent pas.
  DateTime _computeNextDueDate({
    required TreatmentFrequency frequency,
    required DateTime date,
    required List<int> reminderTimes,
  }) {
    if (frequency.usesReminderTimes) {
      return nextReminderDateTime(reminderTimes, DateTime.now());
    }
    return frequency.nextOccurrenceAfter(date);
  }

  Future<int?> _scheduleIfDue({
    required int treatmentId,
    required int animalId,
    required String name,
    required DateTime nextDueDate,
  }) async {
    final fireAt = DateTime(
      nextDueDate.year,
      nextDueDate.month,
      nextDueDate.day,
      notificationHour,
    );
    if (!fireAt.isAfter(DateTime.now())) return null;

    final animal = await _animalDao.getById(animalId);
    final notificationId = notificationIdFor(treatmentId);
    await _notificationService.scheduleNotification(
      id: notificationId,
      title: 'Rappel de traitement',
      body:
          'Le traitement $name de ${animal?.name ?? 'ton animal'} arrive à '
          'échéance aujourd\'hui.',
      scheduledDate: fireAt,
    );
    return notificationId;
  }

  /// Programme une notification récurrente par heure de [reminderTimes]
  /// (`matchDateTimeComponents: DateTimeComponents.time`, voir
  /// `NotificationService.scheduleNotification`) — contrairement à
  /// [_scheduleIfDue], toujours programmées (une fréquence quotidienne
  /// n'a pas d'équivalent "échéance déjà passée, ne rien programmer" :
  /// il y a toujours un prochain "demain à cette heure" si l'heure
  /// d'aujourd'hui est passée). Retourne les identifiants utilisés, pour
  /// stockage dans `Treatment.reminderNotificationIds`.
  Future<List<int>> _scheduleReminderTimes({
    required int treatmentId,
    required int animalId,
    required String name,
    required List<int> reminderTimes,
  }) async {
    if (reminderTimes.isEmpty) return const [];

    final animal = await _animalDao.getById(animalId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sorted = [...reminderTimes]..sort();
    final ids = <int>[];

    for (var slot = 0; slot < sorted.length; slot++) {
      var firstFireAt = today.add(Duration(minutes: sorted[slot]));
      if (!firstFireAt.isAfter(now)) {
        firstFireAt = firstFireAt.add(const Duration(days: 1));
      }
      final id = notificationIdForSlot(treatmentId, slot);
      await _notificationService.scheduleNotification(
        id: id,
        title: 'Rappel de traitement',
        body:
            'Le traitement $name de ${animal?.name ?? 'ton animal'} est à '
            'donner maintenant.',
        scheduledDate: firstFireAt,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      ids.add(id);
    }
    return ids;
  }

  Future<void> _cancelReminderTimes(String? notificationIdsCsv) async {
    for (final id in _decodeIds(notificationIdsCsv)) {
      await _notificationService.cancelNotification(id);
    }
  }

  List<int> _decodeIds(String? csv) => (csv == null || csv.isEmpty)
      ? const []
      : csv.split(',').map(int.parse).toList();

  String _encodeIds(List<int> ids) => ids.join(',');
}
