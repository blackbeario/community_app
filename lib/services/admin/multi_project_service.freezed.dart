// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'multi_project_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CommunityProject _$CommunityProjectFromJson(Map<String, dynamic> json) {
  return _CommunityProject.fromJson(json);
}

/// @nodoc
mixin _$CommunityProject {
  String get name => throw _privateConstructorUsedError;
  String get projectId => throw _privateConstructorUsedError;
  String? get projectNumber => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get created => throw _privateConstructorUsedError;

  /// Serializes this CommunityProject to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityProject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityProjectCopyWith<CommunityProject> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityProjectCopyWith<$Res> {
  factory $CommunityProjectCopyWith(
    CommunityProject value,
    $Res Function(CommunityProject) then,
  ) = _$CommunityProjectCopyWithImpl<$Res, CommunityProject>;
  @useResult
  $Res call({
    String name,
    String projectId,
    String? projectNumber,
    String status,
    DateTime? created,
  });
}

/// @nodoc
class _$CommunityProjectCopyWithImpl<$Res, $Val extends CommunityProject>
    implements $CommunityProjectCopyWith<$Res> {
  _$CommunityProjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityProject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? projectId = null,
    Object? projectNumber = freezed,
    Object? status = null,
    Object? created = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            projectId: null == projectId
                ? _value.projectId
                : projectId // ignore: cast_nullable_to_non_nullable
                      as String,
            projectNumber: freezed == projectNumber
                ? _value.projectNumber
                : projectNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            created: freezed == created
                ? _value.created
                : created // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityProjectImplCopyWith<$Res>
    implements $CommunityProjectCopyWith<$Res> {
  factory _$$CommunityProjectImplCopyWith(
    _$CommunityProjectImpl value,
    $Res Function(_$CommunityProjectImpl) then,
  ) = __$$CommunityProjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String projectId,
    String? projectNumber,
    String status,
    DateTime? created,
  });
}

/// @nodoc
class __$$CommunityProjectImplCopyWithImpl<$Res>
    extends _$CommunityProjectCopyWithImpl<$Res, _$CommunityProjectImpl>
    implements _$$CommunityProjectImplCopyWith<$Res> {
  __$$CommunityProjectImplCopyWithImpl(
    _$CommunityProjectImpl _value,
    $Res Function(_$CommunityProjectImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityProject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? projectId = null,
    Object? projectNumber = freezed,
    Object? status = null,
    Object? created = freezed,
  }) {
    return _then(
      _$CommunityProjectImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        projectId: null == projectId
            ? _value.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as String,
        projectNumber: freezed == projectNumber
            ? _value.projectNumber
            : projectNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        created: freezed == created
            ? _value.created
            : created // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityProjectImpl implements _CommunityProject {
  const _$CommunityProjectImpl({
    required this.name,
    required this.projectId,
    this.projectNumber,
    this.status = 'active',
    this.created,
  });

  factory _$CommunityProjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityProjectImplFromJson(json);

  @override
  final String name;
  @override
  final String projectId;
  @override
  final String? projectNumber;
  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? created;

  @override
  String toString() {
    return 'CommunityProject(name: $name, projectId: $projectId, projectNumber: $projectNumber, status: $status, created: $created)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityProjectImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.projectNumber, projectNumber) ||
                other.projectNumber == projectNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.created, created) || other.created == created));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, projectId, projectNumber, status, created);

  /// Create a copy of CommunityProject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityProjectImplCopyWith<_$CommunityProjectImpl> get copyWith =>
      __$$CommunityProjectImplCopyWithImpl<_$CommunityProjectImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityProjectImplToJson(this);
  }
}

abstract class _CommunityProject implements CommunityProject {
  const factory _CommunityProject({
    required final String name,
    required final String projectId,
    final String? projectNumber,
    final String status,
    final DateTime? created,
  }) = _$CommunityProjectImpl;

  factory _CommunityProject.fromJson(Map<String, dynamic> json) =
      _$CommunityProjectImpl.fromJson;

  @override
  String get name;
  @override
  String get projectId;
  @override
  String? get projectNumber;
  @override
  String get status;
  @override
  DateTime? get created;

  /// Create a copy of CommunityProject
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityProjectImplCopyWith<_$CommunityProjectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
