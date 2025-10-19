import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'multi_project_service.freezed.dart';
part 'multi_project_service.g.dart';

/// Model representing a community Firebase project
@freezed
class CommunityProject with _$CommunityProject {
  const factory CommunityProject({
    required String name,
    required String projectId,
    @Default('active') String status,
    DateTime? created,
  }) = _CommunityProject;

  factory CommunityProject.fromJson(Map<String, dynamic> json) =>
      _$CommunityProjectFromJson(json);
}

/// Provider for the currently selected project
final selectedProjectProvider = StateProvider<CommunityProject?>((ref) => null);

/// Provider for available projects
/// In a real implementation, this would load from a config file or API
final availableProjectsProvider = Provider<List<CommunityProject>>((ref) {
  // TODO: Load from scripts/configs/projects.json or a backend API
  // For now, return example projects
  return [
    CommunityProject(
      name: 'Champion Hills',
      projectId: 'community-champion-hills',
      created: DateTime(2025, 1, 15),
    ),
    CommunityProject(
      name: 'Lake Lure',
      projectId: 'community-lake-lure',
      created: DateTime(2025, 1, 18),
    ),
  ];
});

/// Service for managing multiple Firebase projects
class MultiProjectService {
  /// Load available projects from configuration
  Future<List<CommunityProject>> loadProjects() async {
    // TODO: Implement loading from scripts/configs/projects.json
    // This would typically be done via an HTTP request to a server
    // that reads the projects.json file, or by bundling it as an asset
    throw UnimplementedError('Load projects from config');
  }

  /// Switch to a different Firebase project
  /// This would require re-initializing Firebase with different credentials
  Future<void> switchProject(CommunityProject project) async {
    // TODO: Implement Firebase re-initialization
    // This is complex and may require using named Firebase instances
    throw UnimplementedError('Switch Firebase project');
  }
}

final multiProjectServiceProvider = Provider((ref) => MultiProjectService());
