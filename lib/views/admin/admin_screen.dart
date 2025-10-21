import 'package:community/views/admin/multi_project_admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_action_card.dart';
import 'widgets/create_group_dialog.dart';
import 'widgets/delete_group_dialog.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        children: [
          SizedBox(height: 8),
          AdminActionCard(
            title: 'Manage Communities',
            subtitle: 'Manage multiple communities from a single source',
            icon: Icons.admin_panel_settings,
            iconColor: Colors.red,
            onTap: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MultiProjectAdminScreen())),
          ),
          AdminActionCard(
            title: 'Create Group',
            subtitle: 'Add a new message group to the community',
            icon: Icons.add_circle_outline,
            iconColor: AppColors.accent,
            onTap: () => _showCreateGroupDialog(context),
          ),
          AdminActionCard(
            title: 'Delete Group',
            subtitle: 'Remove a message group from the community',
            icon: Icons.delete_outline,
            iconColor: Colors.red,
            onTap: () => _showDeleteGroupDialog(context),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const CreateGroupDialog());
  }

  void _showDeleteGroupDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const DeleteGroupDialog());
  }
}
