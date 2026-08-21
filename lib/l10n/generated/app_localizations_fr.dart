// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get homeGreeting => 'Bonjour';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonSeeAll => 'Voir tout';

  @override
  String get commonNotProvidedFeminine => 'Non renseignée';

  @override
  String get commonNotProvidedMasculine => 'Non renseigné';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get errorDisplayTitle => 'Une erreur est survenue';

  @override
  String get navHome => 'Accueil';

  @override
  String get navCarnet => 'Carnet';

  @override
  String get homeTodayTitle => 'À faire aujourd\'hui';

  @override
  String get homeNoReminders =>
      'Rien à signaler pour l\'instant — tous les rappels sont à jour.';

  @override
  String get homeQuickActionsTitle => 'Actions rapides';

  @override
  String get homeNewTreatmentAction => 'Nouveau traitement';

  @override
  String get homeVaccinationReminderAction => 'Rappel de vaccin';

  @override
  String get homeAntiparasiteAction => 'Antiparasitaire';

  @override
  String get homeEmptyStateTitle => 'Bienvenue sur MémoPatte';

  @override
  String get homeEmptyStateMessage =>
      'Crée le profil de ton premier compagnon pour commencer à suivre ses rappels.';

  @override
  String get deleteVaccinationTitle => 'Supprimer ce vaccin ?';

  @override
  String deleteVaccinationMessage(String name) {
    return '\"$name\" sera définitivement supprimé, ainsi que son rappel programmé.';
  }

  @override
  String get deleteTreatmentTitle => 'Supprimer ce traitement ?';

  @override
  String deleteTreatmentMessage(String name) {
    return '\"$name\" sera définitivement supprimé, ainsi que son rappel programmé.';
  }

  @override
  String vaccinationDoneOn(String date) {
    return 'Fait le $date';
  }

  @override
  String vaccinationDoneOnWithDue(String date, String dueDate) {
    return 'Fait le $date — échéance le $dueDate';
  }

  @override
  String get treatmentNextDoseLabel => 'Prochaine dose';

  @override
  String get treatmentDueToday => 'Aujourd\'hui';

  @override
  String treatmentDueInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Dans $days jours',
      one: 'Dans 1 jour',
    );
    return '$_temp0';
  }

  @override
  String treatmentOverdueDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'En retard de $days jours',
      one: 'En retard de 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get vaccinationsListTitle => 'Vaccins';

  @override
  String vaccinationsListTitleWithName(String name) {
    return 'Vaccins de $name';
  }

  @override
  String get vaccinationsListAddTooltip => 'Ajouter un vaccin';

  @override
  String get vaccinationsListEmptyTitle => 'Aucun vaccin enregistré';

  @override
  String get vaccinationsListEmptyMessage =>
      'Appuie sur + pour ajouter un vaccin, même fait il y a longtemps.';

  @override
  String get vaccinationFormAddTitle => 'Ajouter un vaccin';

  @override
  String get vaccinationFormEditTitle => 'Modifier le vaccin';

  @override
  String get vaccinationFormNotFound => 'Vaccin introuvable.';

  @override
  String get vaccinationFormNameLabel => 'Nom du vaccin *';

  @override
  String get vaccinationFormNameHint => 'Rage, CHPPiL...';

  @override
  String get vaccinationFormNameRequired => 'Le nom du vaccin est obligatoire.';

  @override
  String get vaccinationFormDateLabel => 'Date du vaccin *';

  @override
  String get vaccinationFormNextDueDateLabel =>
      'Prochaine échéance (facultatif)';

  @override
  String get vaccinationFormClearDueDateTooltip => 'Effacer l\'échéance';

  @override
  String get vaccinationFormSubmit => 'Ajouter le vaccin';

  @override
  String get treatmentsListTitle => 'Traitements';

  @override
  String treatmentsListTitleWithName(String name) {
    return 'Traitements de $name';
  }

  @override
  String get treatmentsListAddTooltip => 'Ajouter un traitement';

  @override
  String get treatmentsListEmptyTitle => 'Aucun traitement enregistré';

  @override
  String get treatmentsListEmptyMessage =>
      'Appuie sur + pour ajouter un vermifuge ou un antiparasitaire, même fait il y a longtemps.';

  @override
  String get treatmentFormAddTitle => 'Ajouter un traitement';

  @override
  String get treatmentFormEditTitle => 'Modifier le traitement';

  @override
  String get treatmentFormNotFound => 'Traitement introuvable.';

  @override
  String get treatmentFormNameLabel => 'Nom du traitement *';

  @override
  String get treatmentFormNameHint => 'Bravecto, Vermifuge...';

  @override
  String get treatmentFormNameRequired =>
      'Le nom du traitement est obligatoire.';

  @override
  String get treatmentFormStartDateLabel => 'Date de début du traitement *';

  @override
  String get treatmentFormLastDoseDateLabel =>
      'Date de la dernière administration *';

  @override
  String get treatmentFormFrequencyLabel => 'Fréquence *';

  @override
  String get treatmentFormReminderTimeLabel => 'Heure de rappel *';

  @override
  String get treatmentFormReminderTimesLabel => 'Heures de rappel *';

  @override
  String get treatmentFormChooseTime => 'Choisir une heure';

  @override
  String get treatmentFormRemoveTimeTooltip => 'Retirer cette heure';

  @override
  String get treatmentFormAddTime => 'Ajouter une heure';

  @override
  String treatmentFormNextReminderLabel(String description) {
    return 'Prochain rappel : $description';
  }

  @override
  String treatmentFormNextDueDateLabel(String date) {
    return 'Prochaine échéance : $date';
  }

  @override
  String get treatmentFormMissingReminderTime =>
      'Choisis au moins une heure de rappel.';

  @override
  String get treatmentFormSubmit => 'Ajouter le traitement';

  @override
  String get treatmentFormFrequencyMonthly => '1 mois';

  @override
  String get treatmentFormFrequencyQuarterly => '3 mois';

  @override
  String get treatmentFormFrequencyBiannual => '6 mois';

  @override
  String get treatmentFormFrequencyAnnual => '1 an';

  @override
  String get treatmentFormFrequencyDaily => '1×/jour';

  @override
  String get treatmentFormFrequencySeveralTimesDaily => 'Plusieurs/jour';

  @override
  String get notificationPermissionBannerText =>
      'Rappels désactivés — active-les dans les réglages';

  @override
  String get notificationPrimingTitle => 'Activer les rappels';

  @override
  String get notificationPrimingHeadline => 'Ne rate plus jamais un rappel';

  @override
  String get notificationPrimingBody =>
      'MémoPatte peut te prévenir quand un vaccin ou un vermifuge approche de son échéance. Autorise les notifications pour ne rien oublier — tu pourras changer d\'avis à tout moment dans les réglages de ton téléphone.';

  @override
  String get notificationPrimingActivate => 'Activer les rappels';

  @override
  String get notificationPrimingLater => 'Plus tard';

  @override
  String get homeReminderVaccinationTitle => 'Rappel de vaccin';

  @override
  String get homeReminderTreatmentTitle => 'Rappel de traitement';

  @override
  String get notificationFallbackAnimalName => 'ton animal';

  @override
  String get vaccinationReminderNotificationTitle => 'Rappel vaccin';

  @override
  String vaccinationReminderNotificationBody(String name, String animalName) {
    return 'Le vaccin $name de $animalName arrive à échéance aujourd\'hui.';
  }

  @override
  String get treatmentReminderNotificationTitle => 'Rappel de traitement';

  @override
  String treatmentReminderDueNotificationBody(String name, String animalName) {
    return 'Le traitement $name de $animalName arrive à échéance aujourd\'hui.';
  }

  @override
  String treatmentReminderTimeNotificationBody(String name, String animalName) {
    return 'Le traitement $name de $animalName est à donner maintenant.';
  }

  @override
  String get dueStatusUpToDate => 'À jour';

  @override
  String get dueStatusDueSoon => 'À venir';

  @override
  String get dueStatusOverdue => 'En retard';

  @override
  String get animalSpeciesDog => 'Chien';

  @override
  String get animalSpeciesCat => 'Chat';

  @override
  String get animalFormNameLabel => 'Nom *';

  @override
  String get animalFormNameRequired => 'Le nom est obligatoire.';

  @override
  String get animalFormSpeciesLabel => 'Espèce *';

  @override
  String get animalFormSpeciesRequired => 'Choisis une espèce.';

  @override
  String get animalFormBreedLabel => 'Race (facultatif)';

  @override
  String get animalFormWeightLabel => 'Poids initial en kg (facultatif)';

  @override
  String get animalFormWeightInvalid => 'Poids invalide.';

  @override
  String get animalFormBirthDateLabel => 'Date de naissance (facultatif)';

  @override
  String get animalFormBirthDateNotProvided => 'Non renseignée';

  @override
  String get createAnimalTitle => 'Créer un profil animal';

  @override
  String get createAnimalSubmit => 'Créer le profil';

  @override
  String get animalNotFound => 'Animal introuvable.';

  @override
  String get profileSpeciesLabel => 'Espèce';

  @override
  String get profileBreedLabel => 'Race';

  @override
  String get profileBirthDateLabel => 'Date de naissance';

  @override
  String get profileWeightLabel => 'Poids initial';

  @override
  String animalProfileWeightValue(String weight) {
    return '$weight kg';
  }

  @override
  String get vaccinationsSectionTitle => 'Vaccins';

  @override
  String get treatmentsSectionTitle => 'Traitement en cours';

  @override
  String get remindersCountLabel => 'rappel(s)';

  @override
  String get vaccinesEmptyCta =>
      'Aucun vaccin enregistré — appuie pour en ajouter un.';

  @override
  String get treatmentsEmptyCta =>
      'Aucun traitement enregistré — appuie pour en ajouter un.';

  @override
  String get animalAgeLessThanMonth => 'moins d\'un mois';

  @override
  String animalAgeMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mois',
      one: '$count mois',
    );
    return '$_temp0';
  }

  @override
  String animalAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ans',
      one: '1 an',
    );
    return '$_temp0';
  }
}
