import 'package:flutter_test/flutter_test.dart';
import 'package:memo_patte/features/treatments/domain/reminder_times.dart';

/// Tests du calcul d'heure(s) de rappel des traitements à fréquence
/// quotidienne (`TreatmentFrequency.daily`/`severalTimesDaily`, ajoutées
/// le 2026-08-17) — même esprit que `treatment_frequency_test.dart`.
void main() {
  group('decodeReminderTimes / encodeReminderTimes', () {
    test('décode un CSV en minutes triées, sans doublon', () {
      expect(decodeReminderTimes('1200,480,480'), [480, 1200]);
    });

    test('null ou vide décode en liste vide', () {
      expect(decodeReminderTimes(null), isEmpty);
      expect(decodeReminderTimes(''), isEmpty);
    });

    test('encode trie et déduplique', () {
      expect(encodeReminderTimes([1200, 480, 480]), '480,1200');
    });

    test('aller-retour encode puis décode', () {
      final original = [540, 60, 1320];
      expect(decodeReminderTimes(encodeReminderTimes(original)), [
        60,
        540,
        1320,
      ]);
    });
  });

  group('nextReminderDateTime', () {
    test('une heure encore à venir aujourd\'hui : retourne aujourd\'hui à '
        'cette heure', () {
      final now = DateTime(2026, 6, 10, 7, 0);
      final next = nextReminderDateTime([8 * 60], now);
      expect(next, DateTime(2026, 6, 10, 8, 0));
    });

    test('l\'heure d\'aujourd\'hui est déjà passée : retourne demain à '
        'cette heure', () {
      final now = DateTime(2026, 6, 10, 21, 0);
      final next = nextReminderDateTime([8 * 60], now);
      expect(next, DateTime(2026, 6, 11, 8, 0));
    });

    test('plusieurs heures : retourne la plus proche encore à venir '
        'aujourd\'hui', () {
      final now = DateTime(2026, 6, 10, 10, 0);
      final next = nextReminderDateTime([8 * 60, 12 * 60, 20 * 60], now);
      expect(next, DateTime(2026, 6, 10, 12, 0));
    });

    test('plusieurs heures, toutes passées : retourne la première de '
        'demain', () {
      final now = DateTime(2026, 6, 10, 23, 0);
      final next = nextReminderDateTime([8 * 60, 12 * 60, 20 * 60], now);
      expect(next, DateTime(2026, 6, 11, 8, 0));
    });

    test('l\'ordre de la liste passée en entrée n\'a pas d\'importance '
        '(triée en interne)', () {
      final now = DateTime(2026, 6, 10, 10, 0);
      final next = nextReminderDateTime([20 * 60, 8 * 60, 12 * 60], now);
      expect(next, DateTime(2026, 6, 10, 12, 0));
    });

    test('liste vide : lève une erreur explicite', () {
      expect(
        () => nextReminderDateTime(const [], DateTime(2026, 6, 10)),
        throwsArgumentError,
      );
    });
  });

  group('formatMinuteOfDay', () {
    test('formate avec zéros de tête', () {
      expect(formatMinuteOfDay(8 * 60), '08:00');
      expect(formatMinuteOfDay(9 * 60 + 5), '09:05');
      expect(formatMinuteOfDay(20 * 60 + 30), '20:30');
    });
  });

  group('describeUpcomingReminder', () {
    test('même jour : "Aujourd\'hui à HH:mm"', () {
      final now = DateTime(2026, 6, 10, 7, 0);
      final due = DateTime(2026, 6, 10, 20, 0);
      expect(describeUpcomingReminder(due, now), 'Aujourd\'hui à 20:00');
    });

    test('jour suivant : "Demain à HH:mm"', () {
      final now = DateTime(2026, 6, 10, 22, 0);
      final due = DateTime(2026, 6, 11, 8, 0);
      expect(describeUpcomingReminder(due, now), 'Demain à 08:00');
    });

    test('jour déjà dépassé (pas encore réconcilié) : "En retard (HH:mm)"', () {
      final now = DateTime(2026, 6, 12, 9, 0);
      final due = DateTime(2026, 6, 10, 8, 0);
      expect(describeUpcomingReminder(due, now), 'En retard (08:00)');
    });
  });
}
