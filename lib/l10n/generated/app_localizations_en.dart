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
  String get commonRetry => 'Retry';

  @override
  String get commonDelete => 'Delete';

  @override
  String get errorDisplayTitle => 'An error occurred';

  @override
  String get navHome => 'Home';

  @override
  String get navCarnet => 'Records';

  @override
  String get homeTodayTitle => 'To do today';

  @override
  String get homeNoReminders =>
      'Nothing to report right now — all reminders are up to date.';

  @override
  String get homeQuickActionsTitle => 'Quick actions';

  @override
  String get homeNewTreatmentAction => 'New treatment';

  @override
  String get homeVaccinationReminderAction => 'Vaccination reminder';

  @override
  String get homeAntiparasiteAction => 'Pest control';

  @override
  String get homeEmptyStateTitle => 'Welcome to MémoPatte';

  @override
  String get homeEmptyStateMessage =>
      'Create your first companion\'s profile to start tracking their reminders.';

  @override
  String get deleteVaccinationTitle => 'Delete this vaccination?';

  @override
  String deleteVaccinationMessage(String name) {
    return '\"$name\" will be permanently deleted, along with its scheduled reminder.';
  }

  @override
  String get deleteTreatmentTitle => 'Delete this treatment?';

  @override
  String deleteTreatmentMessage(String name) {
    return '\"$name\" will be permanently deleted, along with its scheduled reminder.';
  }

  @override
  String vaccinationDoneOn(String date) {
    return 'Given on $date';
  }

  @override
  String vaccinationDoneOnWithDue(String date, String dueDate) {
    return 'Given on $date — due on $dueDate';
  }

  @override
  String get treatmentNextDoseLabel => 'Next dose';

  @override
  String get treatmentDueToday => 'Today';

  @override
  String treatmentDueInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'In $days days',
      one: 'In 1 day',
    );
    return '$_temp0';
  }

  @override
  String treatmentOverdueDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days overdue',
      one: '1 day overdue',
    );
    return '$_temp0';
  }

  @override
  String get vaccinationsListTitle => 'Vaccinations';

  @override
  String vaccinationsListTitleWithName(String name) {
    return '$name\'s vaccinations';
  }

  @override
  String get vaccinationsListAddTooltip => 'Add a vaccination';

  @override
  String get vaccinationsListEmptyTitle => 'No vaccinations recorded';

  @override
  String get vaccinationsListEmptyMessage =>
      'Tap + to add a vaccination, even one given a while ago.';

  @override
  String get vaccinationFormAddTitle => 'Add a vaccination';

  @override
  String get vaccinationFormEditTitle => 'Edit vaccination';

  @override
  String get vaccinationFormNotFound => 'Vaccination not found.';

  @override
  String get vaccinationFormNameLabel => 'Vaccination name *';

  @override
  String get vaccinationFormNameHint => 'Rabies, DHPPi...';

  @override
  String get vaccinationFormNameRequired => 'Vaccination name is required.';

  @override
  String get vaccinationFormDateLabel => 'Vaccination date *';

  @override
  String get vaccinationFormNextDueDateLabel => 'Next due date (optional)';

  @override
  String get vaccinationFormClearDueDateTooltip => 'Clear due date';

  @override
  String get vaccinationFormSubmit => 'Add vaccination';

  @override
  String get treatmentsListTitle => 'Treatments';

  @override
  String treatmentsListTitleWithName(String name) {
    return '$name\'s treatments';
  }

  @override
  String get treatmentsListAddTooltip => 'Add a treatment';

  @override
  String get treatmentsListEmptyTitle => 'No treatments recorded';

  @override
  String get treatmentsListEmptyMessage =>
      'Tap + to add a dewormer or pest control treatment, even one given a while ago.';

  @override
  String get treatmentFormAddTitle => 'Add a treatment';

  @override
  String get treatmentFormEditTitle => 'Edit treatment';

  @override
  String get treatmentFormNotFound => 'Treatment not found.';

  @override
  String get treatmentFormNameLabel => 'Treatment name *';

  @override
  String get treatmentFormNameHint => 'Bravecto, Dewormer...';

  @override
  String get treatmentFormNameRequired => 'Treatment name is required.';

  @override
  String get treatmentFormStartDateLabel => 'Treatment start date *';

  @override
  String get treatmentFormLastDoseDateLabel => 'Date of last dose *';

  @override
  String get treatmentFormFrequencyLabel => 'Frequency *';

  @override
  String get treatmentFormReminderTimeLabel => 'Reminder time *';

  @override
  String get treatmentFormReminderTimesLabel => 'Reminder times *';

  @override
  String get treatmentFormChooseTime => 'Choose a time';

  @override
  String get treatmentFormRemoveTimeTooltip => 'Remove this time';

  @override
  String get treatmentFormAddTime => 'Add a time';

  @override
  String treatmentFormNextReminderLabel(String description) {
    return 'Next reminder: $description';
  }

  @override
  String treatmentFormNextDueDateLabel(String date) {
    return 'Next due date: $date';
  }

  @override
  String get treatmentFormMissingReminderTime =>
      'Choose at least one reminder time.';

  @override
  String get treatmentFormSubmit => 'Add treatment';

  @override
  String get treatmentFormFrequencyMonthly => '1 month';

  @override
  String get treatmentFormFrequencyQuarterly => '3 months';

  @override
  String get treatmentFormFrequencyBiannual => '6 months';

  @override
  String get treatmentFormFrequencyAnnual => '1 year';

  @override
  String get treatmentFormFrequencyDaily => '1×/day';

  @override
  String get treatmentFormFrequencySeveralTimesDaily => 'Several/day';

  @override
  String get notificationPermissionBannerText =>
      'Reminders are off — enable them in settings';

  @override
  String get notificationPrimingTitle => 'Enable reminders';

  @override
  String get notificationPrimingHeadline => 'Never miss a reminder again';

  @override
  String get notificationPrimingBody =>
      'MémoPatte can let you know when a vaccination or a dewormer treatment is coming due. Allow notifications so nothing slips through the cracks — you can change your mind anytime in your phone\'s settings.';

  @override
  String get notificationPrimingActivate => 'Enable reminders';

  @override
  String get notificationPrimingLater => 'Later';

  @override
  String get homeReminderVaccinationTitle => 'Vaccination reminder';

  @override
  String get homeReminderTreatmentTitle => 'Treatment reminder';

  @override
  String get notificationFallbackAnimalName => 'your companion';

  @override
  String get vaccinationReminderNotificationTitle => 'Vaccination reminder';

  @override
  String vaccinationReminderNotificationBody(String name, String animalName) {
    return 'The $name vaccine for $animalName is due today.';
  }

  @override
  String get treatmentReminderNotificationTitle => 'Treatment reminder';

  @override
  String treatmentReminderDueNotificationBody(String name, String animalName) {
    return 'The $name treatment for $animalName is due today.';
  }

  @override
  String treatmentReminderTimeNotificationBody(String name, String animalName) {
    return 'The $name treatment for $animalName needs to be given now.';
  }

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
