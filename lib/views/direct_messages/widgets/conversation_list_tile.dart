import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/conversation.dart';
import '../../../viewmodels/direct_messages/dm_viewmodel.dart';
import '../../../widgets/user_avatar.dart';

class ConversationListTile extends ConsumerWidget {
  final Conversation conversation;
  final String currentUserId;

  const ConversationListTile({super.key, required this.conversation, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherUserId = conversation.participants.firstWhere((id) => id != currentUserId, orElse: () => '');

    if (otherUserId.isEmpty) {
      return const SizedBox.shrink();
    }

    final otherUserAsync = ref.watch(conversationOtherUserProvider(conversation.id, currentUserId));

    return otherUserAsync.when(
      loading: () => _buildLoadingTile(),
      error: (error, stack) => _buildErrorTile(error),
      data: (otherUser) {
        if (otherUser == null) {
          return const SizedBox.shrink();
        }

        final unreadCount = conversation.unreadCount[currentUserId] ?? 0;
        final isUnread = unreadCount > 0;
        final isTyping = conversation.isTyping && conversation.typingUserId == otherUserId;

        return Slidable(
          key: Key(conversation.id),

          // The end action pane is the one at the right or the bottom side.
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => {},
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                icon: Icons.push_pin,
                label: 'Pin',
              ),
              SlidableAction(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                onPressed: (context) => showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Conversation'),
                      content: Text(
                        'Are you sure you want to delete your conversation with ${otherUser.name}? This cannot be undone.',
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            ref.read(dmViewModelProvider.notifier).deleteConversation(conversation.id);
                          },
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                ),
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: InkWell(
            onTap: () => context.push('/direct-messages/conversation/${conversation.id}'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isUnread ? AppColors.primary.withValues(alpha: 0.05) : null,
              child: Row(
                children: [
                  // Avatar
                  UserAvatar(imageUrl: otherUser.photoUrl, name: otherUser.name, radius: 28),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Name
                            Expanded(
                              child: Text(
                                otherUser.name,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Time
                            Text(
                              _formatTimestamp(conversation.lastMessageTimestamp),
                              style: AppTextStyles.caption.copyWith(
                                color: isUnread ? AppColors.primary : Colors.grey[600],
                                fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Last message or typing indicator
                        Row(
                          children: [
                            Expanded(
                              child: isTyping
                                  ? Row(
                                      children: [
                                        Text(
                                          'typing',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.primary,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      _buildLastMessagePreview(),
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: isUnread ? Colors.grey[800] : Colors.grey[600],
                                        fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),

                            // Unread badge
                            if (isUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      // Today - show time
      return DateFormat.jm().format(timestamp);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      return DateFormat.E().format(timestamp);
    } else {
      // Older - show date
      return DateFormat.MMMd().format(timestamp);
    }
  }

  String _buildLastMessagePreview() {
    if (conversation.lastMessage.isEmpty) {
      return 'Start a conversation';
    }

    final isSentByMe = conversation.lastMessageSenderId == currentUserId;
    final prefix = isSentByMe ? 'You: ' : '';

    return '$prefix${conversation.lastMessage}';
  }

  Widget _buildLoadingTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(radius: 28, backgroundColor: Colors.grey[300]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 200,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorTile(Object error) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.red[100],
            child: Icon(Icons.error_outline, color: Colors.red[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Error loading conversation', style: AppTextStyles.bodyMedium.copyWith(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }
}
