// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  photoUrl: json['photoUrl'] as String?,
  coverPhotoUrl: json['coverPhotoUrl'] as String?,
  bio: json['bio'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  unitNumber: json['unitNumber'] as String?,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  groups:
      (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isAdmin: json['isAdmin'] as bool? ?? false,
  fcmToken: json['fcmToken'] as String?,
  fcmTokenUpdatedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['fcmTokenUpdatedAt'],
    const TimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'coverPhotoUrl': instance.coverPhotoUrl,
      'bio': instance.bio,
      'phoneNumber': instance.phoneNumber,
      'unitNumber': instance.unitNumber,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'groups': instance.groups,
      'isAdmin': instance.isAdmin,
      'fcmToken': instance.fcmToken,
      'fcmTokenUpdatedAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.fcmTokenUpdatedAt,
        const TimestampConverter().toJson,
      ),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
