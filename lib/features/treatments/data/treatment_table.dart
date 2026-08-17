import 'package:drift/drift.dart';

import '../../animals/data/animal_table.dart';
import '../domain/treatment_frequency.dart';

/// Table Drift des traitements (vermifuges/antiparasitaires, ticket
/// 4.1). Même schéma que [Vaccinations] (voir son commentaire de classe)
/// avec en plus [frequency], qui porte la notion de fréquence
/// récurrente propre aux traitements.
///
/// [nextDueDate] n'est pas facultative ici, contrairement aux vaccins :
/// elle est toujours calculée (`date` + [frequency], voir
/// `TreatmentRepository`), jamais saisie à la main — un traitement
/// récurrent a par construction toujours une prochaine échéance.
@DataClassName('Treatment')
class Treatments extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Suppression en cascade si le profil animal disparaît — même
  /// remarque que [Vaccinations.animalId] (nécessite
  /// `PRAGMA foreign_keys = ON`, déjà activé dans `AppDatabase`).
  IntColumn get animalId =>
      integer().references(Animals, #id, onDelete: KeyAction.cascade)();

  /// Libellé du traitement tel que noté sur le carnet (ex. "Bravecto",
  /// "Vermifuge").
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Date de la dernière administration. Peut être antérieure à
  /// aujourd'hui — saisie rétroactive, même pain point identifié que
  /// pour les vaccins (`docs/product/03-pain-points.md`), couverte par
  /// le ticket 4.2.
  DateTimeColumn get date => dateTime()();

  IntColumn get frequency => intEnum<TreatmentFrequency>()();

  /// Calculée à la création/modification (`date` + [frequency]), et
  /// avancée automatiquement quand elle est dépassée — voir
  /// `TreatmentRepository.reconcileOverdueTreatments` (ticket 4.4).
  DateTimeColumn get nextDueDate => dateTime()();

  /// Identifiant de la notification locale programmée pour
  /// [nextDueDate], `null` si aucune ne l'est (échéance déjà passée au
  /// moment de la programmation). Géré exclusivement par
  /// `TreatmentRepository`, jamais par les écrans.
  IntColumn get notificationId => integer().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
