import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../utils/date_utils.dart';

class EntryCard extends StatelessWidget {
  final MoodEntry entry;
  final VoidCallback? onDelete;

  const EntryCard({super.key, required this.entry, this.onDelete});

  final List<Color> moodColors = const [
    Color(0xFFE74C3C), // 1 red
    Color(0xFFF39C12), // 2 orange
    Color(0xFFF1C40F), // 3 yellow
    Color(0xFF2ECC71), // 4 light green
    Color(0xFF27AE60), // 5 green
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: _buildMoodCircle(entry.mood),
        title: Text(
          fmtHuman(entry.date),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          entry.note,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }

  Widget _buildMoodCircle(int mood) {
    final color = moodColors[(mood - 1).clamp(0, 4)];

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black26, width: 1),
      ),
    );
  }
}
