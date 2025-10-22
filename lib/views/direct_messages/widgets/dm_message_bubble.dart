import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/direct_message.dart';

class DmMessageBubble extends StatelessWidget {
  final DirectMessage message;
  final bool isMine;
  final bool showTimestamp;

  const DmMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.showTimestamp = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMine) const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMine
                        ? AppColors.primary
                        : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isMine
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                      bottomRight: isMine
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Attachment if present
                      if (message.attachmentUrl != null) ...[
                        _buildAttachment(),
                        if (message.content.isNotEmpty)
                          const SizedBox(height: 8),
                      ],

                      // Message text
                      if (message.content.isNotEmpty)
                        Text(
                          message.content,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isMine ? Colors.white : Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (isMine) const SizedBox(width: 8),
            ],
          ),

          // Timestamp and read status
          if (showTimestamp) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat.jm().format(message.timestamp),
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.isRead ? AppColors.primary : Colors.grey,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachment() {
    if (message.attachmentUrl == null) return const SizedBox.shrink();

    final attachmentType = message.attachmentType ?? 'image';

    if (attachmentType == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: message.attachmentUrl!,
          width: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 200,
            height: 150,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 200,
            height: 150,
            color: Colors.grey[300],
            child: const Icon(Icons.error, color: Colors.red),
          ),
        ),
      );
    } else if (attachmentType == 'document') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMine
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file,
              color: isMine ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Document',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isMine ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
