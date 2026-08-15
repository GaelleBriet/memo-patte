import 'package:flutter_test/flutter_test.dart';
import 'package:memo_patte/features/vaccinations/domain/vaccination_status.dart';

/// Tests du calcul de statut d'échéance (tickets 3.3/3.5). Dates fixes en
/// juin, loin des changements d'heure d'été/hiver, pour que les
/// frontières de jour ne dépendent pas du fuseau de la machine de test.
void main() {
  // Un jeudi à 14h37 : heure quelconque en milieu de journée, pour
  // vérifier que seule la *date* compte.
  final now = DateTime(2026, 6, 18, 14, 37);

  group('VaccinationStatus.fromNextDueDate', () {
    test('sans échéance : à jour', () {
      expect(
        VaccinationStatus.fromNextDueDate(null, now),
        VaccinationStatus.upToDate,
      );
    });

    test('échéance hier : en retard', () {
      expect(
        VaccinationStatus.fromNextDueDate(DateTime(2026, 6, 17), now),
        VaccinationStatus.overdue,
      );
    });

    test('échéance aujourd\'hui : à venir (il reste la journée pour agir)', () {
      expect(
        VaccinationStatus.fromNextDueDate(DateTime(2026, 6, 18), now),
        VaccinationStatus.dueSoon,
      );
    });

    test('échéance au dernier jour de la fenêtre (J+30) : à venir', () {
      expect(
        VaccinationStatus.fromNextDueDate(DateTime(2026, 7, 18), now),
        VaccinationStatus.dueSoon,
      );
    });

    test('échéance juste après la fenêtre (J+31) : à jour', () {
      expect(
        VaccinationStatus.fromNextDueDate(DateTime(2026, 7, 19), now),
        VaccinationStatus.upToDate,
      );
    });

    test('granularité au jour : l\'heure de l\'échéance ne joue pas', () {
      // Échéance aujourd'hui à 8h alors qu'il est 14h37 : pas "en
      // retard" pour autant.
      expect(
        VaccinationStatus.fromNextDueDate(DateTime(2026, 6, 18, 8), now),
        VaccinationStatus.dueSoon,
      );
    });

    test('granularité au jour : l\'heure de `now` ne joue pas non plus', () {
      // À 23h59 la veille de l'échéance, toujours "à venir".
      final lateEvening = DateTime(2026, 6, 17, 23, 59);
      expect(
        VaccinationStatus.fromNextDueDate(DateTime(2026, 6, 18), lateEvening),
        VaccinationStatus.dueSoon,
      );
    });
  });
}
