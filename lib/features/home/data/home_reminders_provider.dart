import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/due_status.dart';
import '../../animals/data/animal_provider.dart';
import '../../treatments/data/treatments_list_provider.dart';
import '../../treatments/domain/reminder_times.dart';
import '../../vaccinations/data/vaccinations_list_provider.dart';
import '../domain/home_reminder.dart';

/// Rappels à venir/en retard d'un animal donné (ticket 6.1), vaccins et
/// traitements fusionnés dans une même liste triée par échéance — voir
/// `home_reminder.dart` pour comment [ReminderKind] les distingue au tap.
///
/// L'accueil est centré sur un seul animal à la fois depuis le
/// 2026-08-15 (chips pour switcher, plus de vue agrégée "tous les
/// animaux" en un seul écran) ; `.family` sur l'id de l'animal plutôt
/// qu'une agrégation multi-animaux comme la première version de ce
/// provider.
///
/// `Provider.family` écrit à la main plutôt qu'un `StreamProvider`
/// combiné : les trois dépendances (`animalProvider`,
/// `vaccinationsListProvider`, `treatmentsListProvider`) sont déjà
/// réactives chacune de leur côté, un simple enchaînement de
/// `ref.watch` suffit à propager leurs changements ici sans re-modéliser
/// un flux combiné à la main.
final homeRemindersProvider =
    Provider.family<AsyncValue<List<HomeReminder>>, int>((ref, animalId) {
      final animalAsync = ref.watch(animalProvider(animalId));
      if (!animalAsync.hasValue) {
        return animalAsync.hasError
            ? AsyncError(animalAsync.error!, animalAsync.stackTrace!)
            : const AsyncLoading();
      }
      final animal = animalAsync.requireValue;
      if (animal == null) return const AsyncData([]);

      final vaccinationsAsync = ref.watch(vaccinationsListProvider(animalId));
      final treatmentsAsync = ref.watch(treatmentsListProvider(animalId));
      if (!vaccinationsAsync.hasValue || !treatmentsAsync.hasValue) {
        final error = vaccinationsAsync.hasError
            ? vaccinationsAsync
            : (treatmentsAsync.hasError ? treatmentsAsync : null);
        if (error != null) {
          return AsyncError(error.error!, error.stackTrace!);
        }
        return const AsyncLoading();
      }

      final reminders = <HomeReminder>[];

      for (final vaccination in vaccinationsAsync.requireValue) {
        final dueDate = vaccination.nextDueDate;
        if (dueDate == null) continue;

        final status = DueStatus.fromNextDueDate(dueDate, DateTime.now());
        if (status == DueStatus.upToDate) continue;

        reminders.add(
          HomeReminder(
            animalId: animalId,
            animalName: animal.name,
            kind: ReminderKind.vaccination,
            sourceId: vaccination.id,
            title: 'Rappel de vaccin',
            detail: vaccination.name,
            dueDate: dueDate,
            status: status,
          ),
        );
      }

      for (final treatment in treatmentsAsync.requireValue) {
        final status = DueStatus.fromNextDueDate(
          treatment.nextDueDate,
          DateTime.now(),
        );
        if (status == DueStatus.upToDate) continue;

        reminders.add(
          HomeReminder(
            animalId: animalId,
            animalName: animal.name,
            kind: ReminderKind.treatment,
            sourceId: treatment.id,
            title: 'Rappel de traitement',
            detail: treatment.name,
            dueDate: treatment.nextDueDate,
            status: status,
            reminderTimeLabel: treatment.frequency.usesReminderTimes
                ? formatMinuteOfDay(
                    treatment.nextDueDate.hour * 60 +
                        treatment.nextDueDate.minute,
                  )
                : null,
          ),
        );
      }

      reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return AsyncData(reminders);
    });
