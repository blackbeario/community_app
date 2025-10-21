import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'group.freezed.dart';
part 'group.g.dart';

@freezed
class Group with _$Group {
  const factory Group({
    required String id,
    required String name,
    required String description,
    List<String>? taxonomy,
    String? icon,
    @Default(0) int memberCount,
    @Default(true) bool isPublic,
    @TimestampConverter() required DateTime createdAt,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    } else if (json is DateTime) {
      return json;
    }
    throw ArgumentError('Cannot convert $json to DateTime');
  }

  @override
  dynamic toJson(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }
}