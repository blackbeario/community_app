import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'message_service.dart';
import 'message_cache_service.dart';
import 'group_service.dart';

part 'cache_sync_service.g.dart';

/// Service for managing background cache synchronization
/// Implements smart prefetching strategy for offline search
class CacheSyncService {
  final MessageService _messageService;
  final MessageCacheService _cacheService;
  final GroupService _groupService;

  bool _hasPrefetched = false;
  DateTime? _lastPrefetchTime;

  CacheSyncService(this._messageService, this._cacheService, this._groupService);

  /// Prefetch and cache recent messages for all groups in the background
  /// This enables offline search across all groups without user navigation
  /// Only runs once per app session unless forced
  Future<void> prefetchAllGroups({int messagesPerGroup = 50, bool force = false}) async {
    // Skip if already prefetched (unless forced)
    if (_hasPrefetched && !force) {
      debugPrint('Cache already prefetched. Skipping.');
      return;
    }

    try {
      debugPrint('Starting background cache prefetch...');
      _hasPrefetched = true;
      _lastPrefetchTime = DateTime.now();

      // Get all groups
      final groupsSnapshot = await _groupService.getAllGroups().first;
      final groups = groupsSnapshot.where((g) => g.id != 'all').toList();

      debugPrint('Prefetching $messagesPerGroup messages from ${groups.length} groups...');

      int totalCached = 0;

      // Fetch and cache messages for each group
      for (final group in groups) {
        try {
          final messages = await _messageService.getMessagesPaginated(groupId: group.id, limit: messagesPerGroup);

          if (messages.isNotEmpty) {
            await _cacheService.cacheMessages(messages);
            totalCached += messages.length;
            debugPrint('Cached ${messages.length} messages from ${group.name}');
          }
        } catch (e) {
          // Don't let one group failure stop the whole sync
          debugPrint('Failed to cache messages for ${group.name}: $e');
        }
      }

      debugPrint('Background prefetch complete! Cached $totalCached total messages.');
    } catch (e, stackTrace) {
      debugPrint('Background cache prefetch error: $e\n$stackTrace');
    }
  }

  /// Clear entire cache
  Future<void> clearCache() async {
    await _cacheService.clearAllCache();
    _hasPrefetched = false;
    _lastPrefetchTime = null;
    debugPrint('Cache cleared');
  }

  /// Get cache statistics
  Future<Map<String, int>> getCacheStats() async {
    return await _cacheService.getCacheStats();
  }

  /// Check if cache has been prefetched
  bool get hasPrefetched => _hasPrefetched;

  /// Get last prefetch time
  DateTime? get lastPrefetchTime => _lastPrefetchTime;
}

@Riverpod(keepAlive: true)
CacheSyncService cacheSyncService(Ref ref) {
  return CacheSyncService(
    ref.watch(messageServiceProvider),
    ref.watch(messageCacheServiceProvider),
    ref.watch(groupServiceProvider),
  );
}
