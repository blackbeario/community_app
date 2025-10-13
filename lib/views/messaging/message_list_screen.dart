import 'package:community/viewmodels/auth/auth_viewmodel.dart';
import 'package:community/viewmodels/messaging/message_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/message_card.dart';

class MessageListScreen extends ConsumerStatefulWidget {
  const MessageListScreen({super.key});

  @override
  ConsumerState<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends ConsumerState<MessageListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentAppUserProvider);
    return currentUserAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Error: $error'))),
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Not logged in')));
        }

        return Scaffold(
          backgroundColor: AppColors.primary,
          body: SafeArea(
            child: Column(
              children: [
                // Custom header with profile avatar and title
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      UserAvatar(imageUrl: user.photoUrl, name: user.name, radius: 20),
                      const Expanded(
                        child: Center(child: Text('Messages', style: AppTextStyles.appBarTitle)),
                      ),
                      const SizedBox(width: 40), // Balance the avatar width
                    ],
                  ),
                ),

                // Search bar with filter icon
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search in community feed',
                              hintStyle: AppTextStyles.inputHint,
                              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.filter_list, color: AppColors.white),
                          onPressed: () {
                            // TODO: Implement filter functionality
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Tabs
                Container(
                  color: AppColors.surface,
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Announcements'),
                      Tab(text: 'Groups'),
                    ],
                  ),
                ),

                // Messages list
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMessagesList('announcements'),
                      _buildMessagesList('groups'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // TODO: Navigate to create message screen
              ref
                  .read(messageViewModelProvider.notifier)
                  .postMessage(groupId: 'all', userId: user.id, content: 'This is a test message');
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildMessagesList(String groupId) {
    final messagesAsync = ref.watch(groupMessagesProvider(groupId));

    return Container(
      color: AppColors.background,
      child: messagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
        data: (messages) {
          if (messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No messages yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to post in the community!',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final messageUserAsync = ref.watch(messageUserProvider(message.userId));

              return messageUserAsync.when(
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => Card(
                  child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error loading user: $error')),
                ),
                data: (messageUser) {
                  if (messageUser == null) {
                    return const Card(
                      child: Padding(padding: EdgeInsets.all(16.0), child: Text('User not found')),
                    );
                  }

                  return MessageCard(
                    message: message,
                    messageAuthor: messageUser,
                    onTap: () {
                      context.goNamed(
                        'messageDetail',
                        pathParameters: {
                          'messageId': message.id,
                          'authorId': messageUser.id,
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

}
