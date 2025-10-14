import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/group.dart';

/// A full-width featured card for the Announcements group
class FeaturedGroupCard extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;
  final int? messageCount;

  const FeaturedGroupCard({
    super.key,
    required this.group,
    required this.onTap,
    this.messageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Large icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    group.icon ?? '📢',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          group.name,
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (messageCount != null && messageCount! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$messageCount',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      group.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Chevron
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
