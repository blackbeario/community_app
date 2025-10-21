import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Widget to display the count of mentioned users
class MentionCounter extends StatelessWidget {
  final int count;

  const MentionCounter({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Row(
      children: [
        const Icon(Icons.alternate_email, size: 16, color: AppColors.accent),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
