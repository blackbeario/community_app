// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_project_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityProjectImpl _$$CommunityProjectImplFromJson(
  Map<String, dynamic> json,
) => _$CommunityProjectImpl(
  name: json['name'] as String,
  projectId: json['projectId'] as String,
  projectNumber: json['projectNumber'] as String?,
  status: json['status'] as String? ?? 'active',
  created: json['created'] == null
      ? null
      : DateTime.parse(json['created'] as String),
);

Map<String, dynamic> _$$CommunityProjectImplToJson(
  _$CommunityProjectImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'projectId': instance.projectId,
  'projectNumber': instance.projectNumber,
  'status': instance.status,
  'created': instance.created?.toIso8601String(),
};
