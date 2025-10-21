import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/notification_preferences.dart';
import '../../services/notification_preferences_service.dart';
import '../../services/group_service.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import 'widgets/notification_preferences_content.dart';

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
          data: (groups) => NotificationPreferencesContent(
            userId: currentUser.id,
            preferences: preferences,
            groups: groups,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error loading groups: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading preferences: $error')),
      ),
    );
  }
}
