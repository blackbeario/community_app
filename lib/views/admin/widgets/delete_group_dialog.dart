import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/group_service.dart';
import '../../../viewmodels/admin/admin_viewmodel.dart';

class DeleteGroupDialog extends ConsumerStatefulWidget {
  const DeleteGroupDialog({super.key});

  @override
  ConsumerState<DeleteGroupDialog> createState() => _DeleteGroupDialogState();
}

class _DeleteGroupDialogState extends ConsumerState<DeleteGroupDialog> {
  String? _selectedGroupId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(allGroupsProvider);

    return AlertDialog(
      title: const Text('Delete Group'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a group to delete:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            groupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error loading groups: $error'),
              data: (groups) {
                if (groups.isEmpty) {
                  return const Text('No groups available to delete');
                }

                return DropdownButtonFormField<String>(
                  // Ensure selected group still exists in the list
                  value: groups.any((g) => g.id == _selectedGroupId) ? _selectedGroupId : null,
                  decoration: const InputDecoration(
                    labelText: 'Group',
                    border: OutlineInputBorder(),
                  ),
                  items: groups.map((group) {
                    return DropdownMenuItem<String>(
                      value: group.id,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (group.icon != null) ...[
                            Text(group.icon!, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                          ],
                          Text(group.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedGroupId = value);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Warning: This action cannot be undone. All messages in this group will become inaccessible.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _selectedGroupId == null ? null : _deleteGroup,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _deleteGroup() async {
    if (_selectedGroupId == null) return;

    // Get the group name for success message
    final groupsAsync = ref.read(allGroupsProvider);
    final groupName = groupsAsync.maybeWhen(
      data: (groups) => groups.firstWhere((g) => g.id == _selectedGroupId).name,
      orElse: () => _selectedGroupId!,
    );

    setState(() => _isLoading = true);

    try {
      final viewModel = ref.read(adminViewModelProvider.notifier);
      await viewModel.deleteGroup(_selectedGroupId!);

      if (mounted) {
        // Close dialog immediately before showing snackbar
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Group "$groupName" deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Reset loading state on error
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting group: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // Note: No finally block needed - dialog closes on success,
    // loading resets on error
  }
}
