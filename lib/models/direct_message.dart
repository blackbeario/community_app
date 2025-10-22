import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'direct_message.freezed.dart';
part 'direct_message.g.dart';

@freezed
class DirectMessage with _$DirectMessage {
  const factory DirectMessage({
    required String id,
    required String conversationId,
    required String senderId,
    required String content,
    String? attachmentUrl,
    String? attachmentType, // 'image' | 'document'
    @TimestampConverter() required DateTime timestamp,
    @Default(false) bool isRead,
    @TimestampConverter() DateTime? readAt,
  }) = _DirectMessage;

  factory DirectMessage.fromJson(Map<String, dynamic> json) =>
      _$DirectMessageFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
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
  dynamic toJson(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.millisecondsSinceEpoch;
  }
}
