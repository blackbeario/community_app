import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../../services/image_picker_service.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/messaging/message_viewmodel.dart';
import '../../widgets/message_card.dart';
import '../../widgets/comment_card.dart';

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
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Listen to text changes to rebuild the send button state
    _commentController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

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
        setState(() {
          _selectedImage = file;
        });
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

    final content = _commentController.text.trim();
    if (content.isEmpty && _selectedImage == null) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(messageViewModelProvider.notifier).addComment(
            messageId: widget.message.id,
            userId: currentUser.id,
            content: content,
            imageFile: _selectedImage,
          );

      _commentController.clear();
      setState(() => _selectedImage = null);
      _commentFocusNode.unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(messageCommentsProvider(widget.message.id));
    // Watch for live message updates to get current comment count and likes
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
                    messageAsync.when(
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
                    ),
                    const Divider(height: 1, thickness: 1),
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
              error: (error, stack) => SingleChildScrollView(
                child: Column(
                  children: [
                    messageAsync.when(
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
                    ),
                    const Divider(height: 1, thickness: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error loading comments: $error'),
                    ),
                  ],
                ),
              ),
              data: (comments) {
                return CustomScrollView(
                  slivers: [
                    // Message at the top
                    SliverToBoxAdapter(
                      child: messageAsync.when(
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
                      ),
                    ),

                    // Divider
                    const SliverToBoxAdapter(
                      child: Divider(height: 1, thickness: 1),
                    ),

                    // Comments header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Text(
                              'Comments',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            messageAsync.when(
                              data: (liveMessage) => Text(
                                '(${liveMessage?.commentCount ?? widget.message.commentCount})',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              loading: () => Text(
                                '(${widget.message.commentCount})',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              error: (_, __) => Text(
                                '(${widget.message.commentCount})',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Comments list or empty state
                    if (comments.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.comment_outlined,
                                size: 64,
                                color: AppColors.textSecondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No comments yet',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Be the first to comment!',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final comment = comments[index];
                              final commentUserAsync = ref.watch(messageUserProvider(comment.userId));

                              return commentUserAsync.when(
                                loading: () => const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                                error: (error, stack) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Error loading user: $error'),
                                ),
                                data: (commentUser) {
                                  if (commentUser == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return CommentCard(
                                    comment: comment,
                                    commentAuthor: commentUser,
                                  );
                                },
                              );
                            },
                            childCount: comments.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Comment input
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Image preview
                if (_selectedImage != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Input row
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Image picker button
                        IconButton(
                          icon: const Icon(Icons.image, color: AppColors.accent),
                          onPressed: _isSubmitting ? null : _pickImage,
                        ),
                        const SizedBox(width: 8),

                        // Text input
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            focusNode: _commentFocusNode,
                            enabled: !_isSubmitting,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: AppTextStyles.inputHint,
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Send button
                        _isSubmitting
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send, color: AppColors.accent),
                                onPressed: 
                                  (_commentController.text.trim().isEmpty && _selectedImage == null)
                                    ? null
                                    : _submitComment,
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
