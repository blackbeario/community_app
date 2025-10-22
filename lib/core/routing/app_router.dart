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
import '../../views/direct_messages/conversations_list_screen.dart';
import '../../views/direct_messages/conversation_screen.dart';
import '../../views/direct_messages/new_conversation_screen.dart';
import '../../views/profile/profile_screen.dart';
import '../../views/admin/admin_screen.dart';
import '../../models/group.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/direct_messages/dm_viewmodel.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

// Export root navigator key for use in FCM service
final rootNavigatorKey = _rootNavigatorKey;

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
              path: '/direct-messages',
              name: 'directMessages',
              builder: (context, state) => const ConversationsListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  name: 'newConversation',
                  builder: (context, state) => const NewConversationScreen(),
                ),
                GoRoute(
                  path: 'conversation/:conversationId',
                  name: 'conversation',
                  builder: (context, state) {
                    final conversationId = state.pathParameters['conversationId']!;
                    return ConversationScreen(
                      conversationId: conversationId,
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
            GoRoute(
              path: '/admin',
              name: 'admin',
              builder: (context, state) => const AdminScreen(),
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
    final currentUserAsync = ref.watch(currentAppUserProvider);
    final isAdmin = currentUserAsync.maybeWhen(
      data: (user) => user?.isAdmin ?? false,
      orElse: () => false,
    );

    final userId = currentUserAsync.maybeWhen(
      data: (user) => user?.id,
      orElse: () => null,
    );

    // Watch unread DM count
    final unreadDmCountAsync = userId != null
        ? ref.watch(unreadDmCountProvider(userId))
        : const AsyncValue<int>.data(0);

    final unreadDmCount = unreadDmCountAsync.maybeWhen(
      data: (count) => count,
      orElse: () => 0,
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context, isAdmin),
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: unreadDmCount > 0
                ? Badge(
                    label: Text(unreadDmCount > 99 ? '99+' : '$unreadDmCount'),
                    child: const Icon(Icons.chat),
                  )
                : const Icon(Icons.chat),
            label: 'DMs',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          if (isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context, bool isAdmin) {
    final location = GoRouterState.of(context).matchedLocation;

    // Check if on direct messages screen
    if (location.startsWith('/direct-messages')) {
      return 1;
    }

    switch (location) {
      case '/messages':
        return 0;
      case '/profile':
        return 2;
      case '/admin':
        return isAdmin ? 3 : 0;
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
        context.go('/direct-messages');
        break;
      case 2:
        context.go('/profile');
        break;
      case 3:
        context.go('/admin');
        break;
    }
  }
}