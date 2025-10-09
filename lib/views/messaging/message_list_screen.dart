import 'package:community/viewmodels/auth/auth_viewmodel.dart';
import 'package:community/viewmodels/messaging/message_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageListScreen extends ConsumerWidget {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentAppUserProvider);
    return currentUserAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Not logged in'));
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Community Messages')),
          body: const Center(child: Text('Messages will appear here', style: TextStyle(fontSize: 18))),
          floatingActionButton: FloatingActionButton(
            onPressed: () => ref.read(messageViewModelProvider.notifier).postMessage(groupId: '001', userId: user.id, content: 'This is a message'),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
