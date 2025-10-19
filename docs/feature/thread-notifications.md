# Feature: Thread Participation Notifications

## Overview
Implement notifications for users when new comments are added to:
1. Messages they created
2. Comment threads they've participated in

This follows common social media patterns (Facebook, LinkedIn, Reddit) and will improve user engagement by keeping them informed about conversations they care about.

## Current State

### Existing Notification System
Currently, notifications are only sent for:
- ✅ Direct @mentions in messages
- ✅ Direct @mentions in comments
- ✅ Announcements (admin-only, sent to all subscribed users)

### Current Implementation Files
- **Models**: `lib/models/notification_preferences.dart`, `lib/models/message.dart`
- **Services**: `lib/services/notification_preferences_service.dart`
- **UI**: `lib/views/profile/user_permissions_screen.dart`
- **Cloud Functions**: `functions/index.js` (onMessageCreated, onCommentCreated, onAnnouncementCreated)

## Proposed Implementation

### 1. Data Model Changes (1-2 hours)

#### Update Message Model
Add a field to track thread participants:

**File**: `lib/models/message.dart`

```dart
@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String groupId,
    required String userId,
    required String content,
    String? imageUrl,
    @TimestampConverter() required DateTime timestamp,
    @Default([]) List<String> likes,
    @Default(0) int commentCount,
    @Default([]) List<String> mentions,
    @Default([]) List<String> commenters,  // NEW: Track users who've commented
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}
```

After updating the model:
1. Run `flutter pub run build_runner build --delete-conflicting-outputs`
2. Existing messages will have empty `commenters` arrays initially
3. The list will populate as new comments are added

#### Update NotificationPreferences Model
Add toggles for new notification types:

**File**: `lib/models/notification_preferences.dart`

```dart
@freezed
class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    @Default({}) Map<String, bool> groups,
    @Default(true) bool announcements,
    @Default(true) bool notifyOnOwnMessages,  // NEW: Notify when someone comments on your messages
    @Default(true) bool notifyOnParticipatingThreads,  // NEW: Notify about threads you've commented on
    @TimestampConverter() DateTime? lastUpdated,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
}
```

After updating, run build_runner again.

### 2. Firebase Cloud Functions Updates (2-3 hours)

**File**: `functions/index.js`

Enhance the `onCommentCreated` function to notify:
- The original message author
- All users who have previously commented on the thread
- Respect their notification preferences

```javascript
/**
 * Cloud Function triggered when a new comment is created
 * Sends push notifications to:
 * 1. Users mentioned in the comment
 * 2. The message author (if not the commenter)
 * 3. Users who have commented on this thread before
 */
exports.onCommentCreated = onDocumentCreated("comments/{commentId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    logger.log("No data associated with the event");
    return;
  }

  const comment = snapshot.data();
  const commentId = event.params.commentId;

  logger.log("New comment created:", commentId);

  try {
    // Get the parent message
    const messageDoc = await admin.firestore()
        .collection("messages")
        .doc(comment.messageId)
        .get();

    if (!messageDoc.exists) {
      logger.error(`Message not found: ${comment.messageId}`);
      return null;
    }

    const message = messageDoc.data();

    // Get comment author info
    const authorDoc = await admin.firestore()
        .collection("users")
        .doc(comment.userId)
        .get();

    if (!authorDoc.exists) {
      logger.error(`Comment author not found: ${comment.userId}`);
      return null;
    }

    const author = authorDoc.data();

    // Collect all users to notify (use Set to avoid duplicates)
    const usersToNotify = new Set();
    const mentions = comment.mentions || [];

    // 1. Add mentioned users (highest priority)
    mentions.forEach(userId => usersToNotify.add(userId));

    // 2. Add message author (if not the commenter and preference enabled)
    if (message.userId !== comment.userId) {
      const authorPrefsDoc = await admin.firestore()
          .collection("notificationPreferences")
          .doc(message.userId)
          .get();

      const authorPrefs = authorPrefsDoc.exists ? authorPrefsDoc.data() : {};
      if (authorPrefs.notifyOnOwnMessages !== false) {  // Default true
        usersToNotify.add(message.userId);
      }
    }

    // 3. Add thread participants (excluding commenter and if preference enabled)
    const commenters = message.commenters || [];
    for (const userId of commenters) {
      if (userId !== comment.userId) {
        const userPrefsDoc = await admin.firestore()
            .collection("notificationPreferences")
            .doc(userId)
            .get();

        const userPrefs = userPrefsDoc.exists ? userPrefsDoc.data() : {};
        if (userPrefs.notifyOnParticipatingThreads !== false) {  // Default true
          usersToNotify.add(userId);
        }
      }
    }

    // Update message's commenters list (add current commenter if not already there)
    await messageDoc.ref.update({
      commenters: admin.firestore.FieldValue.arrayUnion(comment.userId)
    });

    logger.log(`Will notify ${usersToNotify.size} users about comment ${commentId}`);

    // Send notifications
    const notifications = Array.from(usersToNotify).map(async (userId) => {
      try {
        // Get user's FCM token
        const userDoc = await admin.firestore()
            .collection("users")
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          logger.warn(`User not found: ${userId}`);
          return null;
        }

        const userData = userDoc.data();
        const fcmToken = userData.fcmToken;

        if (!fcmToken) {
          logger.warn(`No FCM token for user ${userId}`);
          return null;
        }

        // Determine notification title based on why they're being notified
        let title;
        if (mentions.includes(userId)) {
          title = `${author.name} mentioned you in a comment`;
        } else if (userId === message.userId) {
          title = `${author.name} commented on your message`;
        } else {
          title = `${author.name} replied in a thread`;
        }

        // Send notification
        const payload = {
          notification: {
            title: title,
            body: truncate(comment.content, 100),
          },
          data: {
            type: mentions.includes(userId) ? "comment_mention" : "comment_reply",
            messageId: comment.messageId,
            commentId: commentId,
            fromUserId: comment.userId,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          token: fcmToken,
        };

        await admin.messaging().send(payload);
        logger.log(`Comment notification sent to user ${userId}`);

        return true;
      } catch (error) {
        logger.error(`Failed to send notification to ${userId}:`, error);
        return null;
      }
    });

    await Promise.all(notifications);
    return null;
  } catch (error) {
    logger.error("Error processing comment notification:", error);
    return null;
  }
});
```

After updating:
1. Deploy functions: `firebase deploy --only functions`
2. Monitor logs: `firebase functions:log`

### 3. Notification Preferences Service Updates (1 hour)

**File**: `lib/services/notification_preferences_service.dart`

Add methods to toggle the new notification types:

```dart
/// Toggle notifications for comments on user's own messages
Future<void> toggleOwnMessageNotifications(String userId, bool enabled) async {
  await _firestore
      .collection('notificationPreferences')
      .doc(userId)
      .set({
    'notifyOnOwnMessages': enabled,
    'lastUpdated': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

/// Toggle notifications for threads user has participated in
Future<void> toggleThreadParticipationNotifications(String userId, bool enabled) async {
  await _firestore
      .collection('notificationPreferences')
      .doc(userId)
      .set({
    'notifyOnParticipatingThreads': enabled,
    'lastUpdated': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}
```

### 4. UI Updates (1-2 hours)

**File**: `lib/views/profile/user_permissions_screen.dart`

Add a new section for thread notifications between "Announcements" and "Group Notifications":

```dart
const SizedBox(height: 24),

// Thread notifications section
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thread Notifications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Get notified about conversations you\'re involved in',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Comments on my messages'),
          subtitle: const Text('When someone comments on a message you created'),
          value: preferences.notifyOnOwnMessages,
          onChanged: (value) {
            _toggleOwnMessageNotifications(ref, userId, value);
          },
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Replies in threads I\'ve joined'),
          subtitle: const Text('When someone replies to a conversation you\'ve commented on'),
          value: preferences.notifyOnParticipatingThreads,
          onChanged: (value) {
            _toggleThreadParticipationNotifications(ref, userId, value);
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    ),
  ),
),
```

Add the corresponding toggle methods:

```dart
Future<void> _toggleOwnMessageNotifications(
  WidgetRef ref,
  String userId,
  bool enabled,
) async {
  try {
    await ref
        .read(notificationPreferencesServiceProvider)
        .toggleOwnMessageNotifications(userId, enabled);
  } catch (e) {
    print('Error toggling own message notifications: $e');
  }
}

Future<void> _toggleThreadParticipationNotifications(
  WidgetRef ref,
  String userId,
  bool enabled,
) async {
  try {
    await ref
        .read(notificationPreferencesServiceProvider)
        .toggleThreadParticipationNotifications(userId, enabled);
  } catch (e) {
    print('Error toggling thread participation notifications: $e');
  }
}
```

Update the info card text:

```dart
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
            'You can customize your notification preferences at any time. Thread notifications help you stay engaged in conversations you care about.',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  ),
),
```

### 5. Testing Checklist (1-2 hours)

- [ ] User creates a message, another user comments → original author gets notified
- [ ] User A comments, User B comments on same message → User A gets notified about User B's reply
- [ ] User is mentioned AND is thread participant → only gets one notification (mention takes precedence)
- [ ] User disables "Comments on my messages" → doesn't receive notification when someone comments on their message
- [ ] User disables "Thread participation" → doesn't receive notifications about thread replies
- [ ] Multiple commenters on same thread → all get notified appropriately
- [ ] Commenter doesn't notify themselves
- [ ] Existing messages without `commenters` field work correctly (empty array)
- [ ] Notifications include correct deep link data for navigation
- [ ] Check Firebase Functions logs for any errors

### 6. Deployment Steps

1. **Update Flutter models**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Test locally first** (if using Firebase emulators):
   ```bash
   firebase emulators:start
   ```

3. **Deploy Cloud Functions**:
   ```bash
   firebase deploy --only functions
   ```

4. **Build and deploy app**:
   ```bash
   flutter build ios --release
   flutter build android --release
   ```

5. **Monitor in production**:
   ```bash
   firebase functions:log --only onCommentCreated
   ```

## Benefits

✅ **Improved engagement**: Users stay informed about conversations they care about
✅ **Familiar UX**: Follows patterns from Facebook, LinkedIn, Reddit
✅ **User control**: Can opt-out via preferences
✅ **Smart deduplication**: Avoids notification spam from multiple triggers

## Potential Concerns & Mitigations

⚠️ **Notification fatigue**: Popular threads could generate many notifications
- **Mitigation**: Users can disable thread participation notifications
- **Future enhancement**: Add "mute thread" option per message

⚠️ **Performance**: Querying preferences for many participants
- **Mitigation**: Use batch reads, already implemented in Cloud Functions
- **Future enhancement**: Cache preferences in memory with TTL

⚠️ **Data migration**: Existing messages don't have `commenters` field
- **Mitigation**: Field defaults to empty array, starts populating going forward
- **Optional**: Run one-time script to backfill `commenters` from existing comments

## Estimated Effort

**Total: 6-8 hours**
- Data models: 1-2 hours
- Cloud Functions: 2-3 hours
- Services: 1 hour
- UI: 1-2 hours
- Testing: 1-2 hours

## Implementation Priority

**Recommended approach**: Implement in two phases

### Phase 1 (Simpler, 3-4 hours)
- Implement "Comments on my messages" only
- Test and validate with users
- Gather feedback

### Phase 2 (Add-on, 3-4 hours)
- Add "Thread participation" notifications
- More complex but builds on Phase 1 infrastructure

## Related Files

- `lib/models/message.dart` - Message & Comment models
- `lib/models/notification_preferences.dart` - User preferences model
- `lib/services/notification_preferences_service.dart` - Preferences service
- `lib/views/profile/user_permissions_screen.dart` - Settings UI
- `functions/index.js` - Cloud Functions for notifications
- `lib/services/fcm_service.dart` - FCM client service

## Notes

- The architecture already supports this feature well
- Most of the infrastructure (FCM, preferences, Cloud Functions) is in place
- Main work is expanding the logic and adding UI toggles
- Consider A/B testing to measure engagement impact
