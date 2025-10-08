/// App-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App Info
  static const String appName = 'Community';
  static const String appVersion = '0.1.0';

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 24.0;
  static const double spacingXXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;

  // Avatar Sizes
  static const double avatarSizeS = 32.0;
  static const double avatarSizeM = 48.0;
  static const double avatarSizeL = 72.0;
  static const double avatarSizeXL = 120.0;

  // Icon Sizes
  static const double iconSizeS = 20.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;

  // Touch Target Sizes
  static const double minTouchTarget = 48.0;

  // Animation Durations
  static const Duration animationQuick = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String messagesCollection = 'messages';
  static const String groupsCollection = 'groups';
  static const String commentsCollection = 'comments';
  static const String conversationsCollection = 'conversations';
  static const String dmMessagesCollection = 'dm_messages';

  // Pagination
  static const int messagesPerPage = 50;
  static const int commentsPerPage = 20;

  // Images
  static const String placeholderAvatar = 'assets/images/avatar_placeholder.png';
  static const String placeholderImage = 'assets/images/image_placeholder.png';

  // Routes (will be defined with go_router)
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeMessageFeed = '/messages';
  static const String routeMessageDetail = '/messages/:id';
  static const String routeProfile = '/profile/:id';
  static const String routeGroups = '/groups';
  static const String routeGroupDetail = '/groups/:id';
}
