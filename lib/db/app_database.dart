import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqf;
import 'package:path/path.dart' as p;
import '../models/mood_entry.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  // Mobile (sqflite)
  sqf.Database? _db;

  Future<sqf.Database> _openMobileDb() async {
    if (_db != null) return _db!;
    final dbPath = await sqf.getDatabasesPath();
    final path = p.join(dbPath, 'daily_mood_journal.db');
    _db = await sqf.openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
        CREATE TABLE mood_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date INTEGER NOT NULL,
          mood INTEGER NOT NULL,
          note TEXT NOT NULL
        )
      ''');
        await db.execute('CREATE INDEX idx_mood_date ON mood_entries(date)');
        await db.execute('CREATE INDEX idx_mood_val  ON mood_entries(mood)');
      },
    );
    return _db!;
  }

  // ====== Web (SharedPreferences JSON) ======
  static const _spKey = 'mood_entries_json';

  Future<List<Map<String, dynamic>>> _readAllWeb() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_spKey);
    if (raw == null || raw.isEmpty) return [];
    final List list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> _writeAllWeb(List<Map<String, dynamic>> list) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_spKey, jsonEncode(list));
  }

  int _nextIdWeb(List<Map<String, dynamic>> list) {
    int mx = 0;
    for (final m in list) {
      final v = (m['id'] as int?) ?? 0;
      if (v > mx) mx = v;
    }
    return mx + 1;
  }

  // ====== CRUD (platform-conditional) ======
  Future<int> insertEntry(MoodEntry entry) async {
    if (kIsWeb) {
      final list = await _readAllWeb();
      final id = _nextIdWeb(list);
      final map = entry.copyWith(id: id).toMap();
      list.add(map);
      await _writeAllWeb(list);
      return id;
    } else {
      final db = await _openMobileDb();
      return db.insert(
        'mood_entries',
        entry.toMap(),
        conflictAlgorithm: sqf.ConflictAlgorithm.replace,
      );
    }
  }

  Future<int> updateEntry(MoodEntry entry) async {
    if (kIsWeb) {
      final list = await _readAllWeb();
      final i = list.indexWhere((m) => m['id'] == entry.id);
      if (i >= 0) {
        list[i] = entry.toMap();
        await _writeAllWeb(list);
        return 1;
      }
      return 0;
    } else {
      final db = await _openMobileDb();
      return db.update(
        'mood_entries',
        entry.toMap(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
    }
  }

  Future<int> deleteEntry(int id) async {
    if (kIsWeb) {
      final list = await _readAllWeb();
      final before = list.length;
      list.removeWhere((m) => m['id'] == id);
      await _writeAllWeb(list);
      return before - list.length;
    } else {
      final db = await _openMobileDb();
      return db.delete('mood_entries', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<List<MoodEntry>> getEntries({
    String? keyword,
    int? mood,
    DateTime? start,
    DateTime? end,
  }) async {
    if (kIsWeb) {
      final list = await _readAllWeb();
      Iterable<Map<String, dynamic>> it = list;

      if (keyword != null && keyword.trim().isNotEmpty) {
        final kw = keyword.trim().toLowerCase();
        it = it.where(
          (m) => (m['note'] as String? ?? '').toLowerCase().contains(kw),
        );
      }
      if (mood != null) {
        it = it.where((m) => m['mood'] == mood);
      }
      if (start != null) {
        final st = DateTime(
          start.year,
          start.month,
          start.day,
        ).toUtc().millisecondsSinceEpoch;
        it = it.where((m) => (m['date'] as int) >= st);
      }
      if (end != null) {
        final en = DateTime(
          end.year,
          end.month,
          end.day,
          23,
          59,
          59,
        ).toUtc().millisecondsSinceEpoch;
        it = it.where((m) => (m['date'] as int) <= en);
      }

      final entries = it.map((e) => MoodEntry.fromMap(e)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return entries;
    } else {
      final db = await _openMobileDb();
      final where = <String>[];
      final args = <dynamic>[];

      if (keyword != null && keyword.trim().isNotEmpty) {
        where.add('note LIKE ?');
        args.add('%${keyword.trim()}%');
      }
      if (mood != null) {
        where.add('mood = ?');
        args.add(mood);
      }
      if (start != null) {
        where.add('date >= ?');
        args.add(
          DateTime(
            start.year,
            start.month,
            start.day,
          ).toUtc().millisecondsSinceEpoch,
        );
      }
      if (end != null) {
        where.add('date <= ?');
        args.add(
          DateTime(
            end.year,
            end.month,
            end.day,
            23,
            59,
            59,
          ).toUtc().millisecondsSinceEpoch,
        );
      }

      final rows = await db.query(
        'mood_entries',
        where: where.isEmpty ? null : where.join(' AND '),
        whereArgs: args.isEmpty ? null : args,
        orderBy: 'date DESC, id DESC',
      );
      return rows.map((e) => MoodEntry.fromMap(e)).toList();
    }
  }

  Future<MoodEntry?> getEntryByDate(DateTime date) async {
    final dayStart = DateTime(
      date.year,
      date.month,
      date.day,
    ).toUtc().millisecondsSinceEpoch;
    final dayEnd = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    ).toUtc().millisecondsSinceEpoch;

    if (kIsWeb) {
      final list = await _readAllWeb();
      final row = list.firstWhere(
        (m) => (m['date'] as int) >= dayStart && (m['date'] as int) <= dayEnd,
        orElse: () => {},
      );
      if (row.isEmpty) return null;
      return MoodEntry.fromMap(row);
    } else {
      final db = await _openMobileDb();
      final rows = await db.query(
        'mood_entries',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [dayStart, dayEnd],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return MoodEntry.fromMap(rows.first);
    }
  }

  Future<Map<int, int>> countByMood(DateTime start, DateTime end) async {
    final st = DateTime(
      start.year,
      start.month,
      start.day,
    ).toUtc().millisecondsSinceEpoch;
    final en = DateTime(
      end.year,
      end.month,
      end.day,
      23,
      59,
      59,
    ).toUtc().millisecondsSinceEpoch;

    if (kIsWeb) {
      final list = await _readAllWeb();
      final map = <int, int>{};
      for (final m in list) {
        final d = m['date'] as int;
        if (d >= st && d <= en) {
          final mood = m['mood'] as int;
          map[mood] = (map[mood] ?? 0) + 1;
        }
      }
      return map;
    } else {
      final db = await _openMobileDb();
      final rows = await db.rawQuery(
        '''
        SELECT mood, COUNT(*) as cnt
        FROM mood_entries
        WHERE date BETWEEN ? AND ?
        GROUP BY mood
        ORDER BY mood ASC
      ''',
        [st, en],
      );
      final map = <int, int>{};
      for (final r in rows) {
        map[(r['mood'] as int)] = (r['cnt'] as int);
      }
      return map;
    }
  }
}
