import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  if (kIsWeb) return;
  // Initialize plugin
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Initialize time zones (required for zonedSchedule)
  tz.initializeTimeZones();

  // ANDROID 13+ notifications runtime permission
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();

  // ANDROID 12+ exact alarms (บางเครื่องจำเป็นเมื่อใช้ exactAllowWhileIdle)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestExactAlarmsPermission();
}

Future<void> scheduleDailyReminder(int hour, int minute) async {
  if (kIsWeb) return;
  const androidDetails = AndroidNotificationDetails(
    'daily_reminder_channel',
    'Daily Reminder',
    channelDescription: 'Daily mood check-in reminder',
    importance: Importance.max,
    priority: Priority.high,
  );
  const details = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }

  await flutterLocalNotificationsPlugin.zonedSchedule(
    1001,
    'Mood check-in',
    'How are you feeling today? Tap to record.',
    scheduled,
    details,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    // v19 ไม่ต้องใส่ uiLocalNotificationDateInterpretation แล้ว
    matchDateTimeComponents:
        DateTimeComponents.time, // repeat daily at the same wall-clock time
  );
}

Future<void> cancelDailyReminder() async {
  if (kIsWeb) return;
  await flutterLocalNotificationsPlugin.cancel(1001);
}

// Helper to persist TimeOfDay
class TimeOfDaySerializable {
  final int hour;
  final int minute;
  TimeOfDaySerializable(this.hour, this.minute);

  String toJson() => '$hour:$minute';
  static TimeOfDaySerializable fromJson(String s) {
    final parts = s.split(':');
    return TimeOfDaySerializable(int.parse(parts[0]), int.parse(parts[1]));
  }

  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}
