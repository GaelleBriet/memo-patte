// `export` seul ne suffit pas : il republie le symbole pour les
// fichiers qui *importent* celui-ci, mais ne l'apporte pas dans la
// portée de ce fichier-ci — le `typedef` ci-dessous a besoin de
// `import` en plus pour pouvoir nommer `DueStatus`.
import '../../../core/domain/due_status.dart';
export '../../../core/domain/due_status.dart';

/// Alias historique : `VaccinationStatus` désigne exactement le même
/// type que `DueStatus` (extrait dans `core/domain` au ticket 4.1, quand
/// l'épic 4 a eu besoin du même calcul de statut) — gardé pour ne pas
/// casser les appels existants (`VaccinationCard`, l'écran vaccins,
/// l'accueil, les tests...). Le nouveau code (traitements) utilise
/// `DueStatus` directement, ce type-ci ne sert plus qu'à ce vocabulaire
/// spécifique aux vaccins dans le code déjà écrit.
typedef VaccinationStatus = DueStatus;
