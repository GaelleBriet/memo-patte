import 'package:drift/drift.dart';

import '../../animals/data/animal_table.dart';

/// Table Drift des vaccinations (ticket 3.1).
///
/// Conformément à `01-architecture.md` ("Rappels et notifications :
/// comment ça s'articule"), pas de table "Reminder" séparée : chaque
/// ligne porte sa prochaine échéance ([nextDueDate]) et l'identifiant de
/// la notification locale programmée ([notificationId]), pour pouvoir
/// l'annuler/la reprogrammer si la date change.
///
/// [name] ne figure pas dans l'énumération de colonnes du ticket 3.1
/// ("liée à Animal, date, prochaine échéance, id notification") mais la
/// liste du ticket 3.3 est inutilisable sans un libellé par vaccin —
/// ajouté ici en le signalant comme un écart assumé par rapport au texte
/// du ticket.
@DataClassName('Vaccination')
class Vaccinations extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Suppression en cascade si le profil animal disparaît : pas de
  /// vaccins orphelins. Nécessite `PRAGMA foreign_keys = ON`, activé dans
  /// `beforeOpen` de `AppDatabase`. Attention (hors scope v1, aucun écran
  /// ne supprime un animal) : une cascade ne passe pas par le repository,
  /// donc n'annulerait pas les notifications programmées des lignes
  /// supprimées.
  IntColumn get animalId =>
      integer().references(Animals, #id, onDelete: KeyAction.cascade)();

  /// Libellé du vaccin tel que noté sur le carnet (ex. "Rage", "CHPPiL").
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Date d'administration. Peut être antérieure à aujourd'hui : la
  /// saisie rétroactive est un pain point identifié
  /// (`docs/product/03-pain-points.md`), explicitement couverte par le
  /// ticket 3.2.
  DateTimeColumn get date => dateTime()();

  /// Prochaine échéance donnée par le vétérinaire. Facultative : un
  /// vaccin peut ne pas avoir de rappel prévu (dernière injection d'un
  /// protocole, par exemple).
  DateTimeColumn get nextDueDate => dateTime().nullable()();

  /// Identifiant de la notification locale programmée pour [nextDueDate],
  /// `null` si aucune ne l'est (pas d'échéance, échéance passée...).
  /// Géré exclusivement par `VaccinationRepository` (ticket 3.4), jamais
  /// par les écrans.
  IntColumn get notificationId => integer().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
