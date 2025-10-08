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
    @Default(0) int memberCount,
    @Default(true) bool isPublic,
    @TimestampConverter() required DateTime createdAt,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}