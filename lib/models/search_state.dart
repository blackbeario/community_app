import 'package:freezed_annotation/freezed_annotation.dart';
import 'message.dart';

part 'search_state.freezed.dart';

/// State model for message search with group-scoped filtering
@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    /// Current search query
    @Default('') String query,

    /// Selected group ID for filtering ('all' means search all groups)
    @Default('all') String selectedGroupId,

    /// Search results
    @Default([]) List<Message> results,

    /// Loading state for initial search
    @Default(false) bool isLoading,

    /// Loading state for cloud search fallback
    @Default(false) bool isSearchingCloud,

    /// Offline mode indicator
    @Default(false) bool isOffline,

    /// Error message if search fails
    String? error,
  }) = _SearchState;

  factory SearchState.initial() => const SearchState();
}
