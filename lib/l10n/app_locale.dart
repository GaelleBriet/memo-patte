import 'package:flutter/widgets.dart' show Locale;

import 'generated/app_localizations.dart';

/// Accès à [AppLocalizations] hors arbre de widgets (`BuildContext`
/// indisponible) — typiquement le contenu des notifications programmées
/// depuis la couche données (`VaccinationRepository`, `TreatmentRepository`),
/// qui n'ont et ne doivent pas avoir de dépendance à un `BuildContext`.
///
/// `lookupAppLocalizations` (généré par l'outil `flutter gen-l10n`) est
/// prévu exactement pour ce cas — c'est la même fonction que
/// `AppLocalizations.delegate` appelle en interne une fois la locale
/// résolue. Locale figée sur `Locale('fr')` ici, cohérente avec le
/// `locale: const Locale('fr')` pinné dans `main.dart` (voir son
/// commentaire) : le jour où l'app suit vraiment la langue système ou un
/// choix utilisateur, cette fonction devra lire la même source que
/// `main.dart` plutôt qu'une constante séparée.
AppLocalizations appLocalizations() =>
    lookupAppLocalizations(const Locale('fr'));
