// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_tracking_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentScreenHash() => r'98cfb91fddc07f2c46ca2f01d7e3929e49ff5113';

/// ViewModel for tracking the current screen path
/// Used to suppress notifications and manage screen-specific behavior
///
/// Copied from [CurrentScreen].
@ProviderFor(CurrentScreen)
final currentScreenProvider =
    AutoDisposeNotifierProvider<CurrentScreen, String?>.internal(
      CurrentScreen.new,
      name: r'currentScreenProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentScreenHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentScreen = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
