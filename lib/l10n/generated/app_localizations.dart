import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Salutation en tête de l'accueil.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get homeGreeting;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get commonBack;

  /// No description provided for @commonEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get commonEdit;

  /// No description provided for @commonSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get commonSeeAll;

  /// Valeur d'un champ facultatif non renseigné, accord féminin (ex. "la race", "la date de naissance").
  ///
  /// In fr, this message translates to:
  /// **'Non renseignée'**
  String get commonNotProvidedFeminine;

  /// Valeur d'un champ facultatif non renseigné, accord masculin (ex. "le poids").
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get commonNotProvidedMasculine;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// No description provided for @commonDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// No description provided for @errorDisplayTitle.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get errorDisplayTitle;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navCarnet.
  ///
  /// In fr, this message translates to:
  /// **'Carnet'**
  String get navCarnet;

  /// No description provided for @homeTodayTitle.
  ///
  /// In fr, this message translates to:
  /// **'À faire aujourd\'hui'**
  String get homeTodayTitle;

  /// No description provided for @homeNoReminders.
  ///
  /// In fr, this message translates to:
  /// **'Rien à signaler pour l\'instant — tous les rappels sont à jour.'**
  String get homeNoReminders;

  /// No description provided for @homeQuickActionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Actions rapides'**
  String get homeQuickActionsTitle;

  /// No description provided for @homeNewTreatmentAction.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau traitement'**
  String get homeNewTreatmentAction;

  /// No description provided for @homeVaccinationReminderAction.
  ///
  /// In fr, this message translates to:
  /// **'Rappel de vaccin'**
  String get homeVaccinationReminderAction;

  /// No description provided for @homeAntiparasiteAction.
  ///
  /// In fr, this message translates to:
  /// **'Antiparasitaire'**
  String get homeAntiparasiteAction;

  /// No description provided for @homeEmptyStateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur MémoPatte'**
  String get homeEmptyStateTitle;

  /// No description provided for @homeEmptyStateMessage.
  ///
  /// In fr, this message translates to:
  /// **'Crée le profil de ton premier compagnon pour commencer à suivre ses rappels.'**
  String get homeEmptyStateMessage;

  /// No description provided for @deleteVaccinationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce vaccin ?'**
  String get deleteVaccinationTitle;

  /// No description provided for @deleteVaccinationMessage.
  ///
  /// In fr, this message translates to:
  /// **'\"{name}\" sera définitivement supprimé, ainsi que son rappel programmé.'**
  String deleteVaccinationMessage(String name);

  /// No description provided for @deleteTreatmentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce traitement ?'**
  String get deleteTreatmentTitle;

  /// No description provided for @deleteTreatmentMessage.
  ///
  /// In fr, this message translates to:
  /// **'\"{name}\" sera définitivement supprimé, ainsi que son rappel programmé.'**
  String deleteTreatmentMessage(String name);

  /// No description provided for @vaccinationDoneOn.
  ///
  /// In fr, this message translates to:
  /// **'Fait le {date}'**
  String vaccinationDoneOn(String date);

  /// No description provided for @vaccinationDoneOnWithDue.
  ///
  /// In fr, this message translates to:
  /// **'Fait le {date} — échéance le {dueDate}'**
  String vaccinationDoneOnWithDue(String date, String dueDate);

  /// No description provided for @treatmentNextDoseLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine dose'**
  String get treatmentNextDoseLabel;

  /// No description provided for @treatmentDueToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get treatmentDueToday;

  /// No description provided for @treatmentDueInDays.
  ///
  /// In fr, this message translates to:
  /// **'{days, plural, =1{Dans 1 jour} other{Dans {days} jours}}'**
  String treatmentDueInDays(int days);

  /// No description provided for @treatmentOverdueDays.
  ///
  /// In fr, this message translates to:
  /// **'{days, plural, =1{En retard de 1 jour} other{En retard de {days} jours}}'**
  String treatmentOverdueDays(int days);

  /// No description provided for @vaccinationsListTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vaccins'**
  String get vaccinationsListTitle;

  /// No description provided for @vaccinationsListTitleWithName.
  ///
  /// In fr, this message translates to:
  /// **'Vaccins de {name}'**
  String vaccinationsListTitleWithName(String name);

  /// No description provided for @vaccinationsListAddTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un vaccin'**
  String get vaccinationsListAddTooltip;

  /// No description provided for @vaccinationsListEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun vaccin enregistré'**
  String get vaccinationsListEmptyTitle;

  /// No description provided for @vaccinationsListEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Appuie sur + pour ajouter un vaccin, même fait il y a longtemps.'**
  String get vaccinationsListEmptyMessage;

  /// No description provided for @vaccinationFormAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un vaccin'**
  String get vaccinationFormAddTitle;

  /// No description provided for @vaccinationFormEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le vaccin'**
  String get vaccinationFormEditTitle;

  /// No description provided for @vaccinationFormNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Vaccin introuvable.'**
  String get vaccinationFormNotFound;

  /// No description provided for @vaccinationFormNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du vaccin *'**
  String get vaccinationFormNameLabel;

  /// No description provided for @vaccinationFormNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Rage, CHPPiL...'**
  String get vaccinationFormNameHint;

  /// No description provided for @vaccinationFormNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom du vaccin est obligatoire.'**
  String get vaccinationFormNameRequired;

  /// No description provided for @vaccinationFormDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date du vaccin *'**
  String get vaccinationFormDateLabel;

  /// No description provided for @vaccinationFormNextDueDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine échéance (facultatif)'**
  String get vaccinationFormNextDueDateLabel;

  /// No description provided for @vaccinationFormClearDueDateTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Effacer l\'échéance'**
  String get vaccinationFormClearDueDateTooltip;

  /// No description provided for @vaccinationFormSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter le vaccin'**
  String get vaccinationFormSubmit;

  /// No description provided for @treatmentsListTitle.
  ///
  /// In fr, this message translates to:
  /// **'Traitements'**
  String get treatmentsListTitle;

  /// No description provided for @treatmentsListTitleWithName.
  ///
  /// In fr, this message translates to:
  /// **'Traitements de {name}'**
  String treatmentsListTitleWithName(String name);

  /// No description provided for @treatmentsListAddTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un traitement'**
  String get treatmentsListAddTooltip;

  /// No description provided for @treatmentsListEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun traitement enregistré'**
  String get treatmentsListEmptyTitle;

  /// No description provided for @treatmentsListEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Appuie sur + pour ajouter un vermifuge ou un antiparasitaire, même fait il y a longtemps.'**
  String get treatmentsListEmptyMessage;

  /// No description provided for @treatmentFormAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un traitement'**
  String get treatmentFormAddTitle;

  /// No description provided for @treatmentFormEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le traitement'**
  String get treatmentFormEditTitle;

  /// No description provided for @treatmentFormNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Traitement introuvable.'**
  String get treatmentFormNotFound;

  /// No description provided for @treatmentFormNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du traitement *'**
  String get treatmentFormNameLabel;

  /// No description provided for @treatmentFormNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Bravecto, Vermifuge...'**
  String get treatmentFormNameHint;

  /// No description provided for @treatmentFormNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom du traitement est obligatoire.'**
  String get treatmentFormNameRequired;

  /// No description provided for @treatmentFormStartDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de début du traitement *'**
  String get treatmentFormStartDateLabel;

  /// No description provided for @treatmentFormLastDoseDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de la dernière administration *'**
  String get treatmentFormLastDoseDateLabel;

  /// No description provided for @treatmentFormFrequencyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fréquence *'**
  String get treatmentFormFrequencyLabel;

  /// No description provided for @treatmentFormReminderTimeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Heure de rappel *'**
  String get treatmentFormReminderTimeLabel;

  /// No description provided for @treatmentFormReminderTimesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Heures de rappel *'**
  String get treatmentFormReminderTimesLabel;

  /// No description provided for @treatmentFormChooseTime.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une heure'**
  String get treatmentFormChooseTime;

  /// No description provided for @treatmentFormRemoveTimeTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Retirer cette heure'**
  String get treatmentFormRemoveTimeTooltip;

  /// No description provided for @treatmentFormAddTime.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une heure'**
  String get treatmentFormAddTime;

  /// No description provided for @treatmentFormNextReminderLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prochain rappel : {description}'**
  String treatmentFormNextReminderLabel(String description);

  /// No description provided for @treatmentFormNextDueDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine échéance : {date}'**
  String treatmentFormNextDueDateLabel(String date);

  /// No description provided for @treatmentFormMissingReminderTime.
  ///
  /// In fr, this message translates to:
  /// **'Choisis au moins une heure de rappel.'**
  String get treatmentFormMissingReminderTime;

  /// No description provided for @treatmentFormSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter le traitement'**
  String get treatmentFormSubmit;

  /// No description provided for @treatmentFormFrequencyMonthly.
  ///
  /// In fr, this message translates to:
  /// **'1 mois'**
  String get treatmentFormFrequencyMonthly;

  /// No description provided for @treatmentFormFrequencyQuarterly.
  ///
  /// In fr, this message translates to:
  /// **'3 mois'**
  String get treatmentFormFrequencyQuarterly;

  /// No description provided for @treatmentFormFrequencyBiannual.
  ///
  /// In fr, this message translates to:
  /// **'6 mois'**
  String get treatmentFormFrequencyBiannual;

  /// No description provided for @treatmentFormFrequencyAnnual.
  ///
  /// In fr, this message translates to:
  /// **'1 an'**
  String get treatmentFormFrequencyAnnual;

  /// No description provided for @treatmentFormFrequencyDaily.
  ///
  /// In fr, this message translates to:
  /// **'1×/jour'**
  String get treatmentFormFrequencyDaily;

  /// No description provided for @treatmentFormFrequencySeveralTimesDaily.
  ///
  /// In fr, this message translates to:
  /// **'Plusieurs/jour'**
  String get treatmentFormFrequencySeveralTimesDaily;

  /// No description provided for @notificationPermissionBannerText.
  ///
  /// In fr, this message translates to:
  /// **'Rappels désactivés — active-les dans les réglages'**
  String get notificationPermissionBannerText;

  /// No description provided for @notificationPrimingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Activer les rappels'**
  String get notificationPrimingTitle;

  /// No description provided for @notificationPrimingHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Ne rate plus jamais un rappel'**
  String get notificationPrimingHeadline;

  /// No description provided for @notificationPrimingBody.
  ///
  /// In fr, this message translates to:
  /// **'MémoPatte peut te prévenir quand un vaccin ou un vermifuge approche de son échéance. Autorise les notifications pour ne rien oublier — tu pourras changer d\'avis à tout moment dans les réglages de ton téléphone.'**
  String get notificationPrimingBody;

  /// No description provided for @notificationPrimingActivate.
  ///
  /// In fr, this message translates to:
  /// **'Activer les rappels'**
  String get notificationPrimingActivate;

  /// No description provided for @notificationPrimingLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get notificationPrimingLater;

  /// No description provided for @dueStatusUpToDate.
  ///
  /// In fr, this message translates to:
  /// **'À jour'**
  String get dueStatusUpToDate;

  /// No description provided for @dueStatusDueSoon.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get dueStatusDueSoon;

  /// No description provided for @dueStatusOverdue.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get dueStatusOverdue;

  /// No description provided for @animalSpeciesDog.
  ///
  /// In fr, this message translates to:
  /// **'Chien'**
  String get animalSpeciesDog;

  /// No description provided for @animalSpeciesCat.
  ///
  /// In fr, this message translates to:
  /// **'Chat'**
  String get animalSpeciesCat;

  /// No description provided for @animalFormNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom *'**
  String get animalFormNameLabel;

  /// No description provided for @animalFormNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est obligatoire.'**
  String get animalFormNameRequired;

  /// No description provided for @animalFormSpeciesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Espèce *'**
  String get animalFormSpeciesLabel;

  /// No description provided for @animalFormSpeciesRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisis une espèce.'**
  String get animalFormSpeciesRequired;

  /// No description provided for @animalFormBreedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Race (facultatif)'**
  String get animalFormBreedLabel;

  /// No description provided for @animalFormWeightLabel.
  ///
  /// In fr, this message translates to:
  /// **'Poids initial en kg (facultatif)'**
  String get animalFormWeightLabel;

  /// No description provided for @animalFormWeightInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Poids invalide.'**
  String get animalFormWeightInvalid;

  /// No description provided for @animalFormBirthDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance (facultatif)'**
  String get animalFormBirthDateLabel;

  /// No description provided for @animalFormBirthDateNotProvided.
  ///
  /// In fr, this message translates to:
  /// **'Non renseignée'**
  String get animalFormBirthDateNotProvided;

  /// No description provided for @createAnimalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un profil animal'**
  String get createAnimalTitle;

  /// No description provided for @createAnimalSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Créer le profil'**
  String get createAnimalSubmit;

  /// No description provided for @animalNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Animal introuvable.'**
  String get animalNotFound;

  /// No description provided for @profileSpeciesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Espèce'**
  String get profileSpeciesLabel;

  /// No description provided for @profileBreedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Race'**
  String get profileBreedLabel;

  /// No description provided for @profileBirthDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get profileBirthDateLabel;

  /// No description provided for @profileWeightLabel.
  ///
  /// In fr, this message translates to:
  /// **'Poids initial'**
  String get profileWeightLabel;

  /// No description provided for @animalProfileWeightValue.
  ///
  /// In fr, this message translates to:
  /// **'{weight} kg'**
  String animalProfileWeightValue(String weight);

  /// No description provided for @vaccinationsSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vaccins'**
  String get vaccinationsSectionTitle;

  /// No description provided for @treatmentsSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Traitement en cours'**
  String get treatmentsSectionTitle;

  /// No description provided for @remindersCountLabel.
  ///
  /// In fr, this message translates to:
  /// **'rappel(s)'**
  String get remindersCountLabel;

  /// No description provided for @vaccinesEmptyCta.
  ///
  /// In fr, this message translates to:
  /// **'Aucun vaccin enregistré — appuie pour en ajouter un.'**
  String get vaccinesEmptyCta;

  /// No description provided for @treatmentsEmptyCta.
  ///
  /// In fr, this message translates to:
  /// **'Aucun traitement enregistré — appuie pour en ajouter un.'**
  String get treatmentsEmptyCta;

  /// No description provided for @animalAgeLessThanMonth.
  ///
  /// In fr, this message translates to:
  /// **'moins d\'un mois'**
  String get animalAgeLessThanMonth;

  /// No description provided for @animalAgeMonths.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{{count} mois} other{{count} mois}}'**
  String animalAgeMonths(int count);

  /// No description provided for @animalAgeYears.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 an} other{{count} ans}}'**
  String animalAgeYears(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
