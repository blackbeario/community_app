import '../../models/group.dart';

/// Seed data for initial Firestore setup
/// This data is used only for first-time initialization of a new deployment
class SeedData {
  SeedData._();

  /// Initial groups to populate on first deployment
  static final List<Group> initialGroups = [
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
}
