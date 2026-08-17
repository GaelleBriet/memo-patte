// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treatment_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Même durée de vie que [appDatabaseProvider], pour les mêmes raisons
/// que `vaccination_repository_provider.dart`.

@ProviderFor(treatmentRepository)
final treatmentRepositoryProvider = TreatmentRepositoryProvider._();

/// Même durée de vie que [appDatabaseProvider], pour les mêmes raisons
/// que `vaccination_repository_provider.dart`.

final class TreatmentRepositoryProvider
    extends
        $FunctionalProvider<
          TreatmentRepository,
          TreatmentRepository,
          TreatmentRepository
        >
    with $Provider<TreatmentRepository> {
  /// Même durée de vie que [appDatabaseProvider], pour les mêmes raisons
  /// que `vaccination_repository_provider.dart`.
  TreatmentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'treatmentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$treatmentRepositoryHash();

  @$internal
  @override
  $ProviderElement<TreatmentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TreatmentRepository create(Ref ref) {
    return treatmentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TreatmentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TreatmentRepository>(value),
    );
  }
}

String _$treatmentRepositoryHash() =>
    r'3243281349c967de7c6cbf0e3d6ce9605c50d78c';
