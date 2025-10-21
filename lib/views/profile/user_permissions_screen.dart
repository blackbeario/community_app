import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/group.dart';
import '../../models/notification_preferences.dart';
import '../../services/notification_preferences_service.dart';
import '../../services/group_service.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';

// Provider to watch notification preferences
final notificationPreferencesProvider = StreamProvider.family<NotificationPreferences, String>((ref, userId) {
  return ref.watch(notificationPreferencesServiceProvider).watchPreferences(userId).map(
    (prefs) => prefs ?? const NotificationPreferences(),
  );
});

class UserPermissionsScreen extends ConsumerWidget {
  const UserPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentAppUserProvider).valueOrNull;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: const Center(child: Text('Please log in')),
      );
    }

    final groupsAsync = ref.watch(selectableGroupsProvider);
    final preferencesAsync = ref.watch(notificationPreferencesProvider(currentUser.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: preferencesAsync.when(
        data: (preferences) => groupsAsync.when(
          data: (groups) => _buildContent(context, ref, currentUser.id, preferences, groups),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error loading groups: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading preferences: $error')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    String userId,
    NotificationPreferences preferences,
    List<Group> groups,
  ) {
    return ListView(
      padding: const EdgeInsets.all(4),
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
          child: const Text(
            'Manage your notification preferences',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 8),

        // Announcements section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Community Announcements',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Events, closures, hazards or important alerts relevent to the entire community.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Enable Announcements'),
                  value: preferences.announcements,
                  onChanged: (value) {
                    _toggleAnnouncements(ref, userId, value);
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Info section
        Card(
          color: Colors.blue.shade50,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You can change these group settings at any time. Notifications will only be sent for groups you select and currently only includes direct @mentions. We may add the ability to follow message threads.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Group notifications section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Group Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose which individual groups can send you notifications',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ...groups.map((group) {
                  final isSubscribed = preferences.groups[group.id] ?? false;
                  return SwitchListTile(
                    title: Text(group.name),
                    subtitle: Text(group.description),
                    value: isSubscribed,
                    onChanged: (value) {
                      _toggleGroupSubscription(ref, userId, group.id, value);
                    },
                    contentPadding: EdgeInsets.zero,
                  );
                }),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _toggleGroupSubscription(
    WidgetRef ref,
    String userId,
    String groupId,
    bool subscribe,
  ) async {
    try {
      await ref
          .read(notificationPreferencesServiceProvider)
          .subscribeToGroup(userId, groupId, subscribe);
    } catch (e) {
      // Error handling - you might want to show a snackbar
      print('Error toggling group subscription: $e');
    }
  }

  Future<void> _toggleAnnouncements(
    WidgetRef ref,
    String userId,
    bool subscribe,
  ) async {
    try {
      await ref
          .read(notificationPreferencesServiceProvider)
          .subscribeToAnnouncements(userId, subscribe);
    } catch (e) {
      // Error handling - you might want to show a snackbar
      print('Error toggling announcements: $e');
    }
  }
}
