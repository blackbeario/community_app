import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageListScreen extends ConsumerWidget {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Messages'),
      ),
      body: const Center(
        child: Text(
          'Messages will appear here',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to compose message screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}