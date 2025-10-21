import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/admin/multi_project_service.dart';

/// Dropdown selector for choosing which community project to manage
class ProjectSelector extends ConsumerWidget {
  final CommunityProject? selectedProject;
  final List<CommunityProject> availableProjects;
  final ValueChanged<CommunityProject?> onProjectChanged;

  const ProjectSelector({
    super.key,
    required this.selectedProject,
    required this.availableProjects,
    required this.onProjectChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
              onChanged: onProjectChanged,
            ),
          ),
        ],
      ),
    );
  }
}
