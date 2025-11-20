import 'package:flutter/material.dart';

class MoodPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const MoodPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final List<Color> moodColors = const [
    Color(0xFFE74C3C),
    Color(0xFFF39C12),
    Color(0xFFF1C40F),
    Color(0xFF2ECC71),
    Color(0xFF27AE60),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (i) {
        final selected = (i + 1) == value;

        return GestureDetector(
          onTap: () => onChanged(i + 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: selected ? 48 : 38,
            height: selected ? 48 : 38,
            decoration: BoxDecoration(
              color: moodColors[i],
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white : Colors.black26,
                width: selected ? 3 : 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }
}
