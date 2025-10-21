import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../../services/image_picker_service.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/messaging/message_viewmodel.dart';
import '../../widgets/message_card.dart';
import 'widgets/comment_input_section.dart';
import 'widgets/message_with_comments_view.dart';

class MessageDetailScreen extends ConsumerStatefulWidget {
  final Message message;
  final User messageAuthor;

  const MessageDetailScreen({
    super.key,
    required this.message,
    required this.messageAuthor,
  });

  @override
  ConsumerState<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends ConsumerState<MessageDetailScreen> {
  final GlobalKey<FlutterMentionsState> _mentionsKey = GlobalKey<FlutterMentionsState>();
  File? _selectedImage;
  bool _isSubmitting = false;
  final List<String> _mentionedUserIds = [];

  Future<void> _pickImage() async {
    try {
      final imagePickerService = ref.read(imagePickerServiceProvider);
      final file = await imagePickerService.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (file != null) {
        setState(() => _selectedImage = file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    final currentUser = ref.read(currentAppUserProvider).value;
    if (currentUser == null) return;

    // Get content from FlutterMentions
    final content = _mentionsKey.currentState?.controller?.text.trim() ?? '';
    if (content.isEmpty && _selectedImage == null) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(messageViewModelProvider.notifier).addComment(
            messageId: widget.message.id,
            userId: currentUser.id,
            content: content,
            imageFile: _selectedImage,
            mentions: _mentionedUserIds,
          );

      // Clear the mentions input
      _mentionsKey.currentState?.controller?.clear();
      setState(() {
        _selectedImage = null;
        _mentionedUserIds.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(messageCommentsProvider(widget.message.id));
    final messageAsync = ref.watch(messageStreamProvider(widget.message.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Message'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Combined scrollable area with message and comments
          Expanded(
            child: commentsAsync.when(
              loading: () => SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMessageCard(messageAsync),
                    const Divider(height: 1, thickness: 1),
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
              error: (error, stack) => SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMessageCard(messageAsync),
                    const Divider(height: 1, thickness: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error loading comments: $error'),
                    ),
                  ],
                ),
              ),
              data: (comments) => MessageWithCommentsView(
                message: widget.message,
                messageAuthor: widget.messageAuthor,
                messageAsync: messageAsync,
                comments: comments,
              ),
            ),
          ),

          // Comment input
          CommentInputSection(
            mentionsKey: _mentionsKey,
            selectedImage: _selectedImage,
            isSubmitting: _isSubmitting,
            onPickImage: _pickImage,
            onRemoveImage: () => setState(() => _selectedImage = null),
            onSubmit: _submitComment,
            onMentionAdd: (mention) {
              final userId = mention['id'] as String;
              if (!_mentionedUserIds.contains(userId)) {
                setState(() => _mentionedUserIds.add(userId));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(AsyncValue<Message?> messageAsync) {
    return messageAsync.when(
      data: (liveMessage) => MessageCard(
        message: liveMessage ?? widget.message,
        messageAuthor: widget.messageAuthor,
        onTap: null,
      ),
      loading: () => MessageCard(
        message: widget.message,
        messageAuthor: widget.messageAuthor,
        onTap: null,
      ),
      error: (_, __) => MessageCard(
        message: widget.message,
        messageAuthor: widget.messageAuthor,
        onTap: null,
      ),
    );
  }
}
