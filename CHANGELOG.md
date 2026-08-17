# Changelog

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
