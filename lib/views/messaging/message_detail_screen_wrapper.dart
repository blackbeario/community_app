import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/theme/app_colors.dart';
import '../../models/message.dart';
import '../../viewmodels/messaging/message_viewmodel.dart';
import '../../services/message_service.dart';
import 'message_detail_screen.dart';

part 'message_detail_screen_wrapper.g.dart';

/// Wrapper that loads message and author data before showing the detail screen
class MessageDetailScreenWrapper extends ConsumerWidget {
  final String messageId;
  final String authorId;

  const MessageDetailScreenWrapper({
    super.key,
    required this.messageId,
    required this.authorId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageAsync = ref.watch(messageProvider(messageId));
    final authorAsync = ref.watch(messageUserProvider(authorId));

    return messageAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Message'),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Message'),
          backgroundColor: AppColors.primary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading message: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
      data: (message) {
        if (message == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Message'),
              backgroundColor: AppColors.primary,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.message_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Message not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return authorAsync.when(
          loading: () => Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Message'),
              backgroundColor: AppColors.primary,
            ),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Message'),
              backgroundColor: AppColors.primary,
            ),
            body: Center(
              child: Text('Error loading author: $error'),
            ),
          ),
          data: (author) {
            if (author == null) {
              return Scaffold(
                backgroundColor: AppColors.background,
                appBar: AppBar(
                  title: const Text('Message'),
                  backgroundColor: AppColors.primary,
                ),
                body: const Center(child: Text('Author not found')),
              );
            }

            // Only return MessageDetailScreen when we have both message and author
            return MessageDetailScreen(
              message: message,
              messageAuthor: author,
            );
          },
        );
      },
    );
  }
}

/// Provider to fetch a single message by ID
@riverpod
Future<Message?> message(Ref ref, String messageId) async {
  final messageService = ref.watch(messageServiceProvider);
  return messageService.getMessage(messageId);
}
