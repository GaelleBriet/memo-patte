// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccination_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Même durée de vie que [appDatabaseProvider], pour les mêmes raisons
/// que `animal_repository_provider.dart`.

@ProviderFor(vaccinationRepository)
final vaccinationRepositoryProvider = VaccinationRepositoryProvider._();

/// Même durée de vie que [appDatabaseProvider], pour les mêmes raisons
/// que `animal_repository_provider.dart`.

final class VaccinationRepositoryProvider
    extends
        $FunctionalProvider<
          VaccinationRepository,
          VaccinationRepository,
          VaccinationRepository
        >
    with $Provider<VaccinationRepository> {
  /// Même durée de vie que [appDatabaseProvider], pour les mêmes raisons
  /// que `animal_repository_provider.dart`.
  VaccinationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaccinationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaccinationRepositoryHash();

  @$internal
  @override
  $ProviderElement<VaccinationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VaccinationRepository create(Ref ref) {
    return vaccinationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VaccinationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VaccinationRepository>(value),
    );
  }
}

String _$vaccinationRepositoryHash() =>
    r'5ee8b47f45038c13ef78e376b7b1d97fe6ee27e9';
