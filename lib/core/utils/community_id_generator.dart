class CommunityIdGenerator {
  static Map<String, String> generateIds(String communityName) {
    if (communityName.trim().isEmpty) {
      return {
        'projectId': '',
        'iosBundleId': '',
        'androidPackage': '',
      };
    }

    // Convert to lowercase, replace spaces with hyphens, remove special chars
    final slug = communityName
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '');

    return {
      'projectId': 'community-$slug',
      'iosBundleId': 'io.vibesoftware.community.${slug.replaceAll('-', '')}',
      'androidPackage': 'io.vibesoftware.community.${slug.replaceAll('-', '')}',
    };
  }
}
