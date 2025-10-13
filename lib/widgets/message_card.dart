import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../viewmodels/auth/auth_viewmodel.dart';
import '../viewmodels/messaging/message_viewmodel.dart';
import 'user_avatar.dart';

/// A card widget for displaying a message in the feed
class MessageCard extends ConsumerWidget {
  final Message message;
  final User messageAuthor;
  final VoidCallback? onTap;

  const MessageCard({
    super.key,
    required this.message,
    required this.messageAuthor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentAppUserProvider);
    final currentUser = currentUserAsync.value;
    final isLiked = currentUser != null && message.likes.contains(currentUser.id);
    final isAnnouncement = message.groupId == 'announcements';

    return Card(
      surfaceTintColor: isAnnouncement ? AppColors.warning : null,
      elevation: isAnnouncement ? 3 : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar, Name, Group, Timestamp, More button
              Row(
                children: [
                  UserAvatar(
                    imageUrl: messageAuthor.photoUrl,
                    name: messageAuthor.name,
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                messageAuthor.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'in',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _getGroupName(message.groupId),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTimestamp(message.timestamp),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Unread indicator and more button
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.unread,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.more_horiz,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Message content
              Text(
                message.content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),

              // Image if present
              if (message.imageUrl != null && message.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: AppColors.greyLight,
                        child: const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Engagement row: Likes and Comments
              Row(
                children: [
                  // Like button with count
                  InkWell(
                    onTap: currentUser != null
                        ? () {
                            if (isLiked) {
                              ref
                                  .read(messageViewModelProvider.notifier)
                                  .unlikeMessage(message.id, currentUser.id);
                            } else {
                              ref
                                  .read(messageViewModelProvider.notifier)
                                  .likeMessage(message.id, currentUser.id);
                            }
                          }
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            color: isLiked ? AppColors.like : AppColors.textSecondary,
                            size: 18,
                          ),
                          if (message.likes.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '${message.likes.length}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isLiked ? AppColors.like : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Comment button with count
                  InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.comment_outlined,
                            color: AppColors.comment,
                            size: 18,
                          ),
                          if (message.commentCount > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '${message.commentCount}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.comment,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 30) {
      return DateFormat('dd MMMM HH:mm').format(timestamp);
    } else if (difference.inDays > 0) {
      return DateFormat('dd MMMM HH:mm').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getGroupName(String groupId) {
    // TODO: Replace with actual group lookup
    final groupNames = {
      'all': 'All posts',
      '001': 'Sport',
      '002': 'DIY',
      '003': 'General',
    };
    return groupNames[groupId] ?? 'Community';
  }
}
