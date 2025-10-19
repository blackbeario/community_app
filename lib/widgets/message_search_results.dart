import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../viewmodels/messaging/message_viewmodel.dart';
import '../viewmodels/messaging/search_viewmodel.dart';
import 'message_card.dart';

/// Reusable search results widget for messages
/// Displays search results from SearchViewModel with loading states and error handling
class MessageSearchResults extends ConsumerWidget {
  const MessageSearchResults({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
}
