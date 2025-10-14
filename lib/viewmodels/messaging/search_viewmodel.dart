import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../models/search_state.dart';
import '../../models/message.dart';
import '../../services/message_cache_service.dart';
import '../../services/message_service.dart';

part 'search_viewmodel.g.dart';

/// ViewModel for managing message search with group-scoped filtering
/// Implements debouncing and hybrid cache/cloud search strategy
@riverpod
class SearchViewModel extends _$SearchViewModel {
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 300);

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return SearchState.initial();
  }

  /// Set the group filter (defaults to current tab's group)
  void setGroupFilter(String groupId) {
    state = state.copyWith(selectedGroupId: groupId);
    if (state.query.isNotEmpty) {
      search(state.query);
    }
  }

  /// Debounced search with group scoping
  void search(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      state = SearchState.initial().copyWith(selectedGroupId: state.selectedGroupId);
      return;
    }

    state = state.copyWith(query: query, isLoading: true);

    _debounceTimer = Timer(_debounceDuration, () async {
      await _performSearch(query);
    });
  }

  /// Perform the actual search operation
  Future<void> _performSearch(String query) async {
    try {
      // Check online status
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOffline = connectivityResult.contains(ConnectivityResult.none);

      state = state.copyWith(isOffline: isOffline);

      // 1. Search local cache first (scoped to selected group)
      final cacheService = ref.read(messageCacheServiceProvider);
      final cacheResults = await cacheService.searchMessages(
        query: query,
        groupId: state.selectedGroupId,
        limit: 50,
      );

      // If we have cache results, show them immediately
      if (cacheResults.isNotEmpty) {
        state = state.copyWith(
          results: cacheResults,
          isLoading: false,
        );
      }

      // 2. If online, always query cloud (especially if cache is empty or "all" groups selected)
      // For "all" groups, we skip cloud search since Firestore doesn't support it efficiently
      if (!isOffline && state.selectedGroupId != 'all') {
        state = state.copyWith(isSearchingCloud: true);

        final messageService = ref.read(messageServiceProvider);
        final cloudResults = await messageService.searchMessages(
          state.selectedGroupId,
          query,
        );

        // Merge and deduplicate results
        final allResults = <String, Message>{};
        for (final msg in cacheResults) {
          allResults[msg.id] = msg;
        }
        for (final msg in cloudResults) {
          allResults[msg.id] = msg;
        }

        final mergedResults = allResults.values.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        state = state.copyWith(
          results: mergedResults,
          isLoading: false,
          isSearchingCloud: false,
        );
      } else {
        // Offline or "all" groups - use cache results only
        state = state.copyWith(
          results: cacheResults,
          isLoading: false,
        );
      }
    } catch (e, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        isSearchingCloud: false,
        error: e.toString(),
      );
      // Log error for debugging
      debugPrint('Search error: $e\n$stackTrace');
    }
  }

  /// Clear search and reset state
  void clearSearch() {
    _debounceTimer?.cancel();
    state = SearchState.initial();
  }

  /// Immediate search (without debouncing) - useful for filter changes
  Future<void> searchImmediate(String query) async {
    _debounceTimer?.cancel();
    if (query.isEmpty) {
      clearSearch();
      return;
    }
    state = state.copyWith(query: query, isLoading: true);
    await _performSearch(query);
  }
}
