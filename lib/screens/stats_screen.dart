import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/app_database.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTimeRange? _range;
  Map<int, int> _data = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadThisMonth();
  }

  Future<void> _loadThisMonth() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    await _loadRange(DateTimeRange(start: start, end: end));
  }

  Future<void> _loadRange(DateTimeRange range) async {
    setState(() => _loading = true);
    _range = range;
    _data = await AppDatabase().countByMood(range.start, range.end);
    setState(() => _loading = false);
  }

  Future<void> _pick() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 2);
    final dr = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range,
    );
    if (dr != null) await _loadRange(dr);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final maxCount = (_data.values.isEmpty
            ? 1
            : _data.values.reduce((a, b) => a > b ? a : b))
        .toDouble();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _range == null
                    ? 'This Month'
                    : '${_range!.start.year}-${_range!.start.month}  to  ${_range!.end.year}-${_range!.end.month}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                onPressed: _pick,
                icon: const Icon(Icons.date_range),
                color: isDark ? Colors.white : Colors.black,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  "Mood Count",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${_data.values.fold(0, (a, b) => a + b)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    CircleAvatar(backgroundColor: Color(0xFFE74C3C)),
                    CircleAvatar(backgroundColor: Color(0xFFF39C12)),
                    CircleAvatar(backgroundColor: Color(0xFFF1C40F)),
                    CircleAvatar(backgroundColor: Color(0xFF2ECC71)),
                    CircleAvatar(backgroundColor: Color(0xFF27AE60)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : BarChart(
                    BarChartData(
                      backgroundColor: isDark
                          ? Colors.black
                          : Colors.white, // chart bg

                      maxY: maxCount + 1,

                      barGroups: List.generate(5, (i) {
                        final mood = i + 1;
                        final cnt = (_data[mood] ?? 0).toDouble();
                        final colors = [
                          const Color(0xFFE74C3C),
                          const Color(0xFFF39C12),
                          const Color(0xFFF1C40F),
                          const Color(0xFF2ECC71),
                          const Color(0xFF27AE60),
                        ];
                        return BarChartGroupData(
                          x: mood,
                          barRods: [
                            BarChartRodData(
                              toY: cnt,
                              width: 22,
                              color: colors[i],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }),

                      // Axes
                      titlesData: FlTitlesData(
                        rightTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),

                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              );
                            },
                          ),
                        ),

                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value >= 1 && value <= 5) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),

                      // Grid
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 1,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color:
                              isDark ? Colors.white24 : Colors.black12,
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (v) => FlLine(
                          color:
                              isDark ? Colors.white24 : Colors.black12,
                          strokeWidth: 1,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
