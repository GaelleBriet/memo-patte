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
