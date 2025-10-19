# Group Service Usage Guide

## Overview

The `GroupService` provides a Firebase-backed solution for managing community groups dynamically. All groups are stored in and fetched from Firestore.

## Setup

Groups are automatically seeded on first app launch if the Firestore collection is empty. The initialization happens in `main.dart` before the app starts:

```dart
// Automatically populates Firestore with seed data if collection is empty
await initializer.initializeIfNeeded();
```

The seed data is defined in `lib/core/utils/seed_data.dart` and is only used for initial deployment setup.

## Available Providers

### 1. Get All Groups
```dart
final groupsAsync = ref.watch(allGroupsProvider);

groupsAsync.when(
  data: (groups) => ListView.builder(
    itemCount: groups.length,
    itemBuilder: (context, index) => ListTile(
      leading: Text(groups[index].icon ?? '📁'),
      title: Text(groups[index].name),
    ),
  ),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

### 2. Get Public Groups Only
```dart
final publicGroupsAsync = ref.watch(publicGroupsProvider);
```

### 3. Get Selectable Groups (excludes 'all')
```dart
final selectableGroupsAsync = ref.watch(selectableGroupsProvider);
```

### 4. Get Single Group by ID
```dart
final groupAsync = ref.watch(groupProvider('services'));

groupAsync.when(
  data: (group) => group != null
    ? Text(group.name)
    : Text('Group not found'),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

## Direct Service Methods

For one-off operations, use the service directly:

```dart
final groupService = ref.read(groupServiceProvider);

// Create a new group
await groupService.createGroup(Group(
  id: 'new-group',
  name: 'New Group',
  description: 'Description',
  icon: '🆕',
  isPublic: true,
  createdAt: DateTime.now(),
));

// Update a group
await groupService.updateGroup(updatedGroup);

// Delete a group
await groupService.deleteGroup('group-id');

// Increment member count
await groupService.incrementMemberCount('group-id');
```

## Migration from Hardcoded Groups

### Before (Hardcoded in PredefinedGroups class):
```dart
import '../../models/group.dart';

final group = PredefinedGroups.getById('services');
final groupName = PredefinedGroups.getNameById('services');
```

### After (Dynamic from Firestore):
```dart
import '../../services/group_service.dart';

// In a ConsumerWidget:
final groupAsync = ref.watch(groupProvider('services'));

groupAsync.when(
  data: (group) => Text(group?.name ?? 'Unknown'),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

**Note:** The `PredefinedGroups` class has been removed. All groups are now managed through Firestore via `GroupService`.

## Firestore Structure

```
groups/
  ├─ all/
  │   ├─ id: "all"
  │   ├─ name: "All Posts"
  │   ├─ description: "View all community posts..."
  │   ├─ icon: "📰"
  │   ├─ isPublic: true
  │   ├─ memberCount: 0
  │   └─ createdAt: Timestamp
  ├─ announcements/
  ├─ recreation/
  ├─ sports/
  ├─ services/
  └─ ...
```

## Seeding & Testing

### Initial Seed Data

Seed data is stored in `lib/core/utils/seed_data.dart`:

```dart
class SeedData {
  static final List<Group> initialGroups = [
    Group(id: 'announcements', name: 'Announcements', ...),
    Group(id: 'services', name: 'Services', ...),
    // ... other groups
  ];
}
```

### Force Re-seeding (Development)

To force re-seeding during development:

```dart
final groupService = ref.read(groupServiceProvider);
final initializer = GroupInitializer(groupService);
await initializer.seedGroups();
```

**⚠️ Warning:** `seedGroups()` will overwrite existing groups with the same IDs.

### Custom Seeding

For production deployments or custom setups, you can seed groups manually:

```dart
final groupService = ref.read(groupServiceProvider);
await groupService.seedGroups([
  Group(id: 'custom-group', name: 'Custom Group', ...),
]);
```

## Benefits

1. **Dynamic Management**: Groups can be added/edited via admin panel without app updates
2. **Real-time Updates**: Changes sync across all users instantly
3. **Scalable**: Can handle hundreds of groups
4. **Flexible**: Easy to add custom fields or group types
5. **No Hardcoding**: Groups are stored in Firestore, not in code

## Next Steps

- Build admin panel to manage groups (Phase 5 of app plan)
- Add group membership tracking
- Implement group permissions (public/private/invite-only)
- Add group search functionality
