import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../services/admin/multi_project_service.dart';
import 'create_community_screen.dart';
import 'widgets/no_project_selected_view.dart';
import 'widgets/admin_dashboard_view.dart';

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
                ? const NoProjectSelectedView()
                : AdminDashboardView(
                    project: selectedProject,
                    onCreateCommunity: () => _createCommunity(context, ref, selectedProject),
                    onSeedGroups: () => _seedGroups(context, ref, selectedProject),
                    onManageUsers: () => _manageUsers(context, ref, selectedProject),
                    onCreateAdmin: () => _createAdmin(context, ref, selectedProject),
                    onViewAnalytics: () => _viewAnalytics(context, ref, selectedProject),
                    onOpenFirebaseConsole: () => _openFirebaseConsole(selectedProject),
                    onDeployFunctions: () => _deployFunctions(context, ref, selectedProject),
                  ),
          ),
        ],
      ),
    );
  }

  // Action handlers
  void _createCommunity(BuildContext context, WidgetRef ref, CommunityProject project) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateCommunityScreen(),
      ),
    );
  }

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
