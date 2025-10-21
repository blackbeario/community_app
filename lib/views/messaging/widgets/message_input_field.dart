import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/user_cache_sync_service.dart';

/// Reusable message input field with mentions support
class MessageInputField extends ConsumerWidget {
  final GlobalKey<FlutterMentionsState> mentionsKey;
  final bool enabled;
  final String hintText;
  final void Function(Map<String, dynamic> mention) onMentionAdd;
  final void Function(String value)? onChanged;

  const MessageInputField({
    super.key,
    required this.mentionsKey,
    required this.enabled,
    required this.hintText,
    required this.onMentionAdd,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FlutterMentions(
      key: mentionsKey,
      suggestionPosition: SuggestionPosition.Bottom,
      maxLines: 10,
      minLines: 5,
      autofocus: true,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
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
      onMentionAdd: onMentionAdd,
      onChanged: onChanged,
    );
  }
}
