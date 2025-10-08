import 'package:intl/intl.dart';

/// Extensions for DateTime
extension DateTimeExtensions on DateTime {
  /// Format date as "DD Month HH:MM" (e.g., "09 February 09:18")
  String toMessageTimestamp() {
    return DateFormat('dd MMMM HH:mm').format(this);
  }

  /// Format date as "DD/MM/YYYY"
  String toShortDate() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Format time as "HH:MM"
  String toTimeOnly() {
    return DateFormat('HH:mm').format(this);
  }

  /// Get relative time (e.g., "5 minutes ago", "2 hours ago")
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return toShortDate();
    }
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}

/// Extensions for String
extension StringExtensions on String {
  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Truncate string to max length with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

/// Extensions for List
extension ListExtensions<T> on List<T> {
  /// Safely get item at index, return null if out of bounds
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

/// Extensions for int
extension IntExtensions on int {
  /// Format number with K/M suffix (e.g., 1000 -> "1K", 1500000 -> "1.5M")
  String toCompactFormat() {
    if (this < 1000) return toString();
    if (this < 1000000) return '${(this / 1000).toStringAsFixed(1)}K';
    return '${(this / 1000000).toStringAsFixed(1)}M';
  }
}
