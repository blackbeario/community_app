import 'package:community/viewmodels/auth/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/message_search_bar.dart';
import '../../widgets/message_search_results.dart';
import '../../services/group_service.dart';
import '../../services/cache_sync_service.dart';
import 'widgets/groups_list_view.dart';

class MessageListScreen extends ConsumerStatefulWidget {
  const MessageListScreen({super.key});

  @override
  ConsumerState<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends ConsumerState<MessageListScreen> {
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Trigger background cache prefetch after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Run prefetch in background without blocking UI
      final cacheSyncService = ref.read(cacheSyncServiceProvider);
      cacheSyncService.prefetchAllGroups(messagesPerGroup: 50);
    });
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
                        child: Center(child: Text('Message Groups', style: AppTextStyles.appBarTitle)),
                      ),
                      const SizedBox(width: 40), // Balance the avatar width
                    ],
                  ),
                ),

                // Search bar with filter icon
                MessageSearchBar(
                  onSearchStateChanged: (isSearching) {
                    setState(() => _isSearching = isSearching);
                  },
                ),

                // Main content: Search results or Groups Grid
                Expanded(
                  child: _isSearching
                      ? const MessageSearchResults()
                      : ref
                            .watch(selectableGroupsProvider)
                            .when(
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
                              data: (groups) => GroupsListView(groups: groups),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
