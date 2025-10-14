// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchViewModelHash() => r'55b9434f31c6ea74eff829eb4aac92a59fde9a3f';

/// ViewModel for managing message search with group-scoped filtering
/// Implements debouncing and hybrid cache/cloud search strategy
///
/// Copied from [SearchViewModel].
@ProviderFor(SearchViewModel)
final searchViewModelProvider =
    AutoDisposeNotifierProvider<SearchViewModel, SearchState>.internal(
      SearchViewModel.new,
      name: r'searchViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SearchViewModel = AutoDisposeNotifier<SearchState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
