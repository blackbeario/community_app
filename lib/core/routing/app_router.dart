import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../services/auth_service.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/messaging/message_list_screen.dart';
import '../../views/messaging/message_detail_screen_wrapper.dart';
import '../../views/messaging/group_messages_screen.dart';
import '../../views/profile/profile_screen.dart';
import '../../models/group.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
      initialLocation: '/messages',
      redirect: (context, state) {
        final user = ref.read(currentUserProvider);
        final isLoggedIn = user != null;

        final isLoginRoute = state.matchedLocation.startsWith('/auth');

        if (!isLoggedIn && !isLoginRoute) {
          return '/auth/login';
        }

        if (isLoggedIn && isLoginRoute) {
          return '/messages';
        }

        return null;
      },
      routes: [
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return MainScaffold(child: child);
          },
          routes: [
            GoRoute(
              path: '/messages',
              name: 'messages',
              builder: (context, state) => const MessageListScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:messageId/:authorId',
                  name: 'messageDetail',
                  builder: (context, state) {
                    final messageId = state.pathParameters['messageId']!;
                    final authorId = state.pathParameters['authorId']!;
                    return MessageDetailScreenWrapper(
                      messageId: messageId,
                      authorId: authorId,
                    );
                  },
                ),
                GoRoute(
                  path: 'group/:groupId',
                  name: 'groupMessages',
                  builder: (context, state) {
                    final groupId = state.pathParameters['groupId']!;
                    final group = state.extra as Group?;
                    return GroupMessagesScreen(
                      groupId: groupId,
                      group: group,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/auth/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/auth/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
      ],
  );
}

class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    switch (location) {
      case '/messages':
        return 0;
      case '/profile':
        return 1;
      default:
        return 0;
    }
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/messages');
        break;
      case 1:
        context.go('/profile');
        break;
    }
  }
}