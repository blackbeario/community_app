// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationPreferencesImpl _$$NotificationPreferencesImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationPreferencesImpl(
  groups:
      (json['groups'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const {},
  announcements: json['announcements'] as bool? ?? true,
  directMessages: json['directMessages'] as bool? ?? true,
  lastUpdated: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['lastUpdated'],
    const TimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$$NotificationPreferencesImplToJson(
  _$NotificationPreferencesImpl instance,
) => <String, dynamic>{
  'groups': instance.groups,
  'announcements': instance.announcements,
  'directMessages': instance.directMessages,
  'lastUpdated': _$JsonConverterToJson<Timestamp, DateTime>(
    instance.lastUpdated,
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
