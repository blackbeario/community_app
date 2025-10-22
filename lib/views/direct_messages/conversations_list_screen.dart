import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/direct_messages/dm_viewmodel.dart';
import 'widgets/conversation_list_tile.dart';

class ConversationsListScreen extends ConsumerWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentAppUserProvider);

    return currentUserAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Not logged in')),
          );
        }

        final conversationsAsync = ref.watch(userConversationsProvider(user.id));

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: const Text('Direct Messages', style: AppTextStyles.appBarTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add, color: Colors.white),
                onPressed: () => context.push('/direct-messages/new'),
              ),
            ],
          ),
          body: conversationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading conversations: $error'),
                ],
              ),
            ),
            data: (conversations) {
              if (conversations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start a conversation with someone',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/direct-messages/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('New Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: conversations.length,
                separatorBuilder: (context, index) => const Divider(thickness: 0.5, indent: 8, endIndent: 8, color: AppColors.grey),
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return ConversationListTile(
                    conversation: conversation,
                    currentUserId: user.id,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
