import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../viewmodels/auth/auth_viewmodel.dart';
import '../create_message_screen.dart';

class CreateMessageFab extends ConsumerWidget {
  final String groupId;

  const CreateMessageFab({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For announcements group, only show FAB to admins
    if (groupId == 'announcements') {
      final currentAppUser = ref.watch(currentAppUserProvider).valueOrNull;
      if (currentAppUser == null || !currentAppUser.isAdmin) {
        return const SizedBox.shrink();
      }
    }

    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateMessageScreen(groupId: groupId),
          ),
        ).then((newMessage) {
          if (newMessage != null) {
            // Refresh messages list or add optimistically
          }
        });
      },
      backgroundColor: AppColors.accent,
      child: const Icon(Icons.add, color: AppColors.white),
    );
  }
}
