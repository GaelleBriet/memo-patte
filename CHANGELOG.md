# Changelog

## [1.8.0](https://github.com/GaelleBriet/memo-patte/compare/memo_patte-v1.7.0...memo_patte-v1.8.0) (2026-08-21)


### ✨ Fonctionnalités

* add `flutter_localizations` and `intl` dependencies to prepare i18n infrastructure ([5049287](https://github.com/GaelleBriet/memo-patte/commit/504928782a6d4d0d3637b194027c9e8c85821e05))
* add English and French localization files with home greeting translations ([89eab5d](https://github.com/GaelleBriet/memo-patte/commit/89eab5d61c147ecd7144c617d982e45991e316fa))
* add English and French translations ([cfca127](https://github.com/GaelleBriet/memo-patte/commit/cfca127481958ca3f1a03a813af7bba40bef0932))
* add English translations for common actions, animal form, profile details, and related labels ([8c432b2](https://github.com/GaelleBriet/memo-patte/commit/8c432b2b5ed2b1c0572e62fcb889d398d6b84157))
* add English translations for home screen, navigation, common actions, and confirmation messages ([ea73efe](https://github.com/GaelleBriet/memo-patte/commit/ea73efe9ecea20f037ef506fbc360195bd5f1933))
* add example `key.properties` template for release signing configuration ([a9f6ec0](https://github.com/GaelleBriet/memo-patte/commit/a9f6ec051794e4dc357d4e7d054b245370731d41))
* add French and English translations ([bdd64af](https://github.com/GaelleBriet/memo-patte/commit/bdd64afea91226f36514f96d7dfd40b45aaed881))
* add French and English translations for notification permission banner and priming texts ([f062cf4](https://github.com/GaelleBriet/memo-patte/commit/f062cf4987b2c07b3293c802c9c8c46c9cbf257c))
* add French and English translations for notification priming texts ([8b4959e](https://github.com/GaelleBriet/memo-patte/commit/8b4959e0976e0055ab9f9379cc5b9485cd482610))
* add French and English translations for treatment form fields and labels ([cf8c02f](https://github.com/GaelleBriet/memo-patte/commit/cf8c02f8f6e21fb80870f5ff8962e886e7ef4bb7))
* add French and English translations for vaccination and treatment form screens ([01db3bb](https://github.com/GaelleBriet/memo-patte/commit/01db3bbb508b065e1c5cd375964f8de7adce0805))
* add French and English translations for vaccination form fields ([53b6b81](https://github.com/GaelleBriet/memo-patte/commit/53b6b81ccfd7d38c3c292e8f012fec9bcd154737))
* add French and English translations for vaccinations and treatments screens ([878cf5d](https://github.com/GaelleBriet/memo-patte/commit/878cf5d69dd1801daba169758b295b598e08b909))
* add French translations for common actions, animal form, profile, and related labels ([139e7a1](https://github.com/GaelleBriet/memo-patte/commit/139e7a1dace83e3dd32e061d76a4ee7f7e391db6))
* add French translations for home screen, navigation, common actions, and confirmation messages ([8971272](https://github.com/GaelleBriet/memo-patte/commit/8971272dba016c92c008e04367ca2bf130b1526d))
* add localized strings for common actions, animal form, profile, and related sections ([296b5e5](https://github.com/GaelleBriet/memo-patte/commit/296b5e5c344b50b04910949a6321ff9c1abeefc8))
* add localized test app utility with pinned French locale for i18n testing ([98cddbe](https://github.com/GaelleBriet/memo-patte/commit/98cddbe082c7a270e76d3a62d6130383e26a444a))
* add minimal structured logging utility using `dart:developer` ([f727dcc](https://github.com/GaelleBriet/memo-patte/commit/f727dccd9949afc13f6fb4b7a7f392ca2372c9ef))
* add permission for exact alarms in AndroidManifest, supporting fixed-time reminders ([a5ae8f8](https://github.com/GaelleBriet/memo-patte/commit/a5ae8f8596b6e4a858b509df44c659cc9bb1b7ee))
* add regression tests and defensive checks for handling invalid route IDs and navigation fallback ([e565003](https://github.com/GaelleBriet/memo-patte/commit/e565003b2dd8ff2f431a89c3f9872bcfb5d1ddc6))
* centralize app name in resources for localization support and consistency across platforms ([71ebb82](https://github.com/GaelleBriet/memo-patte/commit/71ebb826905b39dba840ed2b2a4898b7549a7228))
* configure `flutter gen-l10n` with French as the source language ([f6c2c03](https://github.com/GaelleBriet/memo-patte/commit/f6c2c03a8528dc93862aa9606426c935eb3fb1c0))
* configure Flutter localization with pinned French locale, preparing for future bilingual support ([ae1002e](https://github.com/GaelleBriet/memo-patte/commit/ae1002e613f74832e6fd917a65c8447497a25abd))
* create reusable `ErrorDisplay` widget with structured logging and retry support ([6399912](https://github.com/GaelleBriet/memo-patte/commit/6399912ef5374fa0923052a7b4cd2bf17ccb15a2))
* enhance CI to ensure up-to-date generated files, test coverage upload, and APK build ([144de19](https://github.com/GaelleBriet/memo-patte/commit/144de19ffe61c5d16719f38ee6409333f24c7b91))
* generate base localization files with English and French support for `AppLocalizations` ([d17ba2e](https://github.com/GaelleBriet/memo-patte/commit/d17ba2e66d9285d4fd5e442b52b6c4439caf9d7b))
* implement release signing scaffold and update CI to follow `.fvmrc` for Flutter version ([6d566d0](https://github.com/GaelleBriet/memo-patte/commit/6d566d070ee1327025b74a28889484d31e6c0c9a))
* integrate i18n for `AnimalSpecies` labels using `AppLocalizations` ([e22cb39](https://github.com/GaelleBriet/memo-patte/commit/e22cb390ed9659ca1e27cc301485d9653c95e609))
* localize `DueStatus` labels using `AppLocalizations` with `BuildContext` ([393dc36](https://github.com/GaelleBriet/memo-patte/commit/393dc368dffa69266957b936efbd616d38497648))
* localize animal age formatting in profile using `AppLocalizations` ([f3ee95d](https://github.com/GaelleBriet/memo-patte/commit/f3ee95d623423e1e3a76d832bc39a610267dfd19))
* localize animal form and profile fields using `AppLocalizations` ([73df0ba](https://github.com/GaelleBriet/memo-patte/commit/73df0ba0af5fe2eb07bfdb75f9bbfaa7f82d5892))
* localize bottom navigation bar labels using `AppLocalizations` ([cf60cdd](https://github.com/GaelleBriet/memo-patte/commit/cf60cddc263112ac0f0581db57a7f8baf803352b))
* localize create animal screen using `AppLocalizations` ([017a072](https://github.com/GaelleBriet/memo-patte/commit/017a072dcd1e7b54a50828074145984c91ec91d8))
* localize delete confirmation sheet actions using `AppLocalizations` ([5dbbd02](https://github.com/GaelleBriet/memo-patte/commit/5dbbd02448010d6a0fbe74ec3b516abd4120df89))
* localize error display widget using `AppLocalizations` ([a50fd1c](https://github.com/GaelleBriet/memo-patte/commit/a50fd1c9b11e8e0c7d2330b578a537dbfe295477))
* localize home screen, treatment, and vaccination card widgets using `AppLocalizations` ([429b0b9](https://github.com/GaelleBriet/memo-patte/commit/429b0b9d7ddccacfa73271b3d6f49607774ea5fe))
* localize reminders and notifications for vaccinations and treatments ([8913ae4](https://github.com/GaelleBriet/memo-patte/commit/8913ae48bbd89fda35ae0783b7d8e25f9588a896))
* localize treatment and vaccination form screens using `AppLocalizations` for titles and messages ([f6746f7](https://github.com/GaelleBriet/memo-patte/commit/f6746f7c675fdfb168b6ac28e680ad1ba2712c9b))
* localize treatment card due date labels using `AppLocalizations` ([03a47d0](https://github.com/GaelleBriet/memo-patte/commit/03a47d002be28740e48dc30888b874073594b421))
* localize treatment notification titles and bodies using `AppLocalizations` ([20e3424](https://github.com/GaelleBriet/memo-patte/commit/20e3424f88530a83d20cc3ef76c04693e2044b1e))
* localize treatments and vaccinations list screens using `AppLocalizations` ([3f64fb8](https://github.com/GaelleBriet/memo-patte/commit/3f64fb8eaed9cf721a9ce31eef2012190c03951c))
* localize treatments list and vaccination form screens using `AppLocalizations` ([a9016d5](https://github.com/GaelleBriet/memo-patte/commit/a9016d5865ac1199b97a166dad8fee18646b435c))
* support exact alarm scheduling for fixed-time reminders, including fallback for missing permissions ([6a8a5b4](https://github.com/GaelleBriet/memo-patte/commit/6a8a5b4d0d1a36ef79ccdcbccbe8900b08c47ec4))

## [1.7.0](https://github.com/GaelleBriet/memo-patte/compare/memo_patte-v1.6.0...memo_patte-v1.7.0) (2026-08-21)


### ✨ Fonctionnalités

* add defensive checks for column existence during migration to prevent duplicate column errors ([33d1337](https://github.com/GaelleBriet/memo-patte/commit/33d13371952f61530cb65fa4beb37c3ff2558ac2))
* add regression tests for migration handling and first animal creation ([80b3487](https://github.com/GaelleBriet/memo-patte/commit/80b3487879477f05e3ba348095e4b8798802a86b))
* handle navigation fallback after creating the first animal to prevent crashes ([6999407](https://github.com/GaelleBriet/memo-patte/commit/6999407a2f507b03178e7c9e75045602fe1f75f0))

## [1.6.0](https://github.com/GaelleBriet/memo-patte/compare/memo_patte-v1.5.0...memo_patte-v1.6.0) (2026-08-17)


### ✨ Fonctionnalités

* add deleteVaccination method and tests to handle vaccination deletion with notification cancellation ([c40fa8a](https://github.com/GaelleBriet/memo-patte/commit/c40fa8a88778bca90fc49c3ca856f01b06fd309c))
* add isFirstReminderSource function to determine initial vaccination or treatment status ([a27582e](https://github.com/GaelleBriet/memo-patte/commit/a27582e99caf7e370b2f68ea27015f6125b3e400))
* add long press delete functionality and confirmation for vaccination cards ([458d3e2](https://github.com/GaelleBriet/memo-patte/commit/458d3e228d83d115177074e6bc69c320f1e8997f))
* add long press delete functionality for reminders in home screen ([8644495](https://github.com/GaelleBriet/memo-patte/commit/864449500d285e95fe20a4b81ea7d7747383c664))
* add long press functionality and delete confirmation sheet for treatments ([dfaf06c](https://github.com/GaelleBriet/memo-patte/commit/dfaf06c67ebd315e327c2c1edbc87da6e2092229))
* add matchDateTimeComponents parameter for scheduling recurring notifications ([7329072](https://github.com/GaelleBriet/memo-patte/commit/73290727722b4171e957c923fb1373a147e885c1))
* add reminder times handling for daily treatments ([e970f62](https://github.com/GaelleBriet/memo-patte/commit/e970f625f33c12d14ecc0faad07c846db378fd28))
* add reminderTimeLabel to home reminder model for daily treatments ([d95fd93](https://github.com/GaelleBriet/memo-patte/commit/d95fd937705e644ed028d731407a6d1fbbef93c1))
* add reminderTimeLabel to home reminders for treatments ([dec543d](https://github.com/GaelleBriet/memo-patte/commit/dec543ddf4a70664a05c4db47292331f40a27797))
* add reminderTimePill widget to display reminder time label in home screen ([68ae8c2](https://github.com/GaelleBriet/memo-patte/commit/68ae8c2410395e1701f8a9b5b48049864ab6c532))
* add reminderTimes and reminderNotificationIds to Treatments table ([42bc9f7](https://github.com/GaelleBriet/memo-patte/commit/42bc9f70b34dffaa2d94c2499ebbc81ead1dc899))
* add tests for daily treatment reminder time handling and validation ([48f5b17](https://github.com/GaelleBriet/memo-patte/commit/48f5b1700471a33194afe97efaa4e7ef455f3ce6))
* add tests for reminder times handling and treatment scheduling ([742900d](https://github.com/GaelleBriet/memo-patte/commit/742900df0f8c767c77c7c08fac1f5556f480bb64))
* add TreatmentCard and TreatmentFormScreen for managing treatments ([e9c679a](https://github.com/GaelleBriet/memo-patte/commit/e9c679ad1a0e6b60884fc4f35822e9aaa5220d73))
* add TreatmentFrequency enum and tests for treatment scheduling ([71b1c6d](https://github.com/GaelleBriet/memo-patte/commit/71b1c6d4c97aa5c3ee06ccaeb72623444663d045))
* add Treatments table and routing for treatment management ([0823d85](https://github.com/GaelleBriet/memo-patte/commit/0823d85bdf97e888f0df9438d243aa6191863e99))
* extend TreatmentFrequency to include daily and severalTimesDaily options ([d02dd81](https://github.com/GaelleBriet/memo-patte/commit/d02dd819440685b997f7df0b3f29b929755b8ea9))
* implement reminder times handling for daily treatments ([4807b6b](https://github.com/GaelleBriet/memo-patte/commit/4807b6bc09b8b4aa7cc5d4e37efc43976a8ddcd0))
* implement TreatmentDao and TreatmentRepository for managing animal treatments ([d58b5eb](https://github.com/GaelleBriet/memo-patte/commit/d58b5eb442f8ce23fadb0e0b222e614a64b25fbb))
* improve formatting and readability in reminder times and treatment frequency handling ([b825e41](https://github.com/GaelleBriet/memo-patte/commit/b825e41d1cdb511ba54492a9d6eb6f39f8c2cae8))
* integrate treatment reminders into animal profile screen and home reminders ([d119f5b](https://github.com/GaelleBriet/memo-patte/commit/d119f5b486d8183be92d26f02a57ab9d8df1a2f6))
* merge vaccination and treatment reminders in home reminders provider ([67ebdb7](https://github.com/GaelleBriet/memo-patte/commit/67ebdb7b50561a8cdd81b75ff8679951cffec906))
* refactor HomeScreen to use DueStatus and enhance quick action cards for treatments and vaccinations ([94be681](https://github.com/GaelleBriet/memo-patte/commit/94be681d81a36996bf32288f40c109777c8b4b09))
* refactor VaccinationStatus to alias DueStatus for consistency ([61d21a1](https://github.com/GaelleBriet/memo-patte/commit/61d21a11c38551738852b01ee8b7e7c6470ad221))
* update nextDueDate calculation and add matchDateTimeComponents parameter ([ebbdd53](https://github.com/GaelleBriet/memo-patte/commit/ebbdd5376330132cad2e28c2a251411fae8c5360))

## [1.5.0](https://github.com/GaelleBriet/memo-patte/compare/memo_patte-v1.4.0...memo_patte-v1.5.0) (2026-08-15)


### ✨ Fonctionnalités

* add HomeReminder model for upcoming vaccination reminders ([48ae0ea](https://github.com/GaelleBriet/memo-patte/commit/48ae0ea6c557dd3b0f54df7e1b480a31c1559c13))
* add LightStatusBar and StraddlingHero widgets for improved UI layout ([d162083](https://github.com/GaelleBriet/memo-patte/commit/d162083d1e29d9b38956ae89382ff1f01d6d6c8c))
* add unit tests for home reminders provider functionality ([175737b](https://github.com/GaelleBriet/memo-patte/commit/175737b43d9626b1fd476eec5979c3f352930cfe))
* implement home reminders provider for upcoming and overdue vaccinations ([efbdec0](https://github.com/GaelleBriet/memo-patte/commit/efbdec007ba3bff8e0ba49c43f06fd38fcda4afb))
* implement persistent navigation shell with home and animal profile tabs ([12b11dd](https://github.com/GaelleBriet/memo-patte/commit/12b11dd471d053808af3873d893e20a8e992836a))
* redesign animal profile screen with health record features and improved navigation ([d132aff](https://github.com/GaelleBriet/memo-patte/commit/d132aff2dd1e46bc804338663b8ba6ab49f92a24))
* refactor code for improved readability and formatting in multiple files ([b789597](https://github.com/GaelleBriet/memo-patte/commit/b789597fb89be7cb41764b3fd44844b19eed47c5))
* refactor vaccination screens to use VaccinationCard component ([4f5199f](https://github.com/GaelleBriet/memo-patte/commit/4f5199f89b184da47e6342344742ddc32a37d1e6))
* update design guidelines and reusable components documentation ([208343d](https://github.com/GaelleBriet/memo-patte/commit/208343de4f1b9a6f769441c9bb2d9e3f46e5d358))

## [1.4.0](https://github.com/GaelleBriet/memo-patte/compare/memo_patte-v1.3.0...memo_patte-v1.4.0) (2026-08-15)


### ✨ Fonctionnalités

* add vaccination form screen and related tests ([c890a35](https://github.com/GaelleBriet/memo-patte/commit/c890a3561a0028c784e0587c107e1538a4e94873))
* add vaccination status enum and related tests ([625b477](https://github.com/GaelleBriet/memo-patte/commit/625b47717727bb63cdf0cebba3fd51440e8d44ea))
* add vaccinations table and related data access logic ([65a9f56](https://github.com/GaelleBriet/memo-patte/commit/65a9f567cb27b535d665f23e193d71ba26bbbede))
* enhance animal profile and list screens with gradient app bar and surface cards ([1612569](https://github.com/GaelleBriet/memo-patte/commit/1612569250d9bab47a1e78f4b0d56d0a6d3a5454))
* implement vaccination data access and repository logic ([7d89c57](https://github.com/GaelleBriet/memo-patte/commit/7d89c57f7b36ee168a58c9c59a54a7cd12c93e7e))

## [1.3.0](https://github.com/GaelleBriet/memo-patte/compare/memo_patte-v1.2.0...memo_patte-v1.3.0) (2026-08-15)


### ✨ Fonctionnalités

* add notification permission banner and associated tests ([a655a54](https://github.com/GaelleBriet/memo-patte/commit/a655a548b44a49a371685e671ac946322e3ecc84))
* add notification permission handling and settings access ([a68c9f8](https://github.com/GaelleBriet/memo-patte/commit/a68c9f8347072ff9c05b748f26d3834a51318623))
* add notification priming screen and permission banner to router ([b87eb40](https://github.com/GaelleBriet/memo-patte/commit/b87eb40b0a5d24f0eea78cac5174dc209399b64d))
* implement notification permission provider and priming screen ([717ef51](https://github.com/GaelleBriet/memo-patte/commit/717ef5183193c814a2cd5e2826822da0ab9efb0c))

## [1.2.0](https://github.com/GaelleBriet/memo-patte/compare/memo_patte-v1.1.0...memo_patte-v1.2.0) (2026-08-15)


### ✨ Fonctionnalités

* add AnimalFormFields and AnimalProfileScreen for animal profile management ([7e9d05d](https://github.com/GaelleBriet/memo-patte/commit/7e9d05dfb29be7419eda53ec53237ccad0214aa2))
* add unit tests for animal repository CRUD operations ([4504b36](https://github.com/GaelleBriet/memo-patte/commit/4504b3638f20a84b96552f29b83f8be8eb889b98))
* implement animal profile navigation and refactor animal creation form ([d8835cc](https://github.com/GaelleBriet/memo-patte/commit/d8835cc441bac70b48388ce909d3331c1a2528e0))
* implement PreToolUse guard to restrict dangerous commands in Bash ([cc7e52d](https://github.com/GaelleBriet/memo-patte/commit/cc7e52d1aaf3b2da4f51daba6ea36c5b93be2602))
* update animal repository to allow null values for optional fields in updates ([14a80df](https://github.com/GaelleBriet/memo-patte/commit/14a80df2b7daca0e05f755b9e1b88164c5c77add))

## [1.1.0](https://github.com/GaelleBriet/memo-patte/compare/memo_patte-v1.0.0...memo_patte-v1.1.0) (2026-08-14)


### ✨ Fonctionnalités

* add AnimalRepositoryProvider for managing animal data ([8d75d6e](https://github.com/GaelleBriet/memo-patte/commit/8d75d6edb6490dd27851636252876817ebffbc76))
* add AnimalsListScreen and provider for displaying animal list ([6c4bb16](https://github.com/GaelleBriet/memo-patte/commit/6c4bb162940a5b867e364aea123f738e5c8d2542))
* add AppDatabase provider for managing SQLite connections ([71cc7a2](https://github.com/GaelleBriet/memo-patte/commit/71cc7a2f9e12516560656ff9788373b55628e3ee))
* add CreateAnimalScreen for animal profile creation ([07f05e6](https://github.com/GaelleBriet/memo-patte/commit/07f05e6eae766353c822aa0b36c8a92def3777a4))
* add routing for CreateAnimalScreen and temporary entry point ([00126a9](https://github.com/GaelleBriet/memo-patte/commit/00126a91b4f0c57d9e96e2c6b3c93bfa5d45d191))
* configure build.yaml to ensure drift_dev runs before riverpod_generator ([e6cde0c](https://github.com/GaelleBriet/memo-patte/commit/e6cde0c901ccadddc83c6672d05af6426a2f4193))
* update animal species handling and routing for animal screens ([63dcc00](https://github.com/GaelleBriet/memo-patte/commit/63dcc000fd65705f5f31ec57cca98e7c61017418))
