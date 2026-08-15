// `StateProvider` est dans l'export "legacy" de Riverpod 3 (l'API
// courante encourage `Notifier`/`AsyncNotifier`) — largement suffisant
// ici : un entier nullable modifiable de l'extérieur, sans logique
// propre qui justifierait une classe dédiée.
import 'package:flutter_riverpod/legacy.dart';

/// Animal "courant" de l'app — celui sur lequel l'accueil (ticket 6.2) et
/// le Carnet de santé (ticket 6.4) sont centrés, et vers lequel le tap
/// sur l'onglet Carnet de la barre du bas (ticket 6.0) navigue.
///
/// `null` tant que l'utilisateur n'a pas explicitement choisi un animal
/// (via un chip) — les écrans qui le consomment retombent alors sur "le
/// premier animal créé" (décision du 2026-08-15), pas géré ici pour ne
/// pas dupliquer la liste des animaux dans ce provider.
final selectedAnimalIdProvider = StateProvider<int?>((ref) => null);
