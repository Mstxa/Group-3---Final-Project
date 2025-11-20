class MoodEntry {
  final int? id;
  final DateTime date; // stored as UTC midnight
  final int mood; // 1..5 (1 = very bad, 5 = very good)
  final String note;

  MoodEntry({
    this.id,
    required this.date,
    required this.mood,
    required this.note,
  });

  MoodEntry copyWith({int? id, DateTime? date, int? mood, String? note}) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toUtc().millisecondsSinceEpoch,
      'mood': mood,
      'note': note,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as int?,
      date: DateTime.fromMillisecondsSinceEpoch(
        map['date'],
        isUtc: true,
      ).toLocal(),
      mood: map['mood'] as int,
      note: map['note'] as String? ?? '',
    );
  }
}
