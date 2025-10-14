import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import 'local_user_cache_service.dart';
import 'user_service.dart';

part 'user_cache_sync_service.g.dart';

/// Provider for the local user cache service
@riverpod
LocalUserCacheService localUserCacheService(Ref ref) {
  return LocalUserCacheService();
}

/// Provider for syncing users from Firestore to local cache
@riverpod
class UserCacheSync extends _$UserCacheSync {
  @override
  Future<void> build() async {
    developer.log('UserCacheSync build() called - checking cache status', name: 'UserCacheSync');

    // Check if cache needs refresh on startup
    final cacheService = ref.read(localUserCacheServiceProvider);
    final needsRefresh = await cacheService.needsRefresh();

    if (needsRefresh) {
      developer.log('User cache needs refresh, syncing from Firestore...', name: 'UserCacheSync');
      await syncUsers();
    } else {
      final count = await cacheService.getCachedUserCount();
      developer.log('User cache is up to date ($count users cached)', name: 'UserCacheSync');
    }
  }

  /// Sync all users from Firestore to local SQLite cache
  Future<void> syncUsers() async {
    try {
      developer.log('Starting user cache sync from Firestore', name: 'UserCacheSync');

      final userService = ref.read(userServiceProvider);
      final cacheService = ref.read(localUserCacheServiceProvider);

      // Fetch all users from Firestore
      final users = await userService.getAllUsers();
      developer.log('Fetched ${users.length} users from Firestore', name: 'UserCacheSync');

      // Cache them locally
      await cacheService.cacheUsers(users);
      developer.log('Successfully cached ${users.length} users to SQLite', name: 'UserCacheSync');

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      developer.log('Failed to sync user cache: $e', name: 'UserCacheSync', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }

  /// Get the count of cached users
  Future<int> getCachedUserCount() async {
    final cacheService = ref.read(localUserCacheServiceProvider);
    return await cacheService.getCachedUserCount();
  }

  /// Force refresh the cache
  Future<void> forceRefresh() async {
    await syncUsers();
  }
}

/// Provider for searching cached users (offline-capable)
@riverpod
class CachedUserSearch extends _$CachedUserSearch {
  @override
  Future<List<User>> build(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final cacheService = ref.read(localUserCacheServiceProvider);
    return await cacheService.searchUsers(query, limit: 10);
  }

  /// Refresh search results
  Future<void> refresh(String newQuery) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final cacheService = ref.read(localUserCacheServiceProvider);
      return await cacheService.searchUsers(newQuery, limit: 10);
    });
  }
}

/// Provider to get all cached users (for mentions)
@riverpod
Future<List<User>> allCachedUsers(Ref ref) async {
  final cacheService = ref.read(localUserCacheServiceProvider);
  final users = await cacheService.getAllUsers();
  developer.log('allCachedUsers provider returning ${users.length} users', name: 'UserCacheSync');
  return users;
}
