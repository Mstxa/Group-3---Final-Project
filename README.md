📓 Daily Mood Journal

A Flutter application designed to help users track their daily mood, write reflections, review emotional history, and view simple mood statistics. The app uses a local database, Provider state management, and optional notifications to remind users to log their mood daily.

⸻

✨ Features
 • Record Today’s Mood
Choose mood type, write notes, and save today’s entry.
 • History View
See all past mood entries in a clean list.
 • Statistics Dashboard
Simple mood summary & frequency analysis.
 • Local Database (SQLite)
All moods saved locally using sqflite.
 • Provider State Management
Mood state and settings handled through Providers.
 • Daily Reminders (Notifications)
Local notifications to remind users to journal.
 • Clean Modular Architecture
Separate models, screens, utilities, database helper, and widgets.

⸻

📁 Project Structure

lib/
├── main.dart                     # App entry point
│
├── models/
│   └── mood_entry.dart           # Data model for storing mood records
│
├── providers/
│   ├── mood_provider.dart        # Handles mood CRUD operations
│   └── settings_provider.dart    # Manages app settings (theme, notifications)
│
├── screens/
│   ├── today_screen.dart         # Main screen to input today's mood
│   ├── history_screen.dart       # View past mood entries
│   ├── stats_screen.dart         # Mood analytics + summary
│   └── settings_screen.dart      # App settings (theme, reminders)
│
├── widgets/
│   ├── entry_card.dart           # UI card for mood entries
│   └── mood_picker.dart          # Mood selection widget (icons / emojis)
│
├── db/
│   └── app_database.dart         # SQLite database setup & queries
│
└── utils/
    ├── date_utils.dart           # Date formatting helper functions
    └── notifications.dart        # Local notification setup & triggers


⸻

🛠️ Technologies Used

Category Technology
Framework Flutter
Language Dart
State Management Provider
Database SQLite (sqflite)
Notifications flutter_local_notifications
Architecture MVVM-style (Provider + Models + Screens)


⸻

🚀 Getting Started

1️⃣ Install dependencies

flutter pub get

2️⃣ Run the app

flutter run

3️⃣ Build release APK

flutter build apk --release


⸻

📦 Main Components

📌 MoodEntry Model (models/mood_entry.dart)

Defines:
 • mood (enum/int)
 • date
 • note
 • toMap / fromMap for SQLite

📌 MoodProvider (providers/mood_provider.dart)

Handles:
 • Load mood history
 • Insert new mood entry
 • Get today’s entry
 • Provide data to UI

📌 SettingsProvider (providers/settings_provider.dart)

Handles:
 • Theme mode (light/dark)
 • Notification scheduling
 • User preferences

📌 AppDatabase (db/app_database.dart)

Controls:
 • Database initialization
 • Table creation
 • CRUD operations

📌 Notifications (utils/notifications.dart)

Handles:
 • Permission request
 • Schedule daily reminders

📌 UI Screens
 • today_screen.dart – record today’s mood
 • history_screen.dart – timeline of past entries
 • stats_screen.dart – mood statistics
 • settings_screen.dart – theme + notifications

⸻

📊 Stats & Analytics

The app includes a simple statistics screen that shows:
 • Mood count
 • Mood frequency
 • Simple charts (if implemented)

⸻

🧩 Widgets

Reusable components for clean UI:
 • entry_card.dart – card for mood display
 • mood_picker.dart – UI selector of mood icons/emojis

⸻

🌙 Dark Mode Support

Theme settings handled by SettingsProvider.

⸻

🔔 Daily Notification Reminder

Users can enable reminders to log moods every day.

⸻

🤝 Contribution

Feel free to submit pull requests or improvements!
Suggested improvements:
 • Add cloud sync (Firebase)
 • Add charts (fl_chart or charts_flutter)
 • Add lock screen widget
 • Add export/import feature

⸻

📜 License

MIT License — free to modify and distribute.
