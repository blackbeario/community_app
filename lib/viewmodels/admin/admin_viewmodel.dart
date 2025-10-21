import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/config/firebase_providers.dart';
import '../../models/group.dart';
import '../../services/group_service.dart';

part 'admin_viewmodel.g.dart';

@riverpod
class AdminViewModel extends _$AdminViewModel {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Generate an emoji icon for a group based on name and description
  Future<String> generateGroupEmoji({
    required String name,
    required String description,
  }) async {
    final functions = ref.read(firebaseFunctionsProvider);
    final callable = functions.httpsCallable('generateGroupEmoji');
    final result = await callable.call({
      'name': name,
      'description': description,
    });

    return result.data['emoji'] as String;
  }

  /// Create a new group
  Future<void> createGroup({
    required String name,
    required String description,
    required bool isPublic,
    String? icon,
  }) async {
    final groupService = ref.read(groupServiceProvider);

    // Generate a simple ID from the name
    final groupId = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    final group = Group(
      id: groupId,
      name: name.trim(),
      description: description.trim(),
      icon: icon,
      isPublic: isPublic,
      createdAt: DateTime.now(),
    );

    await groupService.createGroup(group);
  }

  /// Delete a group by ID
  Future<void> deleteGroup(String groupId) async {
    final groupService = ref.read(groupServiceProvider);
    await groupService.deleteGroup(groupId);
  }
}
