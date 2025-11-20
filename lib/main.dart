import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mood_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/today_screen.dart';
import 'screens/history_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
  } else {
    await initNotifications();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoodProvider()..load()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (ctx, sp, _) {
          return MaterialApp(
            title: 'Daily Mood Journal',
            themeMode: sp.dark ? ThemeMode.dark : ThemeMode.light,

            // Light Theme
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),

            // Dark Theme
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black,
              primaryColor: Colors.green,
              useMaterial3: true,

              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white),
                titleLarge: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
                titleMedium: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),

              iconTheme: const IconThemeData(color: Colors.white),

              inputDecorationTheme: const InputDecorationTheme(
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                hintStyle: TextStyle(color: Colors.white54),
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),

              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              listTileTheme: const ListTileThemeData(
                textColor: Colors.white,
                iconColor: Colors.white,
              ),

              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: const Color(0xFF111111),
                indicatorColor: Colors.green.withOpacity(0.25),
                iconTheme: const WidgetStatePropertyAll(
                  IconThemeData(color: Colors.white),
                ),
                labelTextStyle: const WidgetStatePropertyAll(
                  TextStyle(color: Colors.white),
                ),
              ),
            ),

            home: const HomeShell(),
          );
        },
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _screens = const [
    TodayScreen(),
    HistoryScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  final _titles = const [
    'Today',
    'History',
    'Statistics',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_reaction_outlined),
            selectedIcon: Icon(Icons.add_reaction),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
