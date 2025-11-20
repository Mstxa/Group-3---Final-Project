import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../widgets/entry_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchCtrl = TextEditingController();
  int? _mood;
  DateTime? _start;
  DateTime? _end;

  final List<Color> moodColors = const [
    Color(0xFFE74C3C), // 1 red
    Color(0xFFF39C12), // 2 orange
    Color(0xFFF1C40F), // 3 yellow
    Color(0xFF2ECC71), // 4 light green
    Color(0xFF27AE60), // 5 green
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 2);
    final dr = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: DateTime(now.year + 1),
      initialDateRange: _start != null && _end != null
          ? DateTimeRange(start: _start!, end: _end!)
          : null,
    );

    if (dr != null) {
      setState(() {
        _start = dr.start;
        _end = dr.end;
      });

      await context.read<MoodProvider>().load(
        keyword: _searchCtrl.text,
        mood: _mood,
        start: _start,
        end: _end,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MoodProvider>();

    return Column(
      children: [
        /// search filter row
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              /// search bar
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search notes...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (v) => mp.load(
                    keyword: v,
                    mood: _mood,
                    start: _start,
                    end: _end,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              /// mood color button
              PopupMenuButton<int?>(
                icon: Icon(
                  Icons.filter_alt,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),

                itemBuilder: (ctx) => [
                  /// all mood
                  PopupMenuItem(
                    value: null,
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text("All moods"),
                      ],
                    ),
                  ),

                  /// mood 1 – 5 colors
                  ...List.generate(5, (i) {
                    final mood = i + 1;
                    return PopupMenuItem(
                      value: mood,
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: moodColors[i],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text("Mood $mood"),
                        ],
                      ),
                    );
                  }),
                ],
              ),

              /// date range
              IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: _pickDateRange,
                tooltip: 'Pick date range',
              ),
            ],
          ),
        ),

        /// list of enty
        Expanded(
          child: mp.loading
              ? const Center(child: CircularProgressIndicator())
              : mp.entries.isEmpty
              ? const Center(child: Text('No entries'))
              : ListView.builder(
                  itemCount: mp.entries.length,
                  itemBuilder: (ctx, i) {
                    final e = mp.entries[i];
                    return EntryCard(
                      entry: e,
                      onDelete: () => mp.delete(e.id!),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
