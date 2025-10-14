import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import '../models/message.dart';

/// Service for caching messages locally with FTS5 full-text search
/// Enables offline search and reduces Firestore query costs
class MessageCacheService {
  static Database? _database;
  static const String _messagesTable = 'messages';
  static const String _ftsTable = 'messages_fts';

  /// Get or initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize SQLite database with FTS5
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final dbFilePath = path.join(dbPath, 'community_messages.db');

    return await openDatabase(
      dbFilePath,
      version: 1,
      onCreate: (db, version) async {
        // Main messages table
        await db.execute('''
          CREATE TABLE $_messagesTable (
            id TEXT PRIMARY KEY,
            groupId TEXT NOT NULL,
            userId TEXT NOT NULL,
            content TEXT NOT NULL,
            imageUrl TEXT,
            timestamp INTEGER NOT NULL,
            likes TEXT,
            commentCount INTEGER DEFAULT 0
          )
        ''');

        // FTS5 virtual table for full-text search
        await db.execute('''
          CREATE VIRTUAL TABLE $_ftsTable USING fts5(
            id UNINDEXED,
            content,
            groupId UNINDEXED,
            userId UNINDEXED,
            timestamp UNINDEXED,
            tokenize='unicode61 remove_diacritics 2'
          )
        ''');

        // Indexes for efficient filtering
        await db.execute('''
          CREATE INDEX idx_messages_groupId
          ON $_messagesTable(groupId)
        ''');

        await db.execute('''
          CREATE INDEX idx_messages_timestamp
          ON $_messagesTable(timestamp DESC)
        ''');

        debugPrint('Message cache database initialized with FTS5');
      },
    );
  }

  /// Cache a single message
  Future<void> cacheMessage(Message message) async {
    final db = await database;

    await db.transaction((txn) async {
      // Insert/update in main table
      await txn.insert(
        _messagesTable,
        {
          'id': message.id,
          'groupId': message.groupId,
          'userId': message.userId,
          'content': message.content,
          'imageUrl': message.imageUrl,
          'timestamp': message.timestamp.millisecondsSinceEpoch,
          'likes': message.likes.join(','),
          'commentCount': message.commentCount,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert/update in FTS table
      await txn.delete(_ftsTable, where: 'id = ?', whereArgs: [message.id]);
      await txn.insert(_ftsTable, {
        'id': message.id,
        'content': message.content,
        'groupId': message.groupId,
        'userId': message.userId,
        'timestamp': message.timestamp.millisecondsSinceEpoch,
      });
    });
  }

  /// Cache multiple messages (bulk insert)
  Future<void> cacheMessages(List<Message> messages) async {
    final db = await database;

    await db.transaction((txn) async {
      for (final message in messages) {
        // Insert/update in main table
        await txn.insert(
          _messagesTable,
          {
            'id': message.id,
            'groupId': message.groupId,
            'userId': message.userId,
            'content': message.content,
            'imageUrl': message.imageUrl,
            'timestamp': message.timestamp.millisecondsSinceEpoch,
            'likes': message.likes.join(','),
            'commentCount': message.commentCount,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Insert/update in FTS table
        await txn.delete(_ftsTable, where: 'id = ?', whereArgs: [message.id]);
        await txn.insert(_ftsTable, {
          'id': message.id,
          'content': message.content,
          'groupId': message.groupId,
          'userId': message.userId,
          'timestamp': message.timestamp.millisecondsSinceEpoch,
        });
      }
    });

    debugPrint('Cached ${messages.length} messages');
  }

  /// Search messages with FTS5 (full-text search)
  Future<List<Message>> searchMessages({
    required String query,
    String? groupId,
    int limit = 50,
  }) async {
    if (query.trim().isEmpty) return [];

    final db = await database;

    // Build FTS5 query
    final ftsQuery = query.trim().split(' ').map((term) => '$term*').join(' ');

    // Search in FTS table
    final List<Map<String, dynamic>> results;

    if (groupId != null && groupId != 'all') {
      // Search within specific group
      results = await db.rawQuery('''
        SELECT m.* FROM $_messagesTable m
        INNER JOIN $_ftsTable fts ON m.id = fts.id
        WHERE fts MATCH ? AND m.groupId = ?
        ORDER BY m.timestamp DESC
        LIMIT ?
      ''', [ftsQuery, groupId, limit]);
    } else {
      // Search across all groups
      results = await db.rawQuery('''
        SELECT m.* FROM $_messagesTable m
        INNER JOIN $_ftsTable fts ON m.id = fts.id
        WHERE fts MATCH ?
        ORDER BY m.timestamp DESC
        LIMIT ?
      ''', [ftsQuery, limit]);
    }

    debugPrint('Found ${results.length} results for query: "$query"');

    return results.map((row) => _messageFromRow(row)).toList();
  }

  /// Get cached messages for a group (for initial display)
  Future<List<Message>> getCachedMessages({
    required String groupId,
    int limit = 500,
  }) async {
    final db = await database;

    final results = await db.query(
      _messagesTable,
      where: groupId != 'all' ? 'groupId = ?' : null,
      whereArgs: groupId != 'all' ? [groupId] : null,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return results.map((row) => _messageFromRow(row)).toList();
  }

  /// Get cache statistics
  Future<Map<String, int>> getCacheStats() async {
    final db = await database;

    final totalCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_messagesTable'),
    );

    final groupCounts = await db.rawQuery('''
      SELECT groupId, COUNT(*) as count
      FROM $_messagesTable
      GROUP BY groupId
    ''');

    return {
      'total': totalCount ?? 0,
      for (var row in groupCounts) row['groupId'] as String: row['count'] as int,
    };
  }

  /// Clear cache for a specific group
  Future<void> clearGroupCache(String groupId) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete(
        _messagesTable,
        where: 'groupId = ?',
        whereArgs: [groupId],
      );
      await txn.delete(
        _ftsTable,
        where: 'groupId = ?',
        whereArgs: [groupId],
      );
    });

    debugPrint('Cleared cache for group: $groupId');
  }

  /// Clear entire cache
  Future<void> clearAllCache() async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete(_messagesTable);
      await txn.delete(_ftsTable);
    });

    debugPrint('Cleared entire message cache');
  }

  /// Convert database row to Message object
  Message _messageFromRow(Map<String, dynamic> row) {
    return Message(
      id: row['id'] as String,
      groupId: row['groupId'] as String,
      userId: row['userId'] as String,
      content: row['content'] as String,
      imageUrl: row['imageUrl'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
      likes: (row['likes'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
      commentCount: row['commentCount'] as int? ?? 0,
    );
  }

  /// Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
