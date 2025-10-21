import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/group.dart';
import '../../../viewmodels/messaging/message_viewmodel.dart';
import '../../../widgets/featured_group_card.dart';
import '../../../widgets/group_card.dart';

class GroupsListView extends ConsumerWidget {
  final List<Group> groups;

  const GroupsListView({
    super.key,
    required this.groups,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Separate announcements from other groups
    final announcementsGroup = groups.firstWhere(
      (g) => g.id == 'announcements',
      orElse: () => groups.first,
    );

    final otherGroups = groups.where((g) => g.id != 'announcements').toList();

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

          // Groups List
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
            SliverList(
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
  }
}
