import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'screen_tracking_viewmodel.g.dart';

/// ViewModel for tracking the current screen path
/// Used to suppress notifications and manage screen-specific behavior
@riverpod
class CurrentScreen extends _$CurrentScreen {
  @override
  String? build() {
    return null;
  }

  /// Set the current screen path
  void setScreen(String? screenPath) {
    state = screenPath;
  }

  /// Check if user is currently viewing a DM conversation
  bool isViewingConversation(String conversationId) {
    return state == '/direct-messages/conversation/$conversationId';
  }

  /// Check if user is currently viewing a message detail
  bool isViewingMessage(String messageId) {
    return state != null && state!.contains('/messages/detail/$messageId');
  }
}
