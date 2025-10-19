import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../services/admin/multi_project_service.dart';

/// Multi-Project Admin Screen
/// Allows admins to manage multiple community Firebase projects from one interface
/// NOTE: This is a temporary mobile view. Should be built as standalone web app.
class MultiProjectAdminScreen extends ConsumerWidget {
  const MultiProjectAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentAppUserProvider).valueOrNull;

    // Only admins can access
    if (currentUser == null || !currentUser.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: Text('Admin access required'),
        ),
      );
    }

    final selectedProject = ref.watch(selectedProjectProvider);
    final availableProjects = ref.watch(availableProjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Admin'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Project Selector
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community Project',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.greyLight),
                  ),
                  child: DropdownButton<CommunityProject>(
                    value: selectedProject,
                    isExpanded: true,
                    underline: Container(),
                    hint: const Text('Select a project'),
                    items: availableProjects.map((project) {
                      return DropdownMenuItem(
                        value: project,
                        child: Row(
                          children: [
                            const Icon(Icons.business, size: 18, color: AppColors.accent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    project.name,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    project.projectId,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (project) {
                      if (project != null) {
                        ref.read(selectedProjectProvider.notifier).state = project;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Dashboard content
          Expanded(
            child: selectedProject == null
                ? _buildNoProjectSelected()
                : _buildAdminDashboard(context, ref, selectedProject),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProjectSelected() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No project selected',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a community project above to manage it',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminDashboard(
    BuildContext context,
    WidgetRef ref,
    CommunityProject project,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Project Info Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.projectId,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (project.created != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Created ${_formatDate(project.created!)}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(project.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    project.status.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      color: _getStatusColor(project.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

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

        _buildActionListTile(
          icon: Icons.group_add,
          color: Colors.blue,
          title: 'Seed Groups',
          subtitle: 'Initialize or update community groups',
          onTap: () => _seedGroups(context, ref, project),
        ),

        _buildActionListTile(
          icon: Icons.people,
          color: Colors.green,
          title: 'Manage Users',
          subtitle: 'View and manage community members',
          onTap: () => _manageUsers(context, ref, project),
        ),

        _buildActionListTile(
          icon: Icons.admin_panel_settings,
          color: Colors.orange,
          title: 'Create Admin',
          subtitle: 'Grant admin privileges to a user',
          onTap: () => _createAdmin(context, ref, project),
        ),

        _buildActionListTile(
          icon: Icons.analytics,
          color: Colors.purple,
          title: 'View Analytics',
          subtitle: 'Community usage and statistics',
          onTap: () => _viewAnalytics(context, ref, project),
        ),

        _buildActionListTile(
          icon: Icons.open_in_new,
          color: Colors.amber,
          title: 'Firebase Console',
          subtitle: 'Open Firebase console for this project',
          onTap: () => _openFirebaseConsole(project),
        ),

        _buildActionListTile(
          icon: Icons.cloud_upload,
          color: Colors.teal,
          title: 'Deploy Functions',
          subtitle: 'Deploy Cloud Functions to this project',
          onTap: () => _deployFunctions(context, ref, project),
        ),
      ],
    );
  }

  Widget _buildActionListTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor(String status) {
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  // Action handlers
  void _seedGroups(BuildContext context, WidgetRef ref, CommunityProject project) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Seed groups for ${project.name} - Coming soon')),
    );
  }

  void _manageUsers(BuildContext context, WidgetRef ref, CommunityProject project) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Manage users for ${project.name} - Coming soon')),
    );
  }

  void _createAdmin(BuildContext context, WidgetRef ref, CommunityProject project) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Create admin for ${project.name} - Coming soon')),
    );
  }

  void _viewAnalytics(BuildContext context, WidgetRef ref, CommunityProject project) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Analytics for ${project.name} - Coming soon')),
    );
  }

  void _openFirebaseConsole(CommunityProject project) {
    // TODO: Launch URL with url_launcher package
    // https://console.firebase.google.com/project/${project.projectId}
  }

  void _deployFunctions(BuildContext context, WidgetRef ref, CommunityProject project) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deploy to ${project.name} - Coming soon')),
    );
  }
}
