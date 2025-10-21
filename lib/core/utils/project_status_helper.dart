import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProjectStatusHelper {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'maintenance':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }
}
