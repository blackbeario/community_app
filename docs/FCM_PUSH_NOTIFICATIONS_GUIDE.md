# Firebase Cloud Messaging (FCM) with Cloud Functions Implementation Guide

## Overview
This guide covers implementing push notifications for @ mentions, tee time reminders, table ready alerts, and other real-time notifications using Firebase Cloud Messaging (FCM) with Cloud Functions.

## Why Cloud Functions (Not Client-Side)

### Benefits:
- ✅ **Secure** - API keys never exposed in client app
- ✅ **Reliable** - Works even if sender's app crashes/closes
- ✅ **Offline-capable** - Firestore triggers fire when data syncs later
- ✅ **Scalable** - Ready for growth from 500 → 50,000 users
- ✅ **Batching** - Send to multiple users efficiently
- ✅ **Scheduled** - Handle "tee time in 1 hour" type reminders
- ✅ **Proper architecture** - Industry best practice

### Cost Analysis:
- **Free tier**: 2M invocations/month
- **Your scale**: 500 users × 10 mentions/day = 150,000/month
- **Result**: Well within free tier!
- **If exceeded**: $0.40/million invocations (pennies)

## Prerequisites

### 1. Upgrade to Firebase Blaze Plan
```bash
# Visit Firebase Console
https://console.firebase.google.com/project/YOUR_PROJECT/usage/details

# Click "Modify plan" → "Blaze (Pay as you go)"
# Note: Free tier still applies, you only pay for overages
```

### 2. Install Firebase CLI
```bash
# Install Node.js first (if not installed)
# Download from: https://nodejs.org/

# Install Firebase CLI globally
npm install -g firebase-tools

# Login to Firebase
firebase login

# Verify installation
firebase --version
```

### 3. Initialize Cloud Functions
```bash
# Navigate to project root
cd /Users/jfraz/Sites/community

# Initialize Cloud Functions
firebase init functions

# Select:
# - Use an existing project → Select your Firebase project
# - Language: TypeScript (recommended) or JavaScript
# - ESLint: Yes
# - Install dependencies: Yes

# This creates:
# - functions/ directory
# - functions/src/index.ts (TypeScript) or functions/index.js
# - functions/package.json
```

## Project Structure After Setup

```
community/
├── lib/                          # Flutter app
├── functions/                    # Cloud Functions (new)
│   ├── src/
│   │   └── index.ts             # Function definitions
│   ├── package.json
│   └── tsconfig.json
├── firebase.json
└── .firebaserc
```

## Implementation Steps

### Phase 1: FCM Token Management (Flutter)

**File**: `lib/services/fcm_service.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize FCM and request permissions
  Future<void> initialize(String userId) async {
    // Request permission (iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      developer.log('User granted notification permission');

      // Get FCM token
      String? token = await _messaging.getToken();
      if (token != null) {
        await _saveFCMToken(userId, token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _saveFCMToken(userId, newToken);
      });
    }
  }

  /// Save FCM token to Firestore
  Future<void> _saveFCMToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      developer.log('FCM token saved for user $userId');
    } catch (e) {
      developer.log('Failed to save FCM token: $e');
    }
  }

  /// Handle foreground notifications
  void setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log('Foreground notification: ${message.notification?.title}');
      // Show in-app notification or update UI
    });
  }

  /// Handle notification taps (background/terminated)
  void setupNotificationTapHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log('Notification tapped: ${message.data}');
      // Navigate to mentioned message/comment
      _handleNotificationTap(message.data);
    });
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    // Implement deep linking to message/comment
    final type = data['type'];
    final messageId = data['messageId'];

    // Use GoRouter to navigate
    // context.go('/messages/detail/$messageId');
  }
}
```

**Update Firestore User Model** to include FCM token:
```dart
// In lib/models/user.dart - add fields:
String? fcmToken;
DateTime? fcmTokenUpdatedAt;
```

### Phase 2: Cloud Function - Mention Notifications

**File**: `functions/src/index.ts`

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

/**
 * Trigger when a new message is created
 * Sends notifications to mentioned users
 */
export const onMessageCreated = functions.firestore
  .document('messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const messageId = context.params.messageId;

    // Extract mentions from content
    const mentions = extractMentions(message.content);

    if (mentions.length === 0) {
      console.log('No mentions found in message');
      return null;
    }

    // Get author info
    const authorDoc = await admin.firestore()
      .collection('users')
      .doc(message.userId)
      .get();
    const author = authorDoc.data();

    // Send notification to each mentioned user
    const notifications = mentions.map(async (userId) => {
      // Get user's FCM token
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(userId)
        .get();

      const fcmToken = userDoc.data()?.fcmToken;

      if (!fcmToken) {
        console.log(`No FCM token for user ${userId}`);
        return null;
      }

      // Send notification
      const payload = {
        notification: {
          title: `${author?.name} mentioned you`,
          body: truncate(message.content, 100),
        },
        data: {
          type: 'mention',
          messageId: messageId,
          fromUserId: message.userId,
        },
        token: fcmToken,
      };

      try {
        await admin.messaging().send(payload);
        console.log(`Notification sent to ${userId}`);
      } catch (error) {
        console.error(`Failed to send notification to ${userId}:`, error);
      }
    });

    await Promise.all(notifications);
    return null;
  });

/**
 * Trigger when a new comment is created
 * Sends notifications to mentioned users
 */
export const onCommentCreated = functions.firestore
  .document('comments/{commentId}')
  .onCreate(async (snap, context) => {
    const comment = snap.data();
    const commentId = context.params.commentId;

    const mentions = extractMentions(comment.content);

    if (mentions.length === 0) {
      console.log('No mentions found in comment');
      return null;
    }

    // Get author info
    const authorDoc = await admin.firestore()
      .collection('users')
      .doc(comment.userId)
      .get();
    const author = authorDoc.data();

    // Get message info for context
    const messageDoc = await admin.firestore()
      .collection('messages')
      .doc(comment.messageId)
      .get();

    // Send notification to each mentioned user
    const notifications = mentions.map(async (userId) => {
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(userId)
        .get();

      const fcmToken = userDoc.data()?.fcmToken;

      if (!fcmToken) {
        console.log(`No FCM token for user ${userId}`);
        return null;
      }

      const payload = {
        notification: {
          title: `${author?.name} mentioned you in a comment`,
          body: truncate(comment.content, 100),
        },
        data: {
          type: 'comment_mention',
          messageId: comment.messageId,
          commentId: commentId,
          fromUserId: comment.userId,
        },
        token: fcmToken,
      };

      try {
        await admin.messaging().send(payload);
        console.log(`Comment notification sent to ${userId}`);
      } catch (error) {
        console.error(`Failed to send notification to ${userId}:`, error);
      }
    });

    await Promise.all(notifications);
    return null;
  });

/**
 * Extract user IDs from @mentions in content
 * Content format: "@John Doe check this out!"
 * We need to match mentions against cached users
 */
function extractMentions(content: string): string[] {
  // This is a simple implementation
  // You may want to store mentioned user IDs in a separate field
  // in the message/comment document for more reliability

  const mentionPattern = /@([A-Za-z\s]+)(?:\s|$|!|\.)/g;
  const matches = content.matchAll(mentionPattern);
  const mentionedNames = Array.from(matches).map(m => m[1].trim());

  // TODO: Look up user IDs by name
  // For now, return empty - implement after storing mentions as user IDs
  return [];
}

function truncate(str: string, length: number): string {
  return str.length > length ? str.substring(0, length) + '...' : str;
}
```

### Phase 3: Store Mention User IDs (Flutter)

Update Message and Comment models to store mentioned user IDs:

```dart
// In lib/models/message.dart
class Message {
  // ... existing fields
  final List<String> mentions; // Add this field
}

// In lib/models/comment.dart
class Comment {
  // ... existing fields
  final List<String> mentions; // Add this field
}
```

Update CreateMessageScreen and MessageDetailScreen:

```dart
// In _submitMessage or _submitComment:
final message = Message(
  // ... other fields
  mentions: _mentionedUserIds, // Use the tracked user IDs
);
```

Update Cloud Function to use stored mentions:

```typescript
// In onMessageCreated:
const mentions = message.mentions || [];
```

### Phase 4: Testing with Firebase Emulators

```bash
# Install emulators
firebase init emulators

# Select: Functions, Firestore
# Use default ports

# Start emulators
firebase emulators:start

# In another terminal, connect Flutter app to emulators
# (Update lib/main.dart with emulator connections)
```

### Phase 5: Deploy Cloud Functions

```bash
# Deploy to Firebase
cd functions
npm run build  # If using TypeScript
cd ..
firebase deploy --only functions

# View logs
firebase functions:log
```

## Future Enhancements

### Scheduled Notifications (Tee Times, Table Ready)

```typescript
// functions/src/index.ts

/**
 * Scheduled function - runs every minute
 * Sends tee time reminders
 */
export const sendTeeTimeReminders = functions.pubsub
  .schedule('every 1 minutes')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const oneHourFromNow = new Date(now.toMillis() + 60 * 60 * 1000);

    // Query tee times starting in ~1 hour
    const teeTimesSnapshot = await admin.firestore()
      .collection('teeTimes')
      .where('startTime', '>=', now)
      .where('startTime', '<=', admin.firestore.Timestamp.fromDate(oneHourFromNow))
      .where('reminderSent', '==', false)
      .get();

    const notifications = teeTimesSnapshot.docs.map(async (doc) => {
      const teeTime = doc.data();
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(teeTime.userId)
        .get();

      const fcmToken = userDoc.data()?.fcmToken;
      if (!fcmToken) return null;

      await admin.messaging().send({
        notification: {
          title: 'Tee Time Reminder',
          body: `Your tee time is in 1 hour at ${teeTime.courseName}`,
        },
        data: {
          type: 'tee_time_reminder',
          teeTimeId: doc.id,
        },
        token: fcmToken,
      });

      // Mark as sent
      await doc.ref.update({ reminderSent: true });
    });

    await Promise.all(notifications);
    return null;
  });
```

## Testing Checklist

- [ ] Upgrade to Firebase Blaze plan
- [ ] Install Firebase CLI
- [ ] Initialize Cloud Functions
- [ ] Add FCM token field to User model
- [ ] Implement FCMService in Flutter
- [ ] Call FCMService.initialize() on app startup
- [ ] Add mentions field to Message/Comment models
- [ ] Update message/comment creation to save mentioned user IDs
- [ ] Write Cloud Functions for mention notifications
- [ ] Test with Firebase emulators locally
- [ ] Deploy Cloud Functions to Firebase
- [ ] Test on Android emulator (FCM works)
- [ ] Test on physical iOS device (FCM works)
- [ ] Verify notifications appear
- [ ] Verify tapping notification navigates to message
- [ ] Test offline scenarios

## References

- [Firebase Cloud Messaging (Flutter)](https://firebase.flutter.dev/docs/messaging/overview/)
- [Cloud Functions for Firebase](https://firebase.google.com/docs/functions)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [FCM Send Messages](https://firebase.google.com/docs/cloud-messaging/send-message)

## Current Status

✅ **Completed:**
- @ Mention UI (flutter_mentions)
- SQLite user caching for offline mentions
- User mention tracking (_mentionedUserIds)

🔲 **Next Steps:**
1. Upgrade to Blaze plan
2. Initialize Cloud Functions
3. Implement FCMService
4. Update models for mentions/fcmToken
5. Write Cloud Functions
6. Test & deploy

## Notes

- The `firebase_messaging: 15.1.3` package is already installed in pubspec.yaml
- iOS requires physical device for testing push notifications
- Android emulator with Google Play Services can test FCM
- Cloud Functions free tier: 2M invocations/month (plenty for <500 users)
- Cost after free tier: $0.40/million invocations
