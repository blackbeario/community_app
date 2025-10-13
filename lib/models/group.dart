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

/// Predefined community groups
class PredefinedGroups {
  PredefinedGroups._();

  static final List<Group> allGroups = [
    Group(
      id: 'all',
      name: 'All Posts',
      description: 'View all community posts across all groups',
      icon: '📰',
      isPublic: true,
      createdAt: DateTime(2025, 1, 1),
    ),
    Group(
      id: 'announcements',
      name: 'Announcements',
      description: 'Important community announcements and updates',
      icon: '📢',
      isPublic: true,
      createdAt: DateTime(2025, 1, 1),
    ),
    Group(
      id: 'recreation',
      name: 'Recreation',
      description: 'Fun activities, events, and recreational discussions',
      icon: '🎉',
      isPublic: true,
      createdAt: DateTime(2025, 1, 1),
    ),
    Group(
      id: 'sports',
      name: 'Sports',
      description: 'Sports activities, teams, and fitness',
      icon: '⚽',
      isPublic: true,
      taxonomy: ['Golf', 'Gym', 'Pickleball', 'Swimming', 'Tennis'],
      createdAt: DateTime(2025, 1, 1),
    ),
    Group(
      id: 'services',
      name: 'Services',
      description: 'Community services and maintenance updates',
      icon: '🔧',
      isPublic: true,
      createdAt: DateTime(2025, 1, 1),
    ),
    Group(
      id: 'advertisements',
      name: 'Advertisements',
      description: 'Local business ads and promotional content',
      icon: '🛍️',
      isPublic: true,
      createdAt: DateTime(2025, 1, 1),
    ),
    Group(
      id: 'transportation',
      name: 'Transportation',
      description: 'Carpools, traffic updates, and transit information',
      icon: '🚗',
      isPublic: true,
      createdAt: DateTime(2025, 1, 1),
    ),
    Group(
      id: 'food',
      name: 'Food',
      description: 'Dining, recipes, and food-related discussions',
      icon: '🍽️',
      isPublic: true,
      createdAt: DateTime(2025, 1, 1),
    ),
  ];

  /// Get a group by ID
  static Group? getById(String id) {
    try {
      return allGroups.firstWhere((group) => group.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get group name by ID
  static String getNameById(String id) {
    return getById(id)?.name ?? 'Unknown';
  }

  /// Get all group IDs
  static List<String> get allIds => allGroups.map((g) => g.id).toList();

  /// Get selectable groups (excluding 'all')
  static List<Group> get selectable =>
      allGroups.where((group) => group.id != 'all').toList();
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