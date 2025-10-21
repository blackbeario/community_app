import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/user_cache_sync_service.dart';

/// Comment input section with mentions support and image attachment
class CommentInputSection extends ConsumerWidget {
  final GlobalKey<FlutterMentionsState> mentionsKey;
  final File? selectedImage;
  final bool isSubmitting;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onSubmit;
  final void Function(Map<String, dynamic> mention) onMentionAdd;

  const CommentInputSection({
    super.key,
    required this.mentionsKey,
    required this.selectedImage,
    required this.isSubmitting,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onSubmit,
    required this.onMentionAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
          if (selectedImage != null)
            Container(
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      selectedImage!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onRemoveImage,
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
                    onPressed: isSubmitting ? null : onPickImage,
                  ),
                  const SizedBox(width: 8),

                  // Text input with mentions
                  Expanded(
                    child: FlutterMentions(
                      key: mentionsKey,
                      suggestionPosition: SuggestionPosition.Top,
                      maxLines: 5,
                      minLines: 1,
                      enabled: !isSubmitting,
                      decoration: InputDecoration(
                        hintText: 'Add a comment... Type @ to mention',
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
                                    radius: 16,
                                    backgroundImage: data['photo'] != null && data['photo'].toString().isNotEmpty
                                      ? NetworkImage(data['photo'] as String)
                                      : null,
                                    child: data['photo'] == null || data['photo'].toString().isEmpty
                                      ? Text(
                                          (data['display'] as String)[0].toUpperCase(),
                                          style: const TextStyle(fontSize: 14),
                                        )
                                      : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    data['display'] as String,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                      onMentionAdd: onMentionAdd,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send button
                  isSubmitting
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
                          onPressed: onSubmit,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
