// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeGreeting => 'Hello';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonBack => 'Back';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonNotProvidedFeminine => 'Not provided';

  @override
  String get commonNotProvidedMasculine => 'Not provided';

  @override
  String get dueStatusUpToDate => 'Up to date';

  @override
  String get dueStatusDueSoon => 'Upcoming';

  @override
  String get dueStatusOverdue => 'Overdue';

  @override
  String get animalSpeciesDog => 'Dog';

  @override
  String get animalSpeciesCat => 'Cat';

  @override
  String get animalFormNameLabel => 'Name *';

  @override
  String get animalFormNameRequired => 'Name is required.';

  @override
  String get animalFormSpeciesLabel => 'Species *';

  @override
  String get animalFormSpeciesRequired => 'Choose a species.';

  @override
  String get animalFormBreedLabel => 'Breed (optional)';

  @override
  String get animalFormWeightLabel => 'Initial weight in kg (optional)';

  @override
  String get animalFormWeightInvalid => 'Invalid weight.';

  @override
  String get animalFormBirthDateLabel => 'Date of birth (optional)';

  @override
  String get animalFormBirthDateNotProvided => 'Not provided';

  @override
  String get createAnimalTitle => 'Create an animal profile';

  @override
  String get createAnimalSubmit => 'Create profile';

  @override
  String get animalNotFound => 'Animal not found.';

  @override
  String get profileSpeciesLabel => 'Species';

  @override
  String get profileBreedLabel => 'Breed';

  @override
  String get profileBirthDateLabel => 'Date of birth';

  @override
  String get profileWeightLabel => 'Initial weight';

  @override
  String animalProfileWeightValue(String weight) {
    return '$weight kg';
  }

  @override
  String get vaccinationsSectionTitle => 'Vaccinations';

  @override
  String get treatmentsSectionTitle => 'Ongoing treatment';

  @override
  String get remindersCountLabel => 'reminder(s)';

  @override
  String get vaccinesEmptyCta => 'No vaccinations recorded — tap to add one.';

  @override
  String get treatmentsEmptyCta => 'No treatments recorded — tap to add one.';

  @override
  String get animalAgeLessThanMonth => 'less than a month old';

  @override
  String animalAgeMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '$count month',
    );
    return '$_temp0';
  }

  @override
  String animalAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '1 year',
    );
    return '$_temp0';
  }
}
