// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
  isPublic: json['isPublic'] as bool? ?? true,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$$GroupImplToJson(_$GroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'memberCount': instance.memberCount,
      'isPublic': instance.isPublic,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
