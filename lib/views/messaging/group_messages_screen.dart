import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/group.dart';
import '../../viewmodels/messaging/message_viewmodel.dart';
import '../../widgets/message_card.dart';
import '../../widgets/message_search_bar.dart';
import '../../widgets/message_search_results.dart';
import 'widgets/create_message_fab.dart';

/// Screen to display messages for a specific group
class GroupMessagesScreen extends ConsumerStatefulWidget {
  final String groupId;
  final Group? group;

  const GroupMessagesScreen({
    super.key,
    required this.groupId,
    this.group,
  });

  @override
  ConsumerState<GroupMessagesScreen> createState() => _GroupMessagesScreenState();
}

class _GroupMessagesScreenState extends ConsumerState<GroupMessagesScreen> {
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(groupMessagesProvider(widget.groupId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Row(
          children: [
            if (widget.group?.icon != null) ...[
              Text(
                widget.group!.icon!,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.group?.name ?? 'Group Messages',
                    style: AppTextStyles.appBarTitle.copyWith(fontSize: 18),
                  ),
                  if (widget.group?.memberCount != null && widget.group!.memberCount > 0)
                    Text(
                      '${widget.group!.memberCount} members',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar (conditionally shown)
          if (_showSearch)
            MessageSearchBar(
              groupId: widget.groupId,
              groupName: widget.group?.name,
              onSearchStateChanged: (isSearching) {
                // Additional logic if needed when search state changes
              },
            ),

          // Main content: search results or messages
          Expanded(
            child: _showSearch
                ? const MessageSearchResults()
                : messagesAsync.when(
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
                              Icon(
                                Icons.message_outlined,
                                size: 64,
                                color: AppColors.textSecondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Be the first to post in ${widget.group?.name ?? 'this group'}!',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
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
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('Error loading user: $error'),
                              ),
                            ),
                            data: (messageUser) {
                              if (messageUser == null) {
                                return const Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('User not found'),
                                  ),
                                );
                              }

                              return MessageCard(
                                message: message,
                                messageAuthor: messageUser,
                                onTap: () {
                                  context.pushNamed(
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
          ),
        ],
      ),
      floatingActionButton: CreateMessageFab(groupId: widget.groupId),
    );
  }
}
