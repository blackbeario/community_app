// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SearchState {
  /// Current search query
  String get query => throw _privateConstructorUsedError;

  /// Selected group ID for filtering ('all' means search all groups)
  String get selectedGroupId => throw _privateConstructorUsedError;

  /// Search results
  List<Message> get results => throw _privateConstructorUsedError;

  /// Loading state for initial search
  bool get isLoading => throw _privateConstructorUsedError;

  /// Loading state for cloud search fallback
  bool get isSearchingCloud => throw _privateConstructorUsedError;

  /// Offline mode indicator
  bool get isOffline => throw _privateConstructorUsedError;

  /// Error message if search fails
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchStateCopyWith<SearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchStateCopyWith<$Res> {
  factory $SearchStateCopyWith(
    SearchState value,
    $Res Function(SearchState) then,
  ) = _$SearchStateCopyWithImpl<$Res, SearchState>;
  @useResult
  $Res call({
    String query,
    String selectedGroupId,
    List<Message> results,
    bool isLoading,
    bool isSearchingCloud,
    bool isOffline,
    String? error,
  });
}

/// @nodoc
class _$SearchStateCopyWithImpl<$Res, $Val extends SearchState>
    implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? selectedGroupId = null,
    Object? results = null,
    Object? isLoading = null,
    Object? isSearchingCloud = null,
    Object? isOffline = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            query: null == query
                ? _value.query
                : query // ignore: cast_nullable_to_non_nullable
                      as String,
            selectedGroupId: null == selectedGroupId
                ? _value.selectedGroupId
                : selectedGroupId // ignore: cast_nullable_to_non_nullable
                      as String,
            results: null == results
                ? _value.results
                : results // ignore: cast_nullable_to_non_nullable
                      as List<Message>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSearchingCloud: null == isSearchingCloud
                ? _value.isSearchingCloud
                : isSearchingCloud // ignore: cast_nullable_to_non_nullable
                      as bool,
            isOffline: null == isOffline
                ? _value.isOffline
                : isOffline // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchStateImplCopyWith<$Res>
    implements $SearchStateCopyWith<$Res> {
  factory _$$SearchStateImplCopyWith(
    _$SearchStateImpl value,
    $Res Function(_$SearchStateImpl) then,
  ) = __$$SearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String query,
    String selectedGroupId,
    List<Message> results,
    bool isLoading,
    bool isSearchingCloud,
    bool isOffline,
    String? error,
  });
}

/// @nodoc
class __$$SearchStateImplCopyWithImpl<$Res>
    extends _$SearchStateCopyWithImpl<$Res, _$SearchStateImpl>
    implements _$$SearchStateImplCopyWith<$Res> {
  __$$SearchStateImplCopyWithImpl(
    _$SearchStateImpl _value,
    $Res Function(_$SearchStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? selectedGroupId = null,
    Object? results = null,
    Object? isLoading = null,
    Object? isSearchingCloud = null,
    Object? isOffline = null,
    Object? error = freezed,
  }) {
    return _then(
      _$SearchStateImpl(
        query: null == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String,
        selectedGroupId: null == selectedGroupId
            ? _value.selectedGroupId
            : selectedGroupId // ignore: cast_nullable_to_non_nullable
                  as String,
        results: null == results
            ? _value._results
            : results // ignore: cast_nullable_to_non_nullable
                  as List<Message>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSearchingCloud: null == isSearchingCloud
            ? _value.isSearchingCloud
            : isSearchingCloud // ignore: cast_nullable_to_non_nullable
                  as bool,
        isOffline: null == isOffline
            ? _value.isOffline
            : isOffline // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SearchStateImpl implements _SearchState {
  const _$SearchStateImpl({
    this.query = '',
    this.selectedGroupId = 'all',
    final List<Message> results = const [],
    this.isLoading = false,
    this.isSearchingCloud = false,
    this.isOffline = false,
    this.error,
  }) : _results = results;

  /// Current search query
  @override
  @JsonKey()
  final String query;

  /// Selected group ID for filtering ('all' means search all groups)
  @override
  @JsonKey()
  final String selectedGroupId;

  /// Search results
  final List<Message> _results;

  /// Search results
  @override
  @JsonKey()
  List<Message> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  /// Loading state for initial search
  @override
  @JsonKey()
  final bool isLoading;

  /// Loading state for cloud search fallback
  @override
  @JsonKey()
  final bool isSearchingCloud;

  /// Offline mode indicator
  @override
  @JsonKey()
  final bool isOffline;

  /// Error message if search fails
  @override
  final String? error;

  @override
  String toString() {
    return 'SearchState(query: $query, selectedGroupId: $selectedGroupId, results: $results, isLoading: $isLoading, isSearchingCloud: $isSearchingCloud, isOffline: $isOffline, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchStateImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.selectedGroupId, selectedGroupId) ||
                other.selectedGroupId == selectedGroupId) &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSearchingCloud, isSearchingCloud) ||
                other.isSearchingCloud == isSearchingCloud) &&
            (identical(other.isOffline, isOffline) ||
                other.isOffline == isOffline) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    query,
    selectedGroupId,
    const DeepCollectionEquality().hash(_results),
    isLoading,
    isSearchingCloud,
    isOffline,
    error,
  );

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      __$$SearchStateImplCopyWithImpl<_$SearchStateImpl>(this, _$identity);
}

abstract class _SearchState implements SearchState {
  const factory _SearchState({
    final String query,
    final String selectedGroupId,
    final List<Message> results,
    final bool isLoading,
    final bool isSearchingCloud,
    final bool isOffline,
    final String? error,
  }) = _$SearchStateImpl;

  /// Current search query
  @override
  String get query;

  /// Selected group ID for filtering ('all' means search all groups)
  @override
  String get selectedGroupId;

  /// Search results
  @override
  List<Message> get results;

  /// Loading state for initial search
  @override
  bool get isLoading;

  /// Loading state for cloud search fallback
  @override
  bool get isSearchingCloud;

  /// Offline mode indicator
  @override
  bool get isOffline;

  /// Error message if search fails
  @override
  String? get error;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
