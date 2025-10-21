import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/admin/multi_project_service.dart';
import 'admin_action_tile.dart';
import 'project_info_card.dart';

class AdminDashboardView extends ConsumerWidget {
  final CommunityProject project;
  final VoidCallback onCreateCommunity;
  final VoidCallback onSeedGroups;
  final VoidCallback onManageUsers;
  final VoidCallback onCreateAdmin;
  final VoidCallback onViewAnalytics;
  final VoidCallback onOpenFirebaseConsole;
  final VoidCallback onDeployFunctions;

  const AdminDashboardView({
    super.key,
    required this.project,
    required this.onCreateCommunity,
    required this.onSeedGroups,
    required this.onManageUsers,
    required this.onCreateAdmin,
    required this.onViewAnalytics,
    required this.onOpenFirebaseConsole,
    required this.onDeployFunctions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Project Info Card
        ProjectInfoCard(project: project),

        const SizedBox(height: 8),

        // Note about web app
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This admin panel is optimized for web/desktop. Mobile view is limited.',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Admin Actions List
        Text(
          'Admin Actions',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        AdminActionTile(
          customIcon: SvgPicture.asset(
            'assets/icons/firebase_flame.svg',
            width: 24,
            height: 24,
          ),
          color: const Color(0xFFFF9800),
          title: 'Create Community',
          subtitle: 'Create a new Firebase community project',
          onTap: onCreateCommunity,
        ),

        AdminActionTile(
          icon: Icons.group_add,
          color: Colors.blue,
          title: 'Seed Groups',
          subtitle: 'Initialize or update community groups',
          onTap: onSeedGroups,
        ),

        AdminActionTile(
          icon: Icons.people,
          color: Colors.green,
          title: 'Manage Users',
          subtitle: 'View and manage community members',
          onTap: onManageUsers,
        ),

        AdminActionTile(
          icon: Icons.admin_panel_settings,
          color: Colors.orange,
          title: 'Create Admin',
          subtitle: 'Grant admin privileges to a user',
          onTap: onCreateAdmin,
        ),

        AdminActionTile(
          icon: Icons.analytics,
          color: Colors.purple,
          title: 'View Analytics',
          subtitle: 'Community usage and statistics',
          onTap: onViewAnalytics,
        ),

        AdminActionTile(
          icon: Icons.open_in_new,
          color: Colors.amber,
          title: 'Firebase Console',
          subtitle: 'Open Firebase console for this project',
          onTap: onOpenFirebaseConsole,
        ),

        AdminActionTile(
          icon: Icons.cloud_upload,
          color: Colors.teal,
          title: 'Deploy Functions',
          subtitle: 'Deploy Cloud Functions to this project',
          onTap: onDeployFunctions,
        ),
      ],
    );
  }
}
