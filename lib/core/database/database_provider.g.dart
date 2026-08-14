// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Instance unique de [AppDatabase] pour toute l'app.
///
/// `keepAlive: true` explicite : une connexion sqlite ne doit pas être
/// fermée/rouverte au gré des écrans qui l'observent ou non (comportement
/// par défaut d'un provider `autoDispose`) — elle vit tant que l'app
/// tourne, et n'est fermée que si le provider est explicitement recréé
/// (tests, par exemple).

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// Instance unique de [AppDatabase] pour toute l'app.
///
/// `keepAlive: true` explicite : une connexion sqlite ne doit pas être
/// fermée/rouverte au gré des écrans qui l'observent ou non (comportement
/// par défaut d'un provider `autoDispose`) — elle vit tant que l'app
/// tourne, et n'est fermée que si le provider est explicitement recréé
/// (tests, par exemple).

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// Instance unique de [AppDatabase] pour toute l'app.
  ///
  /// `keepAlive: true` explicite : une connexion sqlite ne doit pas être
  /// fermée/rouverte au gré des écrans qui l'observent ou non (comportement
  /// par défaut d'un provider `autoDispose`) — elle vit tant que l'app
  /// tourne, et n'est fermée que si le provider est explicitement recréé
  /// (tests, par exemple).
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'44154e51c3f3079ee293d8ad0ebd1e17cca871ed';
