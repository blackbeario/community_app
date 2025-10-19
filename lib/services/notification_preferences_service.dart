import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/notification_preferences.dart';

part 'notification_preferences_service.g.dart';

@riverpod
NotificationPreferencesService notificationPreferencesService(NotificationPreferencesServiceRef ref) {
  return NotificationPreferencesService(
    FirebaseFirestore.instance,
    FirebaseMessaging.instance,
  );
}

class NotificationPreferencesService {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  NotificationPreferencesService(this._firestore, this._messaging);

  // Get user's notification preferences
  Future<NotificationPreferences?> getPreferences(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notificationPreferences')
          .get();

      if (!doc.exists) {
        return null;
      }

      return NotificationPreferences.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting notification preferences: $e');
      return null;
    }
  }

  // Stream user's notification preferences
  Stream<NotificationPreferences?> watchPreferences(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('notificationPreferences')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return const NotificationPreferences();
      }
      return NotificationPreferences.fromJson(snapshot.data()!);
    });
  }

  // Subscribe to a group topic
  Future<void> subscribeToGroup(String userId, String groupId, bool subscribe) async {
    try {
      final topicName = 'group_$groupId';

      if (subscribe) {
        await _messaging.subscribeToTopic(topicName);
      } else {
        await _messaging.unsubscribeFromTopic(topicName);
      }

      // Update preferences in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notificationPreferences')
          .set({
        'groups.$groupId': subscribe,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error subscribing to group: $e');
      rethrow;
    }
  }

  // Subscribe/unsubscribe from announcements
  Future<void> subscribeToAnnouncements(String userId, bool subscribe) async {
    try {
      if (subscribe) {
        await _messaging.subscribeToTopic('announcements');
      } else {
        await _messaging.unsubscribeFromTopic('announcements');
      }

      // Update preferences in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notificationPreferences')
          .set({
        'announcements': subscribe,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error subscribing to announcements: $e');
      rethrow;
    }
  }

  // Initialize default preferences for a new user or when they join a group
  Future<void> initializeGroupPreference(String userId, String groupId, {bool defaultSubscribe = true}) async {
    try {
      final prefs = await getPreferences(userId);

      // If user hasn't set a preference for this group yet, subscribe them by default
      if (prefs == null || !prefs.groups.containsKey(groupId)) {
        await subscribeToGroup(userId, groupId, defaultSubscribe);
      }
    } catch (e) {
      print('Error initializing group preference: $e');
    }
  }
}
