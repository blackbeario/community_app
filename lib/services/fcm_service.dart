import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/app_router.dart';

part 'fcm_service.g.dart';

/// Top-level function to handle background messages
/// Must be top-level or static
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('Background message: ${message.notification?.title}', name: 'FCM');
}

/// Provider for FCM Service
@riverpod
FCMService fcmService(Ref ref) {
  return FCMService();
}

/// Service for managing Firebase Cloud Messaging (FCM)
/// Handles push notification setup, token management, and message handling
class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// Initialize FCM and request permissions
  /// Call this when user logs in
  Future<void> initialize(String userId) async {
    developer.log('Initializing FCM for user $userId', name: 'FCM');

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Request permission (required for iOS, optional for Android)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      developer.log('User granted notification permission', name: 'FCM');

      // On iOS, set foreground notification presentation options
      if (Platform.isIOS) {
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        developer.log('iOS foreground notification presentation options set', name: 'FCM');
      }

      // On iOS, ensure APNs token is available before getting FCM token
      if (Platform.isIOS) {
        try {
          // Wait for APNS token to be available (iOS requirement)
          String? apnsToken = await _messaging.getAPNSToken();

          // If token not immediately available, wait for it
          if (apnsToken == null) {
            developer.log('Waiting for APNs token...', name: 'FCM');

            // Try waiting with exponential backoff
            for (int i = 0; i < 5; i++) {
              await Future.delayed(Duration(seconds: 1 + i));
              apnsToken = await _messaging.getAPNSToken();
              if (apnsToken != null) break;
            }
          }

          if (apnsToken != null) {
            developer.log('APNs token obtained', name: 'FCM');
          } else {
            developer.log('APNs token not available - likely running on iOS Simulator', name: 'FCM');
            developer.log('Push notifications will not work on simulator, but will work on physical device', name: 'FCM');
            // Continue anyway - app should still work without FCM
          }
        } catch (e) {
          developer.log('Error getting APNs token (expected on simulator): $e', name: 'FCM', error: e);
          // Continue anyway
        }
      }

      // Get FCM token
      try {
        String? token = await _messaging.getToken();
        if (token != null) {
          developer.log('FCM Token obtained', name: 'FCM');
          await _saveFCMToken(userId, token);
        } else {
          developer.log('Failed to get FCM token (expected on iOS Simulator)', name: 'FCM');
        }
      } catch (e) {
        developer.log('Error getting FCM token (expected on iOS Simulator): $e', name: 'FCM');
        // Silently continue - app should work without FCM
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        developer.log('FCM Token refreshed', name: 'FCM');
        _saveFCMToken(userId, newToken);
      });

      // Setup message handlers
      setupForegroundHandler();
      setupBackgroundHandler();

    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      developer.log('User granted provisional notification permission', name: 'FCM');
    } else {
      developer.log('User declined notification permission', name: 'FCM');
    }
  }

  /// Save FCM token to Firestore user document
  Future<void> _saveFCMToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      developer.log('FCM token saved for user $userId', name: 'FCM');
    } catch (e) {
      developer.log('Failed to save FCM token: $e', name: 'FCM', error: e);
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap from foreground local notifications
        if (response.payload != null) {
          developer.log('Local notification tapped with payload: ${response.payload}', name: 'FCM');

          // Payload should be the messageId
          // We need to navigate, but we don't have all the data we need
          // For now, just log it - foreground notifications will be handled by FCM
        }
      },
    );

    developer.log('Local notifications initialized', name: 'FCM');
  }

  /// Setup handler for foreground notifications (when app is open)
  void setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log(
        'Foreground notification: ${message.notification?.title}',
        name: 'FCM',
      );

      // With setForegroundNotificationPresentationOptions enabled,
      // iOS will automatically show the notification banner
      // No need to manually show local notification
    });
  }

  /// Setup handler for background messages
  void setupBackgroundHandler() {
    // Handle when notification is tapped (app in background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log(
        'Notification tapped: ${message.notification?.title}',
        name: 'FCM',
      );
      _handleNotificationTap(message.data);
    });

    // Check if app was opened from a terminated state by tapping notification
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        developer.log(
          'App opened from terminated state via notification',
          name: 'FCM',
        );
        _handleNotificationTap(message.data);
      }
    });
  }

  /// Handle notification tap - navigate to appropriate screen
  void _handleNotificationTap(Map<String, dynamic> data) {
    developer.log('Handling notification tap with data: $data', name: 'FCM');

    final type = data['type'];
    final messageId = data['messageId'];
    final fromUserId = data['fromUserId']; // This is the author ID

    // Get the router context
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      developer.log('Navigation context not available', name: 'FCM');
      return;
    }

    switch (type) {
      case 'mention':
        developer.log('Navigate to message: $messageId', name: 'FCM');
        // Navigate to message detail screen
        context.go('/messages/detail/$messageId/$fromUserId');
        break;
      case 'comment_mention':
        developer.log('Navigate to comment in message: $messageId', name: 'FCM');
        // Navigate to message detail screen (comments are shown on the same screen)
        context.go('/messages/detail/$messageId/$fromUserId');
        break;
      default:
        developer.log('Unknown notification type: $type', name: 'FCM');
    }
  }

  /// Clean up FCM token when user logs out
  Future<void> clearToken(String userId) async {
    try {
      await _messaging.deleteToken();
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.delete(),
      });
      developer.log('FCM token cleared for user $userId', name: 'FCM');
    } catch (e) {
      developer.log('Failed to clear FCM token: $e', name: 'FCM', error: e);
    }
  }
}
