# @ Mention Feature Implementation Guide

## Overview
This guide shows how to implement offline-first @ mentions using SQLite for caching users.

## Architecture

### 1. Local SQLite Cache
- **File**: `lib/services/local_user_cache_service.dart`
- **Purpose**: Store all community users in SQLite for instant offline access
- **Features**:
  - Fast name-based searching with SQL indexes
  - Automatic cache refresh (24-hour default)
  - Works completely offline

### 2. Sync Service
- **File**: `lib/services/user_cache_sync_service.dart`
- **Purpose**: Sync users from Firestore to SQLite in background
- **Providers**:
  - `localUserCacheServiceProvider` - SQLite service instance
  - `userCacheSyncProvider` - Auto-syncs on app startup
  - `cachedUserSearchProvider` - Search users by query
  - `allCachedUsersProvider` - Get all cached users

### 3. User Picker Widget
- **File**: `lib/widgets/user_mention_picker.dart`
- **Purpose**: Dialog for selecting users to mention
- **Features**:
  - Offline search
  - Real-time filtering
  - Clean UI with avatars

## Implementation Steps

### Step 1: Initialize Cache on App Startup

Add to your main app initialization:

```dart
// In main.dart or app initialization
class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Sync user cache in background
    Future.microtask(() {
      ref.read(userCacheSyncProvider);
    });
  }
}
```

### Step 2: Update Message Model

Add `mentions` field to store mentioned user IDs:

```dart
// In lib/models/message.dart
class Message {
  final String id;
  final String content;
  final List<String> mentions; // Add this field
  // ... other fields
}
```

### Step 3: Add Mention Button to CreateMessageScreen

Update `create_message_screen.dart`:

```dart
// Add mention button next to image picker
IconButton(
  onPressed: _isSubmitting ? null : _showMentionPicker,
  icon: const Icon(Icons.alternate_email),
  color: AppColors.primary,
  tooltip: 'Mention someone',
)

// Add method to show picker
Future<void> _showMentionPicker() async {
  final user = await showUserMentionPicker(context);
  if (user != null) {
    // Insert mention into text
    final cursorPos = _contentController.selection.baseOffset;
    final currentText = _contentController.text;

    final newText = currentText.substring(0, cursorPos) +
        '@${user.name} ' +
        currentText.substring(cursorPos);

    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: cursorPos + user.name.length + 2,
      ),
    );

    // Track mentioned users
    _mentionedUsers.add(user.id);
  }
}
```

### Step 4: Extract Mentions Before Posting

```dart
// Helper to extract mentioned user IDs from content
List<String> _extractMentionedUserIds(String content) {
  final mentions = <String>[];
  // Match @UserName patterns
  final regex = RegExp(r'@([A-Za-z\s]+)(?:\s|$)');
  final matches = regex.allMatches(content);

  for (final match in matches) {
    final name = match.group(1)?.trim();
    // Look up user ID by name in cache
    // (You may want to store this differently)
    mentions.add(name!);
  }

  return mentions;
}

// In _submitMessage
final message = Message(
  // ... other fields
  mentions: _mentionedUserIds, // Pass the list of mentioned user IDs
);
```

### Step 5: Send Notifications (When Online)

```dart
// After posting message successfully
if (message.mentions.isNotEmpty) {
  for (final userId in message.mentions) {
    await _sendMentionNotification(
      userId: userId,
      messageId: message.id,
      mentionedBy: currentUser.name,
    );
  }
}
```

## Offline Capability

### How It Works:
1. **On first app launch**: All users sync from Firestore → SQLite
2. **Background sync**: Refreshes every 24 hours when online
3. **@ Mention search**: Queries local SQLite (instant, works offline)
4. **Message submission**: Queued if offline, synced when online
5. **Notifications**: Queued if offline, sent when connection restored

### Cache Management:
```dart
// Force refresh cache
await ref.read(userCacheSyncProvider.notifier).forceRefresh();

// Check cache status
final count = await ref.read(userCacheSyncProvider.notifier).getCachedUserCount();
print('$count users cached locally');
```

## Data Flow

```
User opens app
    ↓
Check if cache needs refresh (>24h old)
    ↓
If needed: Fetch from Firestore → SQLite
    ↓
User types @
    ↓
Search SQLite (instant, offline)
    ↓
User selects person → Insert @Name
    ↓
Extract mentions → Store in Message.mentions[]
    ↓
Post message (queued if offline)
    ↓
Send notifications (when online)
```

## Future Enhancements

1. **Rich text mentions**: Use `flutter_mentions` package for styled text
2. **Auto-complete**: Show suggestions as user types `@`
3. **Click mentions**: Make @mentions clickable to view profiles
4. **Notification system**: Firebase Cloud Messaging for push notifications
5. **Search optimization**: Full-text search with SQLite FTS5

## Testing Offline

1. Enable airplane mode
2. Open app (cache should already exist)
3. Try searching for users - should work instantly
4. Post message with mentions - should queue
5. Disable airplane mode - message should sync

## SQLite vs Other Options

| Solution | Pros | Cons |
|----------|------|------|
| SQLite | Stable, fast, built-in indexes, SQL queries | Requires schema management |
| Hive | Simple API, fast | Buggy, uncertain future support |
| Isar | Very fast, good query syntax | Larger binary size |
| Firestore offline | Automatic sync | Limited query offline, larger cache |

**Recommendation**: SQLite is the best choice for your use case - stable, proven, and you already have it in your project.
