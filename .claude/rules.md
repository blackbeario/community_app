# Claude Code Rules - Community App

## Project-Specific Architecture Rules

### Architecture Pattern: MVVM + Riverpod

This project uses **MVVM (Model-View-ViewModel)** architecture with **Riverpod** for state management. Follow these patterns strictly throughout the codebase.

---

## 1. Project Structure

Always organize code following this structure:

```
lib/
├── core/                # Core app configuration
│   ├── config/          # Firebase, environment config
│   ├── theme/           # Theme, colors, typography
│   ├── routing/         # go_router configuration
│   └── utils/           # Helpers, extensions, validators
├── models/              # Freezed data models (shared)
├── services/            # Firebase services (data layer)
├── viewmodels/          # Business logic + Riverpod providers
├── views/               # UI screens
├── widgets/             # Reusable UI components
└── main.dart
```

---

## 2. Models (Data Layer)

**Always use Freezed for data models:**

```dart
// models/message.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String userId,
    required String content,
    required DateTime timestamp,
    @Default([]) List<String> likes,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
```

**Rules:**
- Use `@freezed` for immutable models
- Always include `fromJson` for Firebase deserialization
- Use `@Default()` for optional lists/values
- Store models in `lib/models/` directory

---

## 3. Services (Data Layer)

**Services handle all Firebase operations:**

```dart
// services/message_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class MessageService {
  final FirebaseFirestore _firestore;

  MessageService(this._firestore);

  // Stream for real-time data
  Stream<List<Message>> getMessages(String groupId) {
    return _firestore
        .collection('messages')
        .where('groupId', isEqualTo: groupId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromJson(doc.data()))
            .toList());
  }

  // Future for one-time operations
  Future<void> postMessage(Message message) async {
    await _firestore
        .collection('messages')
        .doc(message.id)
        .set(message.toJson());
  }

  Future<void> likeMessage(String messageId, String userId) async {
    await _firestore.collection('messages').doc(messageId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });
  }
}
```

**Rules:**
- One service class per Firebase collection/feature
- Inject `FirebaseFirestore` via constructor (for testing)
- Return `Stream<T>` for real-time data
- Return `Future<T>` for one-time operations
- Keep services in `lib/services/` directory
- No business logic in services (pure data operations only)

---

## 4. ViewModels (Business Logic + Riverpod)

**Use Riverpod code generation for all providers:**

### Service Provider (Singleton)
```dart
// services/message_service.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_service.g.dart';

@riverpod
MessageService messageService(MessageServiceRef ref) {
  return MessageService(FirebaseFirestore.instance);
}
```

### Stream Provider (Real-time data)
```dart
// viewmodels/messaging/message_viewmodel.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_viewmodel.g.dart';

@riverpod
Stream<List<Message>> messages(MessagesRef ref, String groupId) {
  final service = ref.watch(messageServiceProvider);
  return service.getMessages(groupId);
}
```

### AsyncNotifier (Actions with loading states)
```dart
// viewmodels/messaging/message_viewmodel.dart
@riverpod
class MessageViewModel extends _$MessageViewModel {
  @override
  FutureOr<void> build() {
    // Initialize if needed, otherwise return void
  }

  Future<void> postMessage({
    required String groupId,
    required String userId,
    required String content,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        groupId: groupId,
        userId: userId,
        content: content,
        timestamp: DateTime.now(),
      );

      final service = ref.read(messageServiceProvider);
      await service.postMessage(message);
    });
  }

  Future<void> likeMessage(String messageId, String userId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await ref.read(messageServiceProvider).likeMessage(messageId, userId);
    });
  }
}
```

### StateNotifier (Complex local state)
```dart
// For complex state with multiple fields
@riverpod
class BookingFormViewModel extends _$BookingFormViewModel {
  @override
  BookingFormState build() {
    return BookingFormState(
      selectedDate: DateTime.now(),
      selectedTimeSlot: null,
      partySize: 1,
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void selectTimeSlot(String slot) {
    state = state.copyWith(selectedTimeSlot: slot);
  }
}

@freezed
class BookingFormState with _$BookingFormState {
  const factory BookingFormState({
    required DateTime selectedDate,
    required String? selectedTimeSlot,
    required int partySize,
  }) = _BookingFormState;
}
```

**Rules:**
- Always use `@riverpod` code generation (not manual providers)
- Include `part 'filename.g.dart';`
- Use `AsyncNotifier` for async actions (API calls)
- Use `StateNotifier` for complex local state
- Use `Stream` providers for real-time Firebase data
- Store viewmodels in `lib/viewmodels/{feature}/`
- Use `ref.watch()` to depend on other providers
- Use `ref.read()` for one-time reads (inside methods)

---

## 5. Views (UI Layer)

**Always use ConsumerWidget or ConsumerStatefulWidget:**

```dart
// views/messaging/message_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/messaging/message_viewmodel.dart';
import '../../widgets/message_card.dart';

class MessageListScreen extends ConsumerWidget {
  final String groupId;

  const MessageListScreen({required this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch stream of messages
    final messagesAsync = ref.watch(messagesProvider(groupId));

    // Get viewmodel for actions
    final viewModel = ref.read(messageViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: messagesAsync.when(
        data: (messages) {
          if (messages.isEmpty) {
            return const Center(child: Text('No messages yet'));
          }

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return MessageCard(
                message: messages[index],
                onLike: () => viewModel.likeMessage(
                  messages[index].id,
                  'currentUserId', // TODO: Get from auth
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPostDialog(context, viewModel, groupId),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPostDialog(
    BuildContext context,
    MessageViewModel viewModel,
    String groupId,
  ) {
    // Dialog implementation
  }
}
```

**Rules:**
- Extend `ConsumerWidget` (not `StatelessWidget`)
- Extend `ConsumerStatefulWidget` (not `StatefulWidget`) if state needed
- Use `ref.watch()` to listen to provider changes
- Use `ref.read()` for one-time actions (button taps)
- Handle `AsyncValue` with `.when()` (data, loading, error)
- Keep views simple - delegate logic to ViewModels
- Store views in `lib/views/{feature}/`

---

## 6. Widgets (Reusable Components)

**Create stateless, reusable components:**

```dart
// widgets/message_card.dart
import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  final VoidCallback onLike;

  const MessageCard({
    required this.message,
    required this.onLike,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(message.content),
        subtitle: Text('${message.likes.length} likes'),
        trailing: IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: onLike,
        ),
      ),
    );
  }
}
```

**Rules:**
- Use `StatelessWidget` for reusable widgets
- Accept data via constructor parameters
- Use callbacks for actions (don't call ViewModels directly)
- Keep widgets small and focused
- Store in `lib/widgets/` directory

### Child Widget Organization

**ALWAYS create separate widget classes instead of widget builder methods:**

❌ **DON'T do this:**
```dart
class ProfileScreen extends ConsumerWidget {
  Widget _buildActionButton({required IconData icon}) {
    return ElevatedButton(
      child: Icon(icon),
      onPressed: () {},
    );
  }

  Widget _buildHeader() {
    return Container(...);
  }
}
```

✅ **DO this instead:**
```dart
// Create separate widget files in a widgets/ subdirectory
// views/profile/widgets/profile_action_button.dart
class ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const ProfileActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Icon(icon),
      onPressed: onPressed,
    );
  }
}

// views/profile/profile_screen.dart
class ProfileScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileActionButton(
      icon: Icons.edit,
      onPressed: () {},
    );
  }
}
```

**Benefits:**
- Better code organization and reusability
- Easier to test individual widgets
- Clearer widget tree and dependencies
- Follows Flutter best practices
- Enables widget composition

**Organization:**
- Store screen-specific widgets in `views/{feature}/widgets/`
- Store shared widgets in `lib/widgets/`
- One widget per file

---

## 7. Code Generation

**Always run code generation after creating/modifying:**
- Freezed models
- Riverpod providers
- JSON serialization

```bash
# Run once
dart run build_runner build --delete-conflicting-outputs

# Watch mode (recommended during development)
dart run build_runner watch --delete-conflicting-outputs
```

**Rules:**
- Run build_runner before testing new features
- Commit generated `.g.dart` and `.freezed.dart` files
- Never manually edit generated files

---

## 8. Firebase Integration

**Authentication:**
```dart
// services/auth_service.dart
@riverpod
class AuthService extends _$AuthService {
  @override
  Stream<User?> build() {
    return FirebaseAuth.instance.authStateChanges();
  }

  Future<void> signInWithEmail(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

// Usage in views
final authState = ref.watch(authServiceProvider);
```

**Firestore Best Practices:**
- Use `snapshots()` for real-time data
- Use `get()` for one-time reads
- Always handle errors with try-catch or AsyncValue
- Use transactions for atomic operations
- Implement pagination for large lists

---

## 9. Error Handling

**Always handle errors gracefully:**

```dart
// In ViewModels
state = await AsyncValue.guard(() async {
  // Your async operation
});

// In Views
messagesAsync.when(
  data: (data) => SuccessWidget(data),
  loading: () => LoadingWidget(),
  error: (error, stack) => ErrorWidget(error),
);
```

---

## 10. Testing

**Mock services for testing:**

```dart
// test/services/message_service_test.dart
final mockFirestore = MockFirebaseFirestore();
final service = MessageService(mockFirestore);

// Test service methods
```

**Test ViewModels with mocked services:**

```dart
// test/viewmodels/message_viewmodel_test.dart
final container = ProviderContainer(
  overrides: [
    messageServiceProvider.overrideWithValue(mockMessageService),
  ],
);

final viewModel = container.read(messageViewModelProvider.notifier);
```

---

## 11. Dependencies to Use

**Core:**
- `flutter_riverpod` + `riverpod_annotation`
- `freezed` + `freezed_annotation`
- `json_serializable`
- `go_router`

**Firebase:**
- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `firebase_storage`
- `firebase_messaging`

**Dev Dependencies:**
- `build_runner`
- `riverpod_generator`
- `flutter_lints`

---

## 12. Naming Conventions

**Files:**
- Models: `message.dart`, `user.dart`
- Services: `message_service.dart`, `auth_service.dart`
- ViewModels: `message_viewmodel.dart`, `login_viewmodel.dart`
- Views: `message_list_screen.dart`, `login_screen.dart`
- Widgets: `message_card.dart`, `user_avatar.dart`

**Classes:**
- Models: `Message`, `User` (PascalCase)
- Services: `MessageService`, `AuthService`
- ViewModels: `MessageViewModel`, `LoginViewModel`
- Screens: `MessageListScreen`, `LoginScreen`
- Widgets: `MessageCard`, `UserAvatar`

**Providers:**
- Services: `messageServiceProvider`
- Streams: `messagesProvider`, `authStateProvider`
- ViewModels: `messageViewModelProvider`

---

## 13. Common Patterns to Follow

### Pattern: Real-time List with Actions
```dart
// 1. Model
@freezed class Item { ... }

// 2. Service
class ItemService {
  Stream<List<Item>> getItems() { ... }
  Future<void> addItem(Item item) { ... }
}

// 3. Service Provider
@riverpod ItemService itemService(ref) { ... }

// 4. Stream Provider
@riverpod Stream<List<Item>> items(ref) {
  return ref.watch(itemServiceProvider).getItems();
}

// 5. ViewModel for Actions
@riverpod
class ItemViewModel extends _$ItemViewModel {
  Future<void> addItem(Item item) async { ... }
}

// 6. View
class ItemListScreen extends ConsumerWidget {
  Widget build(context, ref) {
    final items = ref.watch(itemsProvider);
    final viewModel = ref.read(itemViewModelProvider.notifier);
    // Build UI
  }
}
```

---

## 14. What NOT to Do

❌ **Don't use manual Riverpod providers** (use code generation)
❌ **Don't put business logic in Views**
❌ **Don't call Firebase directly from Views**
❌ **Don't use StatelessWidget for screens** (use ConsumerWidget)
❌ **Don't create mutable models** (use Freezed)
❌ **Don't forget to run build_runner**
❌ **Don't use Clean Architecture** (this project uses MVVM)

---

## Summary

**Data Flow:**
```
User Action → View → ViewModel → Service → Firebase
                ↓        ↓
             Updates   State
```

**Key Principles:**
1. Models are immutable (Freezed)
2. Services handle data operations only
3. ViewModels contain business logic
4. Views are thin and declarative
5. Use Riverpod code generation everywhere
6. Keep it simple - MVVM, not Clean Architecture

---

When implementing new features, always follow this MVVM + Riverpod pattern. If unsure, refer to the messaging feature example in `/docs/app-plan.md`.
