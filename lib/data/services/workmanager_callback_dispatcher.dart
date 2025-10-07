import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'workmanager_notification_service.dart';

// Global callback dispatcher for WorkManager
@pragma('vm:entry-point')
void callbackDispatcher() {
  print('🔧 Callback dispatcher initialized');
  Workmanager().executeTask((task, inputData) async {
    print('🔄 WorkManager task executed: $task');
    print('📦 Input data: $inputData');

    try {
      print('🔧 Initializing notification service in background isolate...');
      // Initialize the notification service in the background isolate (without permission request)
      final notificationService = WorkManagerNotificationService();
      try {
        await notificationService.initializeForBackground();
        print('✅ Notification service initialized in background isolate');
      } catch (e) {
        // Handle initialization errors gracefully in background isolate
        print(
            '⚠️ Notification service initialization had minor issues (this is normal): $e');
        print(
            'ℹ️ Notifications will still work if permissions were granted in the main app');
      }

      print('🔍 Processing task: $task');
      switch (task) {
        case 'prayerRescheduler':
          print('🕰 Handling daily prayer rescheduler');
          await WorkManagerNotificationService()
              .rescheduleFromCurrentLocation();
          break;
        case 'prayerNotification':
          print('📿 Handling prayer notification');
          await _handlePrayerNotification(inputData);
          break;
        case 'islamicCalendarNotifications':
          print('📅 Handling Islamic calendar notifications');
          await _handleIslamicCalendarNotifications(inputData);
          break;
        case 'tasbihDailyReminder':
          print('📿 Handling tasbih daily reminder');
          await _handleTasbihDailyReminder(inputData);
          break;
        case 'dailyDuaPopup':
          print('🤲 Handling daily dua popup');
          await _handleDailyDuaPopup(inputData);
          break;
        case 'quranDailyReminder':
          print('📖 Handling Quran daily reminder');
          await _handleQuranDailyReminder(inputData);
          break;
        case 'alKahfFridayReminder':
          print('🕌 Handling Al-Kahf Friday reminder');
          await _handleAlKahfFridayReminder(inputData);
          break;
        default:
          print('❌ Unknown task: $task');
          print(
              '❌ Available tasks: prayerNotification, islamicCalendarNotifications, tasbihDailyReminder, dailyDuaPopup, quranDailyReminder, alKahfFridayReminder');
      }
      print('✅ Task completed successfully');
      return true;
    } catch (e) {
      print('❌ Error executing WorkManager task: $e');
      print('❌ Error stack trace: ${StackTrace.current}');
      return false;
    }
  });
}

@pragma('vm:entry-point')
Future<void> _handlePrayerNotification(Map<String, dynamic>? inputData) async {
  if (inputData == null) return;

  final prayerName = inputData['prayerName'] as String?;
  final prayerTimeString = inputData['prayerTime'] as String?;

  if (prayerName == null || prayerTimeString == null) return;

  final prayerTime = DateTime.parse(prayerTimeString);
  await WorkManagerNotificationService().showPrayerNotification(
    prayerName: prayerName,
    prayerTime: prayerTime,
  );
}

@pragma('vm:entry-point')
Future<void> _handleIslamicCalendarNotifications(
    Map<String, dynamic>? inputData) async {
  await WorkManagerNotificationService().showIslamicCalendarNotification();
}

@pragma('vm:entry-point')
Future<void> _handleTasbihDailyReminder(Map<String, dynamic>? inputData) async {
  print('🎯 _handleTasbihDailyReminder called with input: $inputData');
  final time = inputData?['time'] as String? ?? '12:00 PM';
  print('⏰ Time for tasbih reminder: $time');

  try {
    print('🔔 Attempting to show tasbih notification...');
    await WorkManagerNotificationService().showTasbihReminderNotification(time);
    print('✅ Tasbih notification shown successfully');
  } catch (e) {
    print('❌ Error showing tasbih notification: $e');
    print('❌ Error stack trace: ${StackTrace.current}');
  }

  // Reschedule for next day
  try {
    print('🔄 Attempting to reschedule tasbih reminder...');
    await _rescheduleTasbihReminder(time);
    print('✅ Tasbih reminder rescheduled');
  } catch (e) {
    print('❌ Error rescheduling tasbih reminder: $e');
    print('❌ Error stack trace: ${StackTrace.current}');
  }
}

@pragma('vm:entry-point')
Future<void> _handleDailyDuaPopup(Map<String, dynamic>? inputData) async {
  print('🔄 Handling daily dua popup with input: $inputData');
  final time = inputData?['time'] as String? ?? '12:00 PM';
  print('⏰ Time for daily dua popup: $time');

  try {
    await WorkManagerNotificationService().showDailyDuaPopupNotification(time);
    print('✅ Daily dua notification shown successfully');
  } catch (e) {
    print('❌ Error showing daily dua notification: $e');
  }

  // Reschedule for next day
  try {
    await _rescheduleDailyDuaReminder(time);
    print('✅ Daily dua reminder rescheduled');
  } catch (e) {
    print('❌ Error rescheduling daily dua reminder: $e');
  }
}

@pragma('vm:entry-point')
Future<void> _handleQuranDailyReminder(Map<String, dynamic>? inputData) async {
  print('🔄 Handling Quran daily reminder with input: $inputData');
  final time = inputData?['time'] as String? ?? '12:00 PM';
  print('⏰ Time for Quran reminder: $time');

  try {
    await WorkManagerNotificationService().showQuranReminderNotification(time);
    print('✅ Quran notification shown successfully');
  } catch (e) {
    print('❌ Error showing Quran notification: $e');
  }

  // Reschedule for next day
  try {
    await _rescheduleQuranReminder(time);
    print('✅ Quran reminder rescheduled');
  } catch (e) {
    print('❌ Error rescheduling Quran reminder: $e');
  }
}

@pragma('vm:entry-point')
Future<void> _handleAlKahfFridayReminder(
    Map<String, dynamic>? inputData) async {
  print('🔄 Handling Al-Kahf Friday reminder with input: $inputData');
  final time = inputData?['time'] as String? ?? '12:00 PM';
  print('⏰ Time for Al-Kahf Friday reminder: $time');

  try {
    await WorkManagerNotificationService()
        .showAlKahfFridayReminderNotification(time);
    print('✅ Al-Kahf Friday notification shown successfully');
  } catch (e) {
    print('❌ Error showing Al-Kahf Friday notification: $e');
  }

  // Reschedule for next Friday
  try {
    await _rescheduleAlKahfReminder(time);
    print('✅ Al-Kahf Friday reminder rescheduled');
  } catch (e) {
    print('❌ Error rescheduling Al-Kahf Friday reminder: $e');
  }
}

// Rescheduling helper functions
@pragma('vm:entry-point')
Future<void> _rescheduleTasbihReminder(String time) async {
  try {
    final timeOfDay = _parseTimeString(time);
    if (timeOfDay != null) {
      final delay = _calculateInitialDelay(timeOfDay);

      await Workmanager().registerOneOffTask(
        'tasbih_daily_reminder',
        'tasbihDailyReminder',
        initialDelay: delay,
        constraints: Constraints(
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        inputData: {'time': time},
      );
      print('✅ Tasbih reminder rescheduled for $time');
    }
  } catch (e) {
    print('Error rescheduling tasbih reminder: $e');
  }
}

@pragma('vm:entry-point')
Future<void> _rescheduleDailyDuaReminder(String time) async {
  try {
    final timeOfDay = _parseTimeString(time);
    if (timeOfDay != null) {
      final delay = _calculateInitialDelay(timeOfDay);

      await Workmanager().registerOneOffTask(
        'daily_dua_popup',
        'dailyDuaPopup',
        initialDelay: delay,
        constraints: Constraints(
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        inputData: {'time': time},
      );
      print('✅ Daily dua reminder rescheduled for $time');
    }
  } catch (e) {
    print('Error rescheduling daily dua reminder: $e');
  }
}

@pragma('vm:entry-point')
Future<void> _rescheduleQuranReminder(String time) async {
  try {
    final timeOfDay = _parseTimeString(time);
    if (timeOfDay != null) {
      final delay = _calculateInitialDelay(timeOfDay);

      await Workmanager().registerOneOffTask(
        'quran_daily_reminder',
        'quranDailyReminder',
        initialDelay: delay,
        constraints: Constraints(
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        inputData: {'time': time},
      );
      print('✅ Quran reminder rescheduled for $time');
    }
  } catch (e) {
    print('Error rescheduling Quran reminder: $e');
  }
}

@pragma('vm:entry-point')
Future<void> _rescheduleAlKahfReminder(String time) async {
  try {
    final timeOfDay = _parseTimeString(time);
    if (timeOfDay != null) {
      final delay = _calculateDelayToNextFriday(timeOfDay);

      await Workmanager().registerOneOffTask(
        'al_kahf_friday_reminder',
        'alKahfFridayReminder',
        initialDelay: delay,
        constraints: Constraints(
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        inputData: {'time': time},
      );
      print('✅ Al-Kahf reminder rescheduled for $time');
    }
  } catch (e) {
    print('Error rescheduling Al-Kahf reminder: $e');
  }
}

// Helper functions for time calculations
DateTime? _parseTimeString(String timeString) {
  try {
    final parts = timeString.split(' ');
    final timeParts = parts[0].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPM = parts[1] == 'PM';

    int adjustedHour = hour;
    if (isPM && hour != 12) adjustedHour += 12;
    if (!isPM && hour == 12) adjustedHour = 0;

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, adjustedHour, minute);
  } catch (e) {
    print('Error parsing time string: $e');
    return null;
  }
}

Duration _calculateInitialDelay(DateTime targetTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final targetToday = DateTime(
      today.year, today.month, today.day, targetTime.hour, targetTime.minute);

  Duration delay = targetToday.difference(now);

  // If the time has already passed today, schedule for tomorrow
  if (delay.isNegative) {
    delay = delay + const Duration(days: 1);
  }

  return delay;
}

Duration _calculateDelayToNextFriday(DateTime targetTime) {
  final now = DateTime.now();
  final today = now.weekday; // 1 = Monday, 7 = Sunday

  // Calculate days until next Friday (5 = Friday)
  int daysUntilFriday = 5 - today;
  if (daysUntilFriday <= 0) {
    daysUntilFriday += 7; // Next week's Friday
  }

  final nextFriday = DateTime(now.year, now.month, now.day + daysUntilFriday,
      targetTime.hour, targetTime.minute);
  return nextFriday.difference(now);
}
