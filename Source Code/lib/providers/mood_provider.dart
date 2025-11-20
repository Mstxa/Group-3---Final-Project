import 'package:flutter/foundation.dart';
import '../db/app_database.dart';
import '../models/mood_entry.dart';

class MoodProvider extends ChangeNotifier {
  final _db = AppDatabase();

  List<MoodEntry> entries = [];
  bool loading = false;

  Future<void> load({
    String? keyword,
    int? mood,
    DateTime? start,
    DateTime? end,
  }) async {
    loading = true;
    notifyListeners();
    entries = await _db.getEntries(
      keyword: keyword,
      mood: mood,
      start: start,
      end: end,
    );
    loading = false;
    notifyListeners();
  }

  Future<MoodEntry?> getToday() async {
    return _db.getEntryByDate(DateTime.now());
  }

  Future<void> upsertToday(int mood, String note) async {
    final existing = await _db.getEntryByDate(DateTime.now());
    if (existing == null) {
      await _db.insertEntry(
        MoodEntry(date: DateTime.now(), mood: mood, note: note),
      );
    } else {
      await _db.updateEntry(existing.copyWith(mood: mood, note: note));
    }
    await load();
  }

  Future<void> delete(int id) async {
    await _db.deleteEntry(id);
    await load();
  }
}
