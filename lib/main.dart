// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/config/firebase_providers.dart';
import 'services/group_service.dart';
import 'services/user_cache_sync_service.dart';
import 'services/fcm_service.dart';
import 'core/utils/group_initializer.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Create a temporary ProviderContainer to initialize groups
  final container = ProviderContainer();
  final groupService = container.read(groupServiceProvider);
  final initializer = GroupInitializer(groupService);

  // Initialize groups if needed (one-time setup)
  await initializer.initializeIfNeeded();

  container.dispose();

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    // Listen for auth state changes and initialize FCM
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    // Wait a bit for auth to initialize
    await Future.delayed(const Duration(seconds: 1));

    ref.listenManual(
      authStateChangesProvider,
      (previous, next) {
        next.whenData((user) async {
          if (user != null) {
            // User logged in - initialize FCM
            final fcmService = ref.read(fcmServiceProvider);
            await fcmService.initialize(user.uid);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    // Initialize user cache sync on startup
    ref.watch(userCacheSyncProvider);

    return Portal(
      child: MaterialApp.router(
        title: 'Community',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
