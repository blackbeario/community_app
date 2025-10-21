import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/auth_service.dart';
import '../../services/image_picker_service.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/messaging/message_viewmodel.dart';
import 'widgets/image_source_dialog.dart';
import 'widgets/message_image_preview.dart';
import 'widgets/message_input_field.dart';
import 'widgets/group_badge.dart';
import 'widgets/mention_counter.dart';

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
  final GlobalKey<FlutterMentionsState> _mentionsKey = GlobalKey<FlutterMentionsState>();

  File? _selectedImage;
  bool _isSubmitting = false;
  final List<String> _mentionedUserIds = [];

  Future<void> _pickImage() async {
    try {
      final imagePickerService = ref.read(imagePickerServiceProvider);
      final file = await imagePickerService.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (file != null) {
        setState(() => _selectedImage = file);
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
      final imagePickerService = ref.read(imagePickerServiceProvider);
      final file = await imagePickerService.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (file != null) {
        setState(() => _selectedImage = file);
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
    setState(() => _selectedImage = null);
  }

  Future<void> _submitMessage() async {
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

    final currentAppUser = ref.read(currentAppUserProvider).valueOrNull;
    final content = _mentionsKey.currentState?.controller?.text ?? '';

    setState(() => _isSubmitting = true);

    try {
      final viewModel = ref.read(messageViewModelProvider.notifier);

      final message = await viewModel.createMessage(
        groupId: widget.groupId,
        userId: currentUser.uid,
        content: content,
        imageFile: _selectedImage,
        mentions: _mentionedUserIds,
        isAdmin: currentAppUser?.isAdmin ?? false,
      );

      if (mounted) {
        context.pop(message);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showImageSourceDialog() {
    ImageSourceDialog.show(
      context,
      onCamera: _takePhoto,
      onGallery: _pickImage,
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
                      GroupBadge(groupName: widget.groupName!),
                      const SizedBox(height: 16),
                    ],
                    MessageInputField(
                      mentionsKey: _mentionsKey,
                      enabled: !_isSubmitting,
                      hintText: 'What\'s on your mind? Type @ to mention someone',
                      onMentionAdd: (mention) {
                        final userId = mention['id'] as String;
                        if (!_mentionedUserIds.contains(userId)) {
                          setState(() => _mentionedUserIds.add(userId));
                        }
                      },
                      onChanged: (value) {
                        _formKey.currentState?.validate();
                      },
                    ),
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 16),
                      MessageImagePreview(
                        image: _selectedImage!,
                        onRemove: _removeImage,
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
                  MentionCounter(count: _mentionedUserIds.length),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
