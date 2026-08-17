import 'package:flutter_test/flutter_test.dart';
import 'package:memo_patte/features/treatments/domain/treatment_frequency.dart';

/// Tests du calcul de prochaine échéance à partir de la fréquence
/// (ticket 4.5).
void main() {
  group('nextOccurrenceAfter', () {
    test('mensuel : ajoute 1 mois', () {
      expect(
        TreatmentFrequency.monthly.nextOccurrenceAfter(DateTime(2026, 6, 10)),
        DateTime(2026, 7, 10),
      );
    });

    test('trimestriel : ajoute 3 mois', () {
      expect(
        TreatmentFrequency.quarterly.nextOccurrenceAfter(DateTime(2026, 6, 10)),
        DateTime(2026, 9, 10),
      );
    });

    test('semestriel : ajoute 6 mois', () {
      expect(
        TreatmentFrequency.biannual.nextOccurrenceAfter(DateTime(2026, 6, 10)),
        DateTime(2026, 12, 10),
      );
    });

    test('annuel : ajoute 12 mois', () {
      expect(
        TreatmentFrequency.annual.nextOccurrenceAfter(DateTime(2026, 6, 10)),
        DateTime(2027, 6, 10),
      );
    });

    test('franchit le passage à l\'année suivante (mensuel en décembre)', () {
      expect(
        TreatmentFrequency.monthly.nextOccurrenceAfter(DateTime(2026, 12, 20)),
        DateTime(2027, 1, 20),
      );
    });

    test('franchit plusieurs années (trimestriel depuis novembre)', () {
      expect(
        TreatmentFrequency.quarterly.nextOccurrenceAfter(
          DateTime(2026, 11, 15),
        ),
        DateTime(2027, 2, 15),
      );
    });

    test('ramène au jour près, même si la date de départ porte une heure '
        '(comme une échéance de vaccin — granularité du jour, pas de '
        'l\'instant)', () {
      expect(
        TreatmentFrequency.monthly.nextOccurrenceAfter(
          DateTime(2026, 6, 10, 14, 30),
        ),
        DateTime(2026, 7, 10),
      );
    });
  });
}
