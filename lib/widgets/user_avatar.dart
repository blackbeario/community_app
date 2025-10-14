import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// A reusable circular avatar widget for displaying user profile pictures
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final widget = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              _getInitials(name),
              style: TextStyle(
                color: AppColors.white,
                fontSize: radius * 0.6,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }

    return widget;
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
