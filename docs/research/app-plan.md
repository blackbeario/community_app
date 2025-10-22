# Community App - Technical Plan

## Overview

A comprehensive community-driven mobile app built with Flutter, designed to connect residents through messaging, reservations, services, and real-time community updates.

## Backend Recommendation

### Firebase (Recommended)

**Recommended Firebase Services:**
- **Firebase Auth** - User authentication (email/password, social login)
- **Cloud Firestore** - Real-time database for messages, groups, users, reservations
- **Firebase Cloud Messaging (FCM)** - Push notifications
- **Cloud Storage** - Profile pictures, ad images, documents
- **Cloud Functions** - Backend logic (scheduled tasks, complex operations)
- **Firebase Hosting** - Admin dashboard (optional)
- **Firebase Analytics** - User behavior tracking
- **App Check** - Prevent abuse

**Why Firebase:**
- Excellent Flutter integration via FlutterFire packages
- Real-time data synchronization out of the box
- Scalable and cost-effective for MVPs
- Comprehensive authentication options
- Built-in push notification support

**Alternative Considerations:**
- **Supabase** - Open-source Firebase alternative with PostgreSQL
- **AWS Amplify** - More complex but highly scalable
- **Custom backend** (Node.js/Python) - Maximum control but more maintenance

---

## Phase-Based Development Plan

### Phase 1: Foundation & Messaging (Weeks 1-6)

**MVP Goal:** Users can authenticate, join groups, and send/receive messages

**Features:**
- User authentication (email/password, Google/Apple sign-in)
- User profiles (name, photo, phone, unit number)
- Group management (community admins create groups)
- Message feed (general community + specific groups)
- Like messages
- Comment on messages
- Push notifications for new messages
- Deep linking to specific messages/threads
- Basic UI/UX with Material Design 3

**Tech Stack:**
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `firebase_messaging` - Push notifications
- `firebase_storage` - User avatars, message images
- `go_router` - Navigation with deep linking
- `flutter_riverpod` / `riverpod_annotation` - State management (MVVM pattern)
- `freezed` / `freezed_annotation` - Immutable models
- `json_serializable` - JSON serialization
- `flutter_local_notifications` - Local notification handling

**Data Models:**
```dart
// users collection
{
  userId: String,
  name: String,
  email: String,
  photoUrl: String?,
  phoneNumber: String?,
  unitNumber: String?,
  createdAt: Timestamp,
  groups: List<String>  // List of groupIds
}

// groups collection
{
  groupId: String,
  name: String,
  description: String,
  memberCount: int,
  isPublic: bool,
  createdAt: Timestamp
}

// messages collection
{
  messageId: String,
  groupId: String,
  userId: String,
  content: String,
  imageUrl: String?,
  timestamp: Timestamp,
  likes: List<String>,  // List of userIds
  commentCount: int
}

// comments collection
{
  commentId: String,
  messageId: String,
  userId: String,
  content: String,
  timestamp: Timestamp
}
```

---

### Phase 2: Direct Messaging (Weeks 7-9)

**Features:**
- One-on-one DM conversations
- User directory/search
- Typing indicators
- Read receipts
- Push notifications for DMs
- Message attachments (photos, documents)

**Tech Stack:**
- Reuse existing messaging infrastructure
- `image_picker` - Photo attachments
- `file_picker` - Document attachments

**Data Models:**
```dart
// conversations collection
{
  conversationId: String,
  participants: List<String>,  // [userId1, userId2]
  lastMessage: String,
  lastMessageTimestamp: Timestamp,
  unreadCount: Map<String, int>  // {userId: count}
}

// dm_messages subcollection under conversations
{
  messageId: String,
  senderId: String,
  content: String,
  attachmentUrl: String?,
  attachmentType: String?,  // 'image' | 'document'
  timestamp: Timestamp,
  isRead: bool
}
```

---

### Phase 3: Reservations & Scheduling (Weeks 10-14)

**Features:**
- Amenity booking system (golf tees, pickleball, pool)
- Calendar view (day/week/month)
- Booking rules (time slots, max bookings per user, cancellation policy)
- Waitlist management
- Booking confirmations via push notifications
- Admin panel for amenity management

**Tech Stack:**
- `table_calendar` - Calendar UI
- Cloud Functions - Booking validation, waitlist logic
- Firestore scheduled queries - Automated cancellations/reminders

**Data Models:**
```dart
// amenities collection
{
  amenityId: String,
  name: String,
  type: String,  // 'golf', 'pickleball', 'pool', etc.
  description: String,
  rules: {
    maxBookingsPerUser: int,
    advanceBookingDays: int,
    cancellationHours: int,
    bookingDurationMinutes: int
  },
  timeSlots: List<String>,  // ['08:00', '09:00', '10:00', ...]
  maxBookings: int,
  isActive: bool
}

// bookings collection
{
  bookingId: String,
  amenityId: String,
  userId: String,
  startTime: Timestamp,
  endTime: Timestamp,
  status: String,  // 'confirmed', 'cancelled', 'completed'
  createdAt: Timestamp,
  partySize: int?
}

// waitlist collection
{
  waitlistId: String,
  amenityId: String,
  userId: String,
  requestedDate: Timestamp,
  requestedTimeSlot: String,
  status: String,  // 'waiting', 'notified', 'expired'
  createdAt: Timestamp
}
```

---

### Phase 4: Dining & Services (Weeks 15-17)

**Features:**
- Restaurant/dining reservation requests
- Menu viewer (with photos, prices, dietary info)
- Special events calendar
- Request tracking (pending/approved/declined)

**Data Models:**
```dart
// dining_reservations collection
{
  reservationId: String,
  userId: String,
  date: Timestamp,
  time: String,
  partySize: int,
  specialRequests: String?,
  status: String,  // 'pending', 'approved', 'declined', 'completed'
  createdAt: Timestamp
}

// menu_items collection
{
  itemId: String,
  category: String,
  name: String,
  description: String,
  price: double,
  imageUrl: String?,
  dietaryInfo: List<String>,  // ['vegetarian', 'gluten-free', ...]
  isAvailable: bool
}
```

---

### Phase 5: Advertising & Directory (Weeks 18-21)

**Features:**
- Advertiser profiles (business name, services, contact, website)
- Ad submission portal (for businesses)
- Ad approval workflow (admin review)
- Banner ads in app (rotational display)
- Searchable directory with filters (category, distance, rating)
- Click tracking for analytics

**Tech Stack:**
- Cloud Functions - Ad approval notifications
- `url_launcher` - Open business websites/call numbers
- Firebase Remote Config - Ad rotation settings

**Data Models:**
```dart
// advertisers collection
{
  advertiserId: String,
  businessName: String,
  category: String,
  description: String,
  services: List<String>,
  contactPhone: String,
  contactEmail: String,
  website: String?,
  logoUrl: String,
  address: String?,
  rating: double,
  reviewCount: int,
  isApproved: bool,
  createdAt: Timestamp
}

// ads collection
{
  adId: String,
  advertiserId: String,
  title: String,
  imageUrl: String,
  targetUrl: String?,
  startDate: Timestamp,
  endDate: Timestamp,
  impressions: int,
  clicks: int,
  status: String,  // 'pending', 'approved', 'active', 'expired'
  priority: int
}
```

---

### Phase 6: Interactive Community Map (Weeks 22-25)

**Features:**
- Map view of community
- User-submitted incidents (construction, traffic, outages, hazards)
- Pin types with color coding
- Photo attachments for incidents
- Upvote/comment on incidents
- Time-based auto-expiration
- Push notifications for nearby incidents

**Tech Stack:**
- `google_maps_flutter` or `flutter_map` (open source)
- `geolocator` - User location
- `cloud_firestore` with GeoHash queries for location-based searches

**Data Models:**
```dart
// incidents collection
{
  incidentId: String,
  type: String,  // 'construction', 'traffic', 'outage', 'hazard'
  title: String,
  description: String,
  location: {
    lat: double,
    lng: double,
    geoHash: String,  // For efficient location queries
    address: String?
  },
  photoUrl: String?,
  reportedBy: String,  // userId
  timestamp: Timestamp,
  expiresAt: Timestamp?,
  upvotes: List<String>,  // List of userIds
  status: String,  // 'active', 'resolved', 'expired'
  commentCount: int
}
```

---

### Phase 7: AI-Powered FAQ & Polish (Weeks 26-28)

**Features:**
- FAQ knowledge base
- AI chatbot (GPT-4 or Gemini)
- Context-aware navigation (e.g., "How do I book the pool?" → navigates to reservations)
- Search history
- Final UI/UX polish
- Performance optimization
- Accessibility improvements

**Tech Stack:**
- OpenAI API or Google Vertex AI
- Vector database (Pinecone/Firebase Extensions for semantic search)
- `flutter_chat_ui` - Chat interface

**Data Models:**
```dart
// faq_entries collection
{
  faqId: String,
  question: String,
  answer: String,
  category: String,
  relatedScreenRoute: String?,  // Deep link to relevant app section
  keywords: List<String>,
  viewCount: int,
  isHelpful: int,  // User feedback
  createdAt: Timestamp
}

// faq_conversations collection (user chat history)
{
  conversationId: String,
  userId: String,
  messages: List<{
    role: String,  // 'user' | 'assistant'
    content: String,
    timestamp: Timestamp
  }>,
  createdAt: Timestamp
}
```

---

## Recommended Project Structure

```
lib/
├── core/
│   ├── config/          # Firebase config, environment variables
│   │   ├── firebase_options.dart
│   │   └── env_config.dart
│   ├── theme/           # App theme, colors, typography
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── text_styles.dart
│   ├── routing/         # go_router configuration
│   │   └── app_router.dart
│   └── utils/           # Helpers, extensions, constants
│       ├── constants.dart
│       ├── extensions.dart
│       └── validators.dart
├── models/              # Freezed data models (shared across features)
│   ├── user.dart
│   ├── message.dart
│   ├── group.dart
│   └── ...
├── services/            # Firebase services (data layer)
│   ├── auth_service.dart
│   ├── message_service.dart
│   ├── storage_service.dart
│   └── ...
├── viewmodels/          # Business logic with Riverpod
│   ├── auth/
│   │   ├── auth_viewmodel.dart
│   │   └── login_viewmodel.dart
│   ├── messaging/
│   │   ├── message_viewmodel.dart
│   │   └── comment_viewmodel.dart
│   ├── direct_messages/
│   ├── reservations/
│   ├── directory/
│   ├── map/
│   ├── faq/
│   └── profile/
├── views/               # UI screens and widgets
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── messaging/
│   │   ├── message_list_screen.dart
│   │   └── message_detail_screen.dart
│   ├── direct_messages/
│   ├── reservations/
│   ├── directory/
│   ├── map/
│   ├── faq/
│   └── profile/
├── widgets/             # Reusable UI components
│   ├── message_card.dart
│   ├── user_avatar.dart
│   └── loading_indicator.dart
└── main.dart
```

**Architecture Pattern:** MVVM (Model-View-ViewModel) with Riverpod
- `models/` - Freezed data models with JSON serialization
- `services/` - Firebase interactions (Firestore, Auth, Storage, FCM)
- `viewmodels/` - Business logic, state management with Riverpod providers
- `views/` - UI screens that watch ViewModels via Riverpod
- `widgets/` - Reusable, stateless UI components

**Benefits of MVVM:**
- Simpler than Clean Architecture (3 layers instead of 4+)
- Clear separation: View → ViewModel → Service
- Easy to test (mock services)
- Less boilerplate (2-3 providers per feature vs 6-8 in Clean Architecture)
- Faster development without sacrificing quality

---

## Security Considerations

### 1. Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated users can read/write
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    match /messages/{messageId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.userId;
    }

    // Admin-only collections
    match /amenities/{amenityId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

### 2. App Check
- Enable App Check to prevent API abuse
- Protect Cloud Functions and Firebase services

### 3. User Verification
- Email verification required
- Unit number verification by admin (optional)
- Phone number verification for sensitive operations

### 4. Content Moderation
- Report/flag system for inappropriate content
- Admin review queue
- Automated content filtering (Cloud Functions)

### 5. Rate Limiting
- Cloud Functions to prevent spam
- Firestore quota monitoring
- API rate limiting for external services

---

## Estimated Costs (Firebase)

### Initial Scale (500 active users)

**Firebase Blaze Plan (Pay-as-you-go):**
- **Firestore:** ~$25-50/month
  - Reads: ~5M/month
  - Writes: ~1M/month
  - Storage: ~5GB
- **Cloud Storage:** ~$10-20/month
  - 10GB storage
  - 50GB bandwidth
- **Cloud Functions:** ~$10-30/month
  - 1M invocations
  - 400K GB-seconds compute
- **Firebase Cloud Messaging:** Free
- **Authentication:** Free
- **Hosting:** Free (within limits)

**Total: $50-100/month**

### Growth Scale (5,000 active users)
- **Total: $300-500/month**

Costs scale linearly with user growth. Monitor via Firebase console.

---

## Key Performance Indicators (KPIs)

### Phase 1 Success Metrics
- User registration rate: >70% of invited users
- Daily active users (DAU): >30%
- Messages per user per day: >3
- Push notification open rate: >40%
- App crash-free rate: >99%

### Future Metrics
- Reservation booking rate
- Advertiser directory engagement
- Map incident reports per week
- AI FAQ resolution rate

---

## Risk Mitigation

### Technical Risks
1. **Firebase costs exceeding budget**
   - Mitigation: Set budget alerts, implement caching, optimize queries
2. **Push notification delivery issues**
   - Mitigation: Test across iOS/Android, implement retry logic
3. **Real-time performance degradation**
   - Mitigation: Pagination, query optimization, consider sharding

### Product Risks
1. **Low user adoption**
   - Mitigation: User research, beta testing, iterative improvements
2. **Content moderation challenges**
   - Mitigation: Automated filtering, active admin team, clear guidelines

---

## Timeline Summary

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| Phase 1 | 6 weeks | Authentication, Groups, Messaging, Push Notifications |
| Phase 2 | 3 weeks | Direct Messaging |
| Phase 3 | 5 weeks | Reservations & Scheduling |
| Phase 4 | 3 weeks | Dining Services |
| Phase 5 | 4 weeks | Advertising & Directory |
| Phase 6 | 4 weeks | Community Map |
| Phase 7 | 3 weeks | AI FAQ & Polish |
| **Total** | **28 weeks** | Full-featured community app |

---

## Next Steps

1. **Design Review** - Review UI/UX designs provided by stakeholders
2. **Firebase Setup** - Create Firebase project, configure FlutterFire
3. **Project Structure** - Set up clean architecture folder structure
4. **Phase 1 Development** - Begin with authentication and messaging
5. **Beta Testing** - Deploy to TestFlight/Internal Testing after Phase 1
6. **Iterate** - Gather feedback and refine before proceeding to Phase 2

---

## Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Go Router Documentation](https://pub.dev/packages/go_router)
- [Flutter Best Practices](https://docs.flutter.dev/development/best-practices)
- [Firebase Pricing Calculator](https://firebase.google.com/pricing)

---

---

## Architecture Deep Dive: MVVM + Riverpod

### Example: Messaging Feature Structure

```
lib/
├── models/
│   └── message.dart              # Freezed model with JSON serialization
├── services/
│   └── message_service.dart      # Firebase Firestore operations
├── viewmodels/
│   └── messaging/
│       └── message_viewmodel.dart # Business logic + Riverpod providers
└── views/
    └── messaging/
        ├── message_list_screen.dart
        └── widgets/
            ├── message_card.dart
            └── message_input.dart
```

### Code Example: Message Feature

**1. Model (Freezed + JSON)**
```dart
// models/message.dart
@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String groupId,
    required String userId,
    required String content,
    required DateTime timestamp,
    @Default([]) List<String> likes,
    @Default(0) int commentCount,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}
```

**2. Service (Firebase operations)**
```dart
// services/message_service.dart
class MessageService {
  final FirebaseFirestore _firestore;

  MessageService(this._firestore);

  Stream<List<Message>> getMessages(String groupId) {
    return _firestore
        .collection('messages')
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) =>
            Message.fromJson(doc.data())).toList());
  }

  Future<void> postMessage(Message message) async {
    await _firestore.collection('messages').doc(message.id).set(message.toJson());
  }
}

// Provider for MessageService
@riverpod
MessageService messageService(MessageServiceRef ref) {
  return MessageService(FirebaseFirestore.instance);
}
```

**3. ViewModel (Business logic)**
```dart
// viewmodels/messaging/message_viewmodel.dart
@riverpod
Stream<List<Message>> messages(MessagesRef ref, String groupId) {
  final service = ref.watch(messageServiceProvider);
  return service.getMessages(groupId);
}

@riverpod
class MessageViewModel extends _$MessageViewModel {
  @override
  FutureOr<void> build() {}

  Future<void> postMessage(String groupId, String userId, String content) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        groupId: groupId,
        userId: userId,
        content: content,
        timestamp: DateTime.now(),
      );
      await ref.read(messageServiceProvider).postMessage(message);
    });
  }
}
```

**4. View (UI with Consumer)**
```dart
// views/messaging/message_list_screen.dart
class MessageListScreen extends ConsumerWidget {
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider(groupId));
    final viewModel = ref.read(messageViewModelProvider.notifier);

    return messagesAsync.when(
      data: (messages) => ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) => MessageCard(message: messages[index]),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### Key Riverpod Patterns for This Project

**1. Service Providers (Singleton)**
```dart
@riverpod
MessageService messageService(MessageServiceRef ref) {
  return MessageService(FirebaseFirestore.instance);
}
```

**2. Stream Providers (Real-time data)**
```dart
@riverpod
Stream<List<Message>> messages(MessagesRef ref, String groupId) {
  return ref.watch(messageServiceProvider).getMessages(groupId);
}
```

**3. AsyncNotifier (Actions with loading states)**
```dart
@riverpod
class MessageViewModel extends _$MessageViewModel {
  @override
  FutureOr<void> build() {}

  Future<void> someAction() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // perform action
    });
  }
}
```

**4. StateNotifier (Complex state management)**
```dart
@riverpod
class BookingViewModel extends _$BookingViewModel {
  @override
  BookingState build() => BookingState.initial();

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }
}
```

---

**Document Version:** 2.0
**Last Updated:** 2025-10-08
**Status:** Updated to MVVM + Riverpod Architecture
