import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../animals/data/animal_provider.dart';
import '../../vaccinations/data/vaccinations_list_provider.dart';
import '../../vaccinations/domain/vaccination_status.dart';
import '../domain/home_reminder.dart';

/// Rappels à venir/en retard d'un animal donné (ticket 6.1) — l'accueil
/// est centré sur un seul animal à la fois depuis le 2026-08-15 (chips
/// pour switcher, plus de vue agrégée "tous les animaux" en un seul
/// écran) ; `.family` sur l'id de l'animal plutôt qu'une agrégation
/// multi-animaux comme la première version de ce provider.
///
/// Aujourd'hui, seuls les vaccins alimentent la liste (épic 4
/// `treatments` pas encore faite) — voir `home_reminder.dart` pour
/// pourquoi ce n'est pas gênant d'en ajouter d'autres plus tard.
///
/// `Provider.family` écrit à la main plutôt qu'un `StreamProvider`
/// combiné : les deux dépendances (`animalProvider`,
/// `vaccinationsListProvider`) sont déjà réactives chacune de leur côté,
/// un simple enchaînement de `ref.watch` suffit à propager leurs
/// changements ici sans re-modéliser un flux combiné à la main.
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
      if (!vaccinationsAsync.hasValue) {
        return vaccinationsAsync.hasError
            ? AsyncError(
                vaccinationsAsync.error!,
                vaccinationsAsync.stackTrace!,
              )
            : const AsyncLoading();
      }

      final reminders = <HomeReminder>[];
      for (final vaccination in vaccinationsAsync.requireValue) {
        final dueDate = vaccination.nextDueDate;
        if (dueDate == null) continue;

        final status = VaccinationStatus.fromNextDueDate(
          dueDate,
          DateTime.now(),
        );
        if (status == VaccinationStatus.upToDate) continue;

        reminders.add(
          HomeReminder(
            animalId: animalId,
            animalName: animal.name,
            vaccinationId: vaccination.id,
            title: 'Rappel de vaccin',
            detail: vaccination.name,
            dueDate: dueDate,
            status: status,
          ),
        );
      }

      reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return AsyncData(reminders);
    });
