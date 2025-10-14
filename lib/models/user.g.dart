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
    };
