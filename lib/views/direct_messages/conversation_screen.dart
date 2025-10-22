import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/direct_message.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/direct_messages/dm_viewmodel.dart';
import '../../viewmodels/navigation/screen_tracking_viewmodel.dart';
import '../../widgets/user_avatar.dart';
import 'widgets/dm_message_bubble.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ConversationScreen({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isTyping = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Set current screen for unread count management
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentScreenProvider.notifier).setScreen(
        '/direct-messages/conversation/${widget.conversationId}',
      );
    });
  }

  @override
  void dispose() {
    // Clear current screen when leaving
    ref.read(currentScreenProvider.notifier).setScreen(null);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentAppUserProvider);

    return currentUserAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (currentUser) {
        if (currentUser == null) {
          return const Scaffold(
            body: Center(child: Text('Not logged in')),
          );
        }

        final conversationAsync = ref.watch(
          conversationProvider(widget.conversationId),
        );
        final messagesAsync = ref.watch(
          conversationMessagesProvider(widget.conversationId),
        );

        return conversationAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(child: Text('Error: $error')),
          ),
          data: (conversation) {
            // If conversation is null (deleted), navigate back
            if (conversation == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.go('/direct-messages');
                }
              });
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: AppColors.primary,
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            final otherUserId = conversation.participants.firstWhere(
              (id) => id != currentUser.id,
              orElse: () => '',
            );

            if (otherUserId.isEmpty) {
              return const Scaffold(
                body: Center(child: Text('Invalid conversation')),
              );
            }

            final otherUserAsync = ref.watch(
              conversationOtherUserProvider(
                widget.conversationId,
                currentUser.id,
              ),
            );

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: _buildAppBar(otherUserAsync),
              body: Column(
                children: [
                  // Messages list
                  Expanded(
                    child: messagesAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Center(
                        child: Text('Error loading messages: $error'),
                      ),
                      data: (messages) {
                        if (messages.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.message_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No messages yet',
                                  style: AppTextStyles.h3.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Send a message to start the conversation',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Mark messages as read using scheduleMicrotask for faster execution
                        // This minimizes the badge flash when receiving messages
                        // while actively viewing the conversation
                        scheduleMicrotask(() {
                          if (mounted) {
                            _markMessagesAsRead(
                              messages,
                              currentUser.id,
                              otherUserId,
                            );
                          }
                        });

                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMine = message.senderId == currentUser.id;

                            // Show timestamp for first message and every 10 messages
                            final showTimestamp = index == 0 ||
                                (index % 10 == 0);

                            return DmMessageBubble(
                              message: message,
                              isMine: isMine,
                              showTimestamp: showTimestamp,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Typing indicator
                  if (conversation.isTyping &&
                      conversation.typingUserId == otherUserId)
                    _buildTypingIndicator(),

                  // Image preview
                  if (_selectedImage != null) _buildImagePreview(),

                  // Message input
                  _buildMessageInput(currentUser.id, otherUserId),
                ],
              ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(AsyncValue<dynamic> otherUserAsync) {
    return AppBar(
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: otherUserAsync.when(
        loading: () => const Text(
          'Loading...',
          style: AppTextStyles.appBarTitle,
        ),
        error: (error, stack) => const Text(
          'Error',
          style: AppTextStyles.appBarTitle,
        ),
        data: (otherUser) {
          if (otherUser == null) {
            return const Text(
              'Unknown',
              style: AppTextStyles.appBarTitle,
            );
          }

          return Row(
            children: [
              UserAvatar(
                imageUrl: otherUser.photoUrl,
                name: otherUser.name,
                radius: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  otherUser.name,
                  style: AppTextStyles.appBarTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () => _showOptionsMenu(context),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'typing',
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(
              _selectedImage!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Image selected',
              style: AppTextStyles.bodyMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _selectedImage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(String currentUserId, String otherUserId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Image picker button
            IconButton(
              icon: Icon(Icons.image, color: AppColors.primary),
              onPressed: _pickImage,
            ),

            // Text field
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  final isTypingNow = value.trim().isNotEmpty;
                  if (isTypingNow != _isTyping) {
                    setState(() {
                      _isTyping = isTypingNow;
                    });
                    _updateTypingIndicator(currentUserId, isTypingNow);
                  }
                },
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 20,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                onPressed: () => _sendMessage(currentUserId, otherUserId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _sendMessage(String currentUserId, String otherUserId) async {
    final content = _messageController.text.trim();

    if (content.isEmpty && _selectedImage == null) return;

    // Clear input immediately for better UX
    _messageController.clear();
    final imageToSend = _selectedImage;
    setState(() {
      _selectedImage = null;
      _isTyping = false;
    });

    // Clear typing indicator
    _updateTypingIndicator(currentUserId, false);

    try {
      await ref.read(dmViewModelProvider.notifier).sendMessage(
            conversationId: widget.conversationId,
            senderId: currentUserId,
            otherUserId: otherUserId,
            content: content,
            attachmentFile: imageToSend,
            attachmentType: imageToSend != null ? 'image' : null,
          );

      // Scroll to bottom after sending
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  void _updateTypingIndicator(String currentUserId, bool isTyping) {
    ref.read(dmViewModelProvider.notifier).setTypingIndicator(
          widget.conversationId,
          currentUserId,
          isTyping,
        );
  }

  void _markMessagesAsRead(
    List<DirectMessage> messages,
    String currentUserId,
    String otherUserId,
  ) {
    final unreadMessages = messages
        .where((msg) => msg.senderId == otherUserId && !msg.isRead)
        .map((msg) => msg.id)
        .toList();

    if (unreadMessages.isNotEmpty) {
      ref.read(dmViewModelProvider.notifier).markMessagesAsRead(
            widget.conversationId,
            currentUserId,
            unreadMessages,
          );
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.push_pin),
                title: const Text(
                  'Pin Conversation'
                ),
                onTap: () {
                  Navigator.pop(context);
                  // _confirmDeleteConversation();
                },
              ),
              Divider(),
              ListTile(
                leading: const Icon(Icons.notifications_off),
                title: const Text(
                  'Mute Conversation'
                ),
                onTap: () {
                  Navigator.pop(context);
                  // _confirmDeleteConversation();
                },
              ),
              Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Conversation',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteConversation();
                },
              ),
              SizedBox(height: 16)
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteConversation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Conversation'),
          content: const Text(
            'Are you sure you want to delete this conversation? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final conversationId = widget.conversationId;
                Navigator.of(context).pop(); // Close dialog

                // Navigate away first to avoid widget tree issues
                context.go('/direct-messages');

                // Then delete the conversation in the background
                ref.read(dmViewModelProvider.notifier).deleteConversation(
                  conversationId,
                ).then((_) {
                  // Show success message after navigation
                  // Note: We can't use context here as we've navigated away
                }).catchError((e) {
                  // Silently fail or log error
                  debugPrint('Error deleting conversation: $e');
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
