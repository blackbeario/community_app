import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

/// Service for caching users locally in SQLite for offline @ mention functionality
class LocalUserCacheService {
  static const String _tableName = 'cached_users';
  static const String _dbName = 'community_cache.db';
  static const int _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        photoUrl TEXT,
        bio TEXT,
        phoneNumber TEXT,
        unitNumber TEXT,
        coverPhotoUrl TEXT,
        createdAt INTEGER NOT NULL,
        groups TEXT,
        isAdmin INTEGER NOT NULL DEFAULT 0,
        lastSynced INTEGER NOT NULL
      )
    ''');

    // Create index for fast name searching
    await db.execute('''
      CREATE INDEX idx_name ON $_tableName (name COLLATE NOCASE)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations
  }

  /// Cache a batch of users from Firestore
  Future<void> cacheUsers(List<User> users) async {
    final db = await database;
    final batch = db.batch();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    for (final user in users) {
      batch.insert(
        _tableName,
        {
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'photoUrl': user.photoUrl,
          'bio': user.bio,
          'phoneNumber': user.phoneNumber,
          'unitNumber': user.unitNumber,
          'coverPhotoUrl': user.coverPhotoUrl,
          'createdAt': user.createdAt.millisecondsSinceEpoch,
          'groups': user.groups.join(','),
          'isAdmin': user.isAdmin ? 1 : 0,
          'lastSynced': timestamp,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Cache a single user
  Future<void> cacheUser(User user) async {
    final db = await database;
    await db.insert(
      _tableName,
      {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'bio': user.bio,
        'phoneNumber': user.phoneNumber,
        'unitNumber': user.unitNumber,
        'coverPhotoUrl': user.coverPhotoUrl,
        'createdAt': user.createdAt.millisecondsSinceEpoch,
        'groups': user.groups.join(','),
        'isAdmin': user.isAdmin ? 1 : 0,
        'lastSynced': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Search users by name (offline-capable)
  Future<List<User>> searchUsers(String query, {int limit = 10}) async {
    final db = await database;

    // Search by name prefix or contains
    final results = await db.query(
      _tableName,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
      limit: limit,
    );

    return results.map((row) => _userFromMap(row)).toList();
  }

  /// Get all cached users
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final results = await db.query(
      _tableName,
      orderBy: 'name ASC',
    );

    return results.map((row) => _userFromMap(row)).toList();
  }

  /// Get a specific user by ID
  Future<User?> getUser(String userId) async {
    final db = await database;
    final results = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return _userFromMap(results.first);
  }

  /// Get count of cached users
  Future<int> getCachedUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Clear all cached users
  Future<void> clearCache() async {
    final db = await database;
    await db.delete(_tableName);
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    final db = await database;
    final result = await db.query(
      _tableName,
      columns: ['MAX(lastSynced) as lastSynced'],
      limit: 1,
    );

    if (result.isEmpty || result.first['lastSynced'] == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(result.first['lastSynced'] as int);
  }

  /// Check if cache needs refresh (e.g., older than 1 hour for development)
  /// TODO: Change back to 24 hours for production
  Future<bool> needsRefresh({Duration maxAge = const Duration(hours: 1)}) async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;

    return DateTime.now().difference(lastSync) > maxAge;
  }

  User _userFromMap(Map<String, dynamic> map) {
    final groupsString = map['groups'] as String?;
    final groups = groupsString?.isNotEmpty == true
        ? groupsString!.split(',')
        : <String>[];

    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      unitNumber: map['unitNumber'] as String?,
      coverPhotoUrl: map['coverPhotoUrl'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      groups: groups,
      isAdmin: (map['isAdmin'] as int) == 1,
    );
  }

  /// Close the database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
