import 'package:flutter/foundation.dart';
import '../../services/group_service.dart';
import 'seed_data.dart';

/// Utility class to initialize groups in Firestore
/// This should be called once when the app first starts to populate
/// the groups collection with seed data
class GroupInitializer {
  final GroupService _groupService;

  GroupInitializer(this._groupService);

  /// Force re-seeding (useful for development/testing)
  /// WARNING: This will overwrite existing groups with the same IDs
  Future<void> seedGroups() async {
    try {
      debugPrint('Force seeding groups...');
      await _groupService.seedGroups(SeedData.initialGroups);
      debugPrint('Successfully force-seeded ${await _getGroupCount()} groups.');
    } catch (e) {
      debugPrint('Error force-seeding groups: $e');
      rethrow;
    }
  }

  /// Get the current count of groups in Firestore
  Future<int> _getGroupCount() async {
    try {
      final groups = await _groupService.getAllGroups().first;
      return groups.length;
    } catch (e) {
      return 0;
    }
  }
}
