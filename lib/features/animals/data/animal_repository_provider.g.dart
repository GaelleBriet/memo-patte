// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Même durée de vie que [appDatabaseProvider] : le repository ne fait
/// qu'envelopper le DAO, pas de raison qu'il soit recréé indépendamment de
/// la connexion à la base.

@ProviderFor(animalRepository)
final animalRepositoryProvider = AnimalRepositoryProvider._();

/// Même durée de vie que [appDatabaseProvider] : le repository ne fait
/// qu'envelopper le DAO, pas de raison qu'il soit recréé indépendamment de
/// la connexion à la base.

final class AnimalRepositoryProvider
    extends
        $FunctionalProvider<
          AnimalRepository,
          AnimalRepository,
          AnimalRepository
        >
    with $Provider<AnimalRepository> {
  /// Même durée de vie que [appDatabaseProvider] : le repository ne fait
  /// qu'envelopper le DAO, pas de raison qu'il soit recréé indépendamment de
  /// la connexion à la base.
  AnimalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'animalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$animalRepositoryHash();

  @$internal
  @override
  $ProviderElement<AnimalRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnimalRepository create(Ref ref) {
    return animalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnimalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnimalRepository>(value),
    );
  }
}

String _$animalRepositoryHash() => r'd73c0315264d21fa052b5a377fabc58311d183f1';
