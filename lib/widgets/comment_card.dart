import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/message.dart';
import '../models/user.dart';
import 'user_avatar.dart';

/// A card widget for displaying a comment
class CommentCard extends StatelessWidget {
  final Comment comment;
  final User commentAuthor;

  const CommentCard({
    super.key,
    required this.comment,
    required this.commentAuthor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          UserAvatar(
            imageUrl: commentAuthor.photoUrl,
            name: commentAuthor.name,
            radius: 20,
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and timestamp
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        commentAuthor.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Comment text
                if (comment.content.isNotEmpty)
                  Text(
                    comment.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),

                // Comment image
                if (comment.imageUrl != null && comment.imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      comment.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: AppColors.greyLight,
                          child: const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          color: AppColors.greyLight,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
}
