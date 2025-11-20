import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});
  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final _noteCtrl = TextEditingController();
  int _mood = 3;
  bool _loaded = false;

  final List<Color> moodColors = const [
    Color(0xFFE74C3C),
    Color(0xFFF39C12),
    Color(0xFFF1C40F),
    Color(0xFF2ECC71),
    Color(0xFF27AE60),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final mp = context.read<MoodProvider>();
        final today = await mp.getToday();
        if (!mounted) return;
        setState(() {
          _mood = today?.mood ?? 3;
          _noteCtrl.text = today?.note ?? '';
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to load today: $e')));
        }
      } finally {
        if (mounted) setState(() => _loaded = true);
      }
    });
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          Text(
            'How do you feel today?',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(moodColors.length, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _mood = i + 1),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: moodColors[i],
                      shape: BoxShape.circle,
                      border: _mood == i + 1
                          ? Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors
                                        .white
                                  : Colors.black,
                              width: 3,
                            )
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 24),

          /// note box
          TextField(
            controller: _noteCtrl,
            style: const TextStyle(color: Colors.black),
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Write a short note...',
              hintStyle: TextStyle(color: Colors.black45),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          const Spacer(),

          /// save button
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () async {
                await context.read<MoodProvider>().upsertToday(
                  _mood,
                  _noteCtrl.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Today's entry saved.")),
                  );
                }
              },
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
