import 'package:community/viewmodels/auth/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/featured_group_card.dart';
import '../../widgets/group_card.dart';
import '../../services/group_service.dart';
import '../../viewmodels/messaging/message_viewmodel.dart';

class MessageListScreen extends ConsumerStatefulWidget {
  const MessageListScreen({super.key});

  @override
  ConsumerState<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends ConsumerState<MessageListScreen> {
  final TextEditingController _searchController = TextEditingController();

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
                Container(
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
                              hintText: 'Search messages...',
                              hintStyle: AppTextStyles.inputHint,
                              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onChanged: (value) {
                              // TODO: Implement search
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.filter_list, color: AppColors.white),
                          onPressed: () {
                            // TODO: Implement filter functionality
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Main content: Featured Announcements + Groups Grid
                Expanded(
                  child: _buildGroupsView(),
                ),
              ],
            ),
          ),
        );
      },
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
                    childAspectRatio: 0.85,
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
