import 'package:community/viewmodels/auth/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/featured_group_card.dart';
import '../../widgets/group_card.dart';
import '../../widgets/message_card.dart';
import '../../services/group_service.dart';
import '../../services/cache_sync_service.dart';
import '../../viewmodels/messaging/message_viewmodel.dart';
import '../../viewmodels/messaging/search_viewmodel.dart';
import '../../models/group.dart';

class MessageListScreen extends ConsumerStatefulWidget {
  const MessageListScreen({super.key});

  @override
  ConsumerState<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends ConsumerState<MessageListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _hasPrefetched = false;

  @override
  void initState() {
    super.initState();
    // Trigger background cache prefetch after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchMessagesInBackground();
    });
  }

  /// Prefetch messages from all groups in the background for offline search
  Future<void> _prefetchMessagesInBackground() async {
    if (_hasPrefetched) return;
    _hasPrefetched = true;

    // Run in background without blocking UI
    final cacheSyncService = ref.read(cacheSyncServiceProvider);
    await cacheSyncService.prefetchAllGroups(messagesPerGroup: 50);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentAppUserProvider);
    return currentUserAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Error: $error'))),
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Not logged in')));
        }

        return Scaffold(
          backgroundColor: AppColors.primary,
          body: SafeArea(
            child: Column(
              children: [
                // Custom header with profile avatar and title
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: UserAvatar(imageUrl: user.photoUrl, name: user.name, radius: 20),
                      ),
                      const Expanded(
                        child: Center(child: Text('Community', style: AppTextStyles.appBarTitle)),
                      ),
                      const SizedBox(width: 40), // Balance the avatar width
                    ],
                  ),
                ),

                // Search bar with filter icon
                _buildSearchBar(),

                // Main content: Search results or Groups Grid
                Expanded(
                  child: _isSearching ? _buildSearchResults() : _buildGroupsView(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final searchState = ref.watch(searchViewModelProvider);
    final groupsAsync = ref.watch(selectableGroupsProvider);

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
                            setState(() => _isSearching = false);
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  ref.read(searchViewModelProvider.notifier).search(value);
                  setState(() => _isSearching = value.isNotEmpty);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Group filter dropdown
          groupsAsync.when(
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
      ),
    );
  }

  String _getSearchHint(String selectedGroupId, AsyncValue<List<Group>> groupsAsync) {
    if (selectedGroupId == 'all') {
      return 'Search all groups...';
    }

    return groupsAsync.maybeWhen(
      data: (groups) {
        final group = groups.where((g) => g.id == selectedGroupId).firstOrNull;
        return group != null ? 'Search in ${group.name}...' : 'Search messages...';
      },
      orElse: () => 'Search messages...',
    );
  }

  Widget _buildSearchResults() {
    final searchState = ref.watch(searchViewModelProvider);

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Offline indicator
          if (searchState.isOffline)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(Icons.offline_bolt, size: 16, color: Colors.orange.shade800),
                  const SizedBox(width: 8),
                  Text(
                    'Offline - Searching cached messages only',
                    style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                  ),
                ],
              ),
            ),

          // Cloud search indicator
          if (searchState.isSearchingCloud)
            const LinearProgressIndicator(),

          // Results header
          if (!searchState.isLoading || searchState.results.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${searchState.results.length} result${searchState.results.length == 1 ? '' : 's'}',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        if (searchState.isSearchingCloud)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Searching cloud for more results...',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.accent,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Results list
          Expanded(
            child: searchState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchState.results.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: AppColors.textSecondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text('No messages found', style: AppTextStyles.bodyMedium),
                              const SizedBox(height: 8),
                              Text(
                                searchState.selectedGroupId == 'all'
                                    ? 'Search is limited to recent messages.\nFor older messages, try selecting a specific group.'
                                    : 'No matches in recent messages.\nTry a different search term.',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: searchState.results.length,
                        itemBuilder: (context, index) {
                          final message = searchState.results[index];
                          final messageUserAsync = ref.watch(messageUserProvider(message.userId));

                          return messageUserAsync.when(
                            data: (messageUser) {
                              if (messageUser == null) {
                                return const SizedBox.shrink();
                              }
                              return MessageCard(
                                message: message,
                                messageAuthor: messageUser,
                                onTap: () {
                                  // Navigate to message detail with correct route
                                  context.pushNamed(
                                    'messageDetail',
                                    pathParameters: {
                                      'messageId': message.id,
                                      'authorId': message.userId,
                                    },
                                  );
                                },
                              );
                            },
                            loading: () => const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsView() {
    final groupsAsync = ref.watch(selectableGroupsProvider);

    return groupsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading groups: $error'),
          ],
        ),
      ),
      data: (allGroups) {
        // Separate announcements from other groups
        final announcementsGroup = allGroups.firstWhere(
          (g) => g.id == 'announcements',
          orElse: () => allGroups.first,
        );

        final otherGroups = allGroups
            .where((g) => g.id != 'announcements')
            .toList();

        // Get message count for announcements
        final announcementsMessagesAsync = ref.watch(groupMessagesProvider('announcements'));
        final announcementsCount = announcementsMessagesAsync.maybeWhen(
          data: (messages) => messages.length,
          orElse: () => null,
        );

        return Container(
          color: AppColors.background,
          child: CustomScrollView(
            slivers: [
              // Featured Announcements Card
              SliverToBoxAdapter(
                child: FeaturedGroupCard(
                  group: announcementsGroup,
                  messageCount: announcementsCount,
                  onTap: () {
                    context.push('/messages/group/${announcementsGroup.id}', extra: announcementsGroup);
                  },
                ),
              ),

              // Groups Grid
              if (otherGroups.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 64,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No other groups available',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 0,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final group = otherGroups[index];
                      return GroupCard(
                        group: group,
                        onTap: () {
                          context.push('/messages/group/${group.id}', extra: group);
                        },
                      );
                    },
                    childCount: otherGroups.length,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
