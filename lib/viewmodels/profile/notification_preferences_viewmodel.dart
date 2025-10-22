import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/notification_preferences_service.dart';

class NotificationPreferencesViewModel {
  final Ref ref;

  NotificationPreferencesViewModel(this.ref);

  Future<void> toggleGroupSubscription(String userId, String groupId, bool subscribe) async {
    final service = ref.read(notificationPreferencesServiceProvider);
    await service.subscribeToGroup(userId, groupId, subscribe);
  }

  Future<void> toggleAnnouncements(String userId, bool subscribe) async {
    final service = ref.read(notificationPreferencesServiceProvider);
    await service.subscribeToAnnouncements(userId, subscribe);
  }

  Future<void> toggleDirectMessages(String userId, bool enabled) async {
    final service = ref.read(notificationPreferencesServiceProvider);
    await service.toggleDirectMessages(userId, enabled);
  }
}

final notificationPreferencesViewModelProvider = Provider((ref) => NotificationPreferencesViewModel(ref));
