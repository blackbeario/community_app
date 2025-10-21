import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';
import '../../../viewmodels/messaging/message_viewmodel.dart';
import '../../../widgets/message_card.dart';
import '../../../widgets/comment_card.dart';

/// Widget displaying the message and its comments in a scrollable view
class MessageWithCommentsView extends ConsumerWidget {
  final Message message;
  final User messageAuthor;
  final AsyncValue<Message?> messageAsync;
  final List<Comment> comments;

  const MessageWithCommentsView({
    super.key,
    required this.message,
    required this.messageAuthor,
    required this.messageAsync,
    required this.comments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // Message at the top
        SliverToBoxAdapter(
          child: messageAsync.when(
            data: (liveMessage) => MessageCard(
              message: liveMessage ?? message,
              messageAuthor: messageAuthor,
              onTap: null,
            ),
            loading: () => MessageCard(
              message: message,
              messageAuthor: messageAuthor,
              onTap: null,
            ),
            error: (_, __) => MessageCard(
              message: message,
              messageAuthor: messageAuthor,
              onTap: null,
            ),
          ),
        ),

        // Divider
        const SliverToBoxAdapter(child: Divider(height: 1, thickness: 1)),

        // Comments header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                messageAsync.when(
                  data: (liveMessage) => Text(
                    '(${liveMessage?.commentCount ?? message.commentCount})',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  loading: () => Text(
                    '(${message.commentCount})',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  error: (_, __) => Text(
                    '(${message.commentCount})',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Comments list or empty state
        if (comments.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 64,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No comments yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to comment!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final comment = comments[index];
                  final commentUserAsync = ref.watch(messageUserProvider(comment.userId));

                  return commentUserAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stack) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Error loading user: $error'),
                    ),
                    data: (commentUser) {
                      if (commentUser == null) {
                        return const SizedBox.shrink();
                      }
                      return CommentCard(
                        comment: comment,
                        commentAuthor: commentUser,
                      );
                    },
                  );
                },
                childCount: comments.length,
              ),
            ),
          ),
      ],
    );
  }
}
