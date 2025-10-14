import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/message.dart';
import '../../services/auth_service.dart';
import '../../services/message_service.dart';
import '../../services/user_cache_sync_service.dart';

/// Screen for creating a new message in a group
class CreateMessageScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String? groupName;

  const CreateMessageScreen({
    super.key,
    required this.groupId,
    this.groupName,
  });

  @override
  ConsumerState<CreateMessageScreen> createState() => _CreateMessageScreenState();
}

class _CreateMessageScreenState extends ConsumerState<CreateMessageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();
  final GlobalKey<FlutterMentionsState> _mentionsKey = GlobalKey<FlutterMentionsState>();

  File? _selectedImage;
  bool _isSubmitting = false;
  List<String> _mentionedUserIds = [];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<String> _uploadMessageImage(File file, String userId, String messageId) async {
    final fileBytes = await file.readAsBytes();
    final path = 'messages/$userId/$messageId.jpg';
    final storageRef = FirebaseStorage.instance.ref().child(path);

    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final uploadTask = storageRef.putData(fileBytes, metadata);

    final snapshot = await uploadTask;
    final url = await snapshot.ref.getDownloadURL();

    return url;
  }

  Future<void> _submitMessage() async {
    // Get content from FlutterMentions (use text for display, markupText has IDs)
    final content = _mentionsKey.currentState?.controller?.text ?? '';

    // Validate content
    if (content.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message or add an image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to post'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final messageService = ref.read(messageServiceProvider);

      // Generate message ID first so we can use it for image upload path
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload image to Firebase Storage if selected
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadMessageImage(
          _selectedImage!,
          currentUser.uid,
          messageId,
        );
      }

      final message = Message(
        id: messageId,
        groupId: widget.groupId,
        userId: currentUser.uid,
        content: content.trim(),
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
        likes: [],
        commentCount: 0,
      );

      await messageService.postMessage(message);

      if (mounted) {
        // Return the newly created message to refresh the list
        context.pop(message);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post message: $e'),
            backgroundColor: Colors.red,
          ),
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

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                context.pop();
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                context.pop();
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(
          'New Message',
          style: AppTextStyles.appBarTitle,
        ),
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submitMessage,
              child: Text(
                'Post',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.groupName != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.group,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Posting to ${widget.groupName}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    FlutterMentions(
                      key: _mentionsKey,
                      suggestionPosition: SuggestionPosition.Top,
                      maxLines: 10,
                      minLines: 5,
                      autofocus: true,
                      enabled: !_isSubmitting,
                      decoration: InputDecoration(
                        hintText: 'What\'s on your mind? Type @ to mention someone',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.greyLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.greyLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                      ),
                      style: AppTextStyles.bodyMedium,
                      mentions: [
                        Mention(
                          trigger: '@',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                          data: ref.watch(allCachedUsersProvider).when(
                            data: (users) => users.map((user) => {
                              'id': user.id,
                              'display': user.name,
                              'photo': user.photoUrl ?? '',
                            }).toList(),
                            loading: () => [],
                            error: (_, __) => [],
                          ),
                          matchAll: true,
                          suggestionBuilder: (data) {
                            return Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: data['photo'] != null && data['photo'].toString().isNotEmpty
                                      ? NetworkImage(data['photo'] as String)
                                      : null,
                                    child: data['photo'] == null || data['photo'].toString().isEmpty
                                      ? Text(
                                          (data['display'] as String)[0].toUpperCase(),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        )
                                      : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    data['display'] as String,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                      onMentionAdd: (mention) {
                        // Track mentioned user IDs
                        final userId = mention['id'] as String;
                        if (!_mentionedUserIds.contains(userId)) {
                          setState(() {
                            _mentionedUserIds.add(userId);
                          });
                        }
                      },
                      onChanged: (value) {
                        // Update form validation
                        _formKey.currentState?.validate();
                      },
                    ),
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: _removeImage,
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.greyLight),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isSubmitting ? null : _showImageSourceDialog,
                    icon: const Icon(Icons.image),
                    color: AppColors.primary,
                    tooltip: 'Add image',
                  ),
                  const Spacer(),
                  if (_mentionedUserIds.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.alternate_email, size: 16, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text(
                            '${_mentionedUserIds.length}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
