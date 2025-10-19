import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/group.dart';
import '../services/group_service.dart';
import '../viewmodels/messaging/search_viewmodel.dart';

/// Reusable search bar widget for messages
/// Can be configured to show group filter dropdown or search within a specific group
class MessageSearchBar extends ConsumerStatefulWidget {
  /// If provided, search is scoped to this group and filter dropdown is hidden
  final String? groupId;

  /// Group name for hint text (used when groupId is provided)
  final String? groupName;

  /// Callback when search state changes (active/inactive)
  final ValueChanged<bool>? onSearchStateChanged;

  const MessageSearchBar({
    super.key,
    this.groupId,
    this.groupName,
    this.onSearchStateChanged,
  });

  @override
  ConsumerState<MessageSearchBar> createState() => _MessageSearchBarState();
}

class _MessageSearchBarState extends ConsumerState<MessageSearchBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // If groupId is provided, set it as the filter immediately
    if (widget.groupId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchViewModelProvider.notifier).setGroupFilter(widget.groupId!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchState(bool isSearching) {
    widget.onSearchStateChanged?.call(isSearching);
  }

  String _getSearchHint(String? selectedGroupId, AsyncValue<List<Group>>? groupsAsync) {
    // If scoped to a specific group
    if (widget.groupId != null) {
      return widget.groupName != null
          ? 'Search in ${widget.groupName}...'
          : 'Search messages...';
    }

    // General search with filter
    if (selectedGroupId == 'all' || selectedGroupId == null) {
      return 'Search all groups...';
    }

    return groupsAsync?.maybeWhen(
      data: (groups) {
        final group = groups.where((g) => g.id == selectedGroupId).firstOrNull;
        return group != null ? 'Search in ${group.name}...' : 'Search messages...';
      },
      orElse: () => 'Search messages...',
    ) ?? 'Search messages...';
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);
    final groupsAsync = widget.groupId == null ? ref.watch(selectableGroupsProvider) : null;

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: _getSearchHint(searchState.selectedGroupId, groupsAsync),
                  hintStyle: AppTextStyles.inputHint,
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: searchState.query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchViewModelProvider.notifier).clearSearch();
                            _updateSearchState(false);
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  ref.read(searchViewModelProvider.notifier).search(value);
                  _updateSearchState(value.isNotEmpty);
                },
              ),
            ),
          ),
          // Only show group filter if not scoped to a specific group
          if (widget.groupId == null) ...[
            const SizedBox(width: 12),
            groupsAsync!.when(
              data: (groups) => Container(
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list, color: AppColors.white),
                  tooltip: 'Filter by group',
                  onSelected: (groupId) {
                    ref.read(searchViewModelProvider.notifier).setGroupFilter(groupId);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'all',
                      child: Row(
                        children: [
                          const Text('📰', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          const Text('All Groups'),
                          if (searchState.selectedGroupId == 'all') ...[
                            const Spacer(),
                            const Icon(Icons.check, color: AppColors.accent),
                          ],
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    ...groups.map((group) {
                      return PopupMenuItem(
                        value: group.id,
                        child: Row(
                          children: [
                            Text(group.icon ?? '📁', style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Text(group.name),
                            if (searchState.selectedGroupId == group.id) ...[
                              const Spacer(),
                              const Icon(Icons.check, color: AppColors.accent),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              loading: () => Container(
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const IconButton(
                  icon: Icon(Icons.filter_list, color: AppColors.white),
                  onPressed: null,
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }
}
