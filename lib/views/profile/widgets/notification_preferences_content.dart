import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/group.dart';
import '../../../models/notification_preferences.dart';
import '../../../viewmodels/profile/notification_preferences_viewmodel.dart';

class NotificationPreferencesContent extends ConsumerWidget {
  final String userId;
  final NotificationPreferences preferences;
  final List<Group> groups;

  const NotificationPreferencesContent({
    super.key,
    required this.userId,
    required this.preferences,
    required this.groups,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(notificationPreferencesViewModelProvider);

    return ListView(
      padding: const EdgeInsets.all(4),
      children: [
        // Header
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 0, 0),
          child: Text(
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
                    viewModel.toggleAnnouncements(userId, value);
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
                      viewModel.toggleGroupSubscription(userId, group.id, value);
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
}
