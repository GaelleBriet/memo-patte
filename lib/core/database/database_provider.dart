import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_database.dart';

part 'database_provider.g.dart';

/// Instance unique de [AppDatabase] pour toute l'app.
///
/// `keepAlive: true` explicite : une connexion sqlite ne doit pas être
/// fermée/rouverte au gré des écrans qui l'observent ou non (comportement
/// par défaut d'un provider `autoDispose`) — elle vit tant que l'app
/// tourne, et n'est fermée que si le provider est explicitement recréé
/// (tests, par exemple).
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}
