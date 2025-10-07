import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'workmanager_callback_dispatcher.dart';
import 'package:adhan/adhan.dart';

class WorkManagerNotificationService {
  static final WorkManagerNotificationService _instance =
      WorkManagerNotificationService._internal();
  factory WorkManagerNotificationService() => _instance;
  WorkManagerNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Flag to prevent duplicate notification scheduling
  bool _notificationsScheduled = false;

  // Reset notification scheduling flag (call this when prayer times change)
  void resetNotificationScheduling() {
    _notificationsScheduled = false;
    print('🔄 Notification scheduling flag reset');
  }

  // Channel IDs for different notification types
  static const String defaultChannelId = 'prayer_notifications_default';
  static const String customChannelId = 'prayer_notifications_custom';

  // Initialize the notification service
  Future<void> initialize() async {
    print('🔧 Initializing WorkManagerNotificationService...');

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      print('✅ Timezone initialized');

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      print('✅ FlutterLocalNotificationsPlugin initialized');

      // Create notification channels
      await _createNotificationChannels();
      print('✅ Notification channels created');

      // Request notification permissions for Android 13+
      await _requestNotificationPermissions();
      print('✅ Notification permissions requested');

      // Request exact alarms permission on Android 12+
      await _requestExactAlarmsPermissionIfNeeded();
      print('✅ Exact alarms permission flow requested (Android 12+)');

      print('✅ WorkManagerNotificationService initialized successfully');
    } catch (e) {
      print('❌ Error initializing WorkManagerNotificationService: $e');
      print('❌ Error stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Initialize the notification service for background isolate (without permission request)
  Future<void> initializeForBackground() async {
    print(
        '🔧 Initializing WorkManagerNotificationService for background isolate...');

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      print('✅ Timezone initialized');

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      print('✅ FlutterLocalNotificationsPlugin initialized');

      // Create notification channels
      await _createNotificationChannels();
      print('✅ Notification channels created');

      // Skip permission request in background isolate
      print(
          'ℹ️ Skipping permission request in background isolate (permissions handled in main app)');

      print(
          '✅ WorkManagerNotificationService initialized for background isolate');
    } catch (e) {
      print(
          '❌ Error initializing WorkManagerNotificationService for background: $e');
      print('❌ Error stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Initialize WorkManager
  Future<void> initializeWorkManager() async {
    print('🔧 Initializing WorkManager...');
    try {
      await Workmanager().initialize(callbackDispatcher);
      print('✅ WorkManager initialized successfully');

      // Register a daily rescheduler to recompute and re-schedule prayers
      await registerDailyRescheduler();
    } catch (e) {
      print('❌ WorkManager initialization error: $e');
      print('❌ Error stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Request notification permissions (should only be called from main app, not background isolate)
  Future<void> requestNotificationPermissions() async {
    print('🔧 Requesting notification permissions from main app...');
    await _requestNotificationPermissions();
    print('✅ Notification permissions requested from main app');
  }

  Future<void> _createNotificationChannels() async {
    print('🔧 Creating notification channels...');

    try {
      // Default channel for built-in azan sounds
      const AndroidNotificationChannel defaultChannel =
          AndroidNotificationChannel(
        defaultChannelId,
        'Prayer Notifications',
        description: 'Notifications for prayer times with default azan sounds',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azan_madinah'),
      );

      // Custom channel for user-selected sounds
      const AndroidNotificationChannel customChannel =
          AndroidNotificationChannel(
        customChannelId,
        'Custom Prayer Notifications',
        description: 'Notifications for prayer times with custom sounds',
        importance: Importance.max,
        playSound: true,
      );

      // Islamic Calendar Notifications channel
      const AndroidNotificationChannel islamicCalendarChannel =
          AndroidNotificationChannel(
        'islamic_calendar_notifications',
        'Islamic Calendar Notifications',
        description: 'Notifications for Islamic calendar events',
        importance: Importance.high,
        playSound: true,
      );

      // Tasbih Daily Reminder channel
      const AndroidNotificationChannel tasbihChannel =
          AndroidNotificationChannel(
        'tasbih_daily_reminder',
        'Tasbih Daily Reminder',
        description: 'Daily reminders for tasbih',
        importance: Importance.high,
        playSound: true,
      );

      // Daily Dua Popup channel
      const AndroidNotificationChannel dailyDuaChannel =
          AndroidNotificationChannel(
        'daily_dua_popup',
        'Daily Dua Popup',
        description: 'Daily dua reminders',
        importance: Importance.high,
        playSound: true,
      );

      // Quran Daily Reminder channel
      const AndroidNotificationChannel quranChannel =
          AndroidNotificationChannel(
        'quran_daily_reminder',
        'Quran Daily Reminder',
        description: 'Daily reminders for Quran reading',
        importance: Importance.high,
        playSound: true,
      );

      // Al-Kahf Friday Reminder channel
      const AndroidNotificationChannel alKahfChannel =
          AndroidNotificationChannel(
        'al_kahf_friday_reminder',
        'Al-Kahf Friday Reminder',
        description: 'Friday reminders for reading Surah Al-Kahf',
        importance: Importance.high,
        playSound: true,
      );

      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(defaultChannel);
        print('✅ Default channel created');

        await androidImplementation.createNotificationChannel(customChannel);
        print('✅ Custom channel created');

        await androidImplementation
            .createNotificationChannel(islamicCalendarChannel);
        print('✅ Islamic calendar channel created');

        await androidImplementation.createNotificationChannel(tasbihChannel);
        print('✅ Tasbih channel created');

        await androidImplementation.createNotificationChannel(dailyDuaChannel);
        print('✅ Daily dua channel created');

        await androidImplementation.createNotificationChannel(quranChannel);
        print('✅ Quran channel created');

        await androidImplementation.createNotificationChannel(alKahfChannel);
        print('✅ Al-Kahf channel created');
      } else {
        print('⚠️ Android implementation not available');
      }

      print('✅ All notification channels created successfully');
    } catch (e) {
      print('❌ Error creating notification channels: $e');
      print('❌ Error stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _requestNotificationPermissions() async {
    print('🔧 Requesting notification permissions...');

    try {
      // Request notification permissions for Android 13+
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted =
            await androidImplementation.requestNotificationsPermission();
        print('✅ Notification permission granted: $granted');

        // Check if we can show notifications
        final bool? canShowNotifications =
            await androidImplementation.areNotificationsEnabled();
        print('✅ Can show notifications: $canShowNotifications');

        if (granted == true && canShowNotifications == true) {
          print('✅ All notification permissions are properly set');
        } else {
          print('⚠️ Notification permissions may not be properly set');
        }
      } else {
        print('⚠️ Android implementation not available for permission request');
      }
    } catch (e) {
      print('❌ Error requesting notification permissions: $e');
      print('❌ Error stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    try {
      final payload = response.payload;
      print('Notification tapped. Raw payload: $payload');
      if (payload == null || payload.isEmpty) {
        return;
      }

      final Map<String, dynamic> data = jsonDecode(payload);
      final String? route = data['route'] as String?;
      final String? id = data['id']?.toString();
      print('Parsed payload -> route: $route, id: $id');

      if (route != null && route.isNotEmpty) {
        // Use GetX navigation since app uses GetMaterialApp
        if (route == '/dua_details' && id != null && id.isNotEmpty) {
          // Navigate to a real Dua details screen if available via named route
          // Otherwise, open main Dua list
          Get.toNamed('/dua_details', arguments: {'id': id});
        } else if (route == '/duas') {
          Get.toNamed('/duas');
        } else {
          // Unknown route -> open duas list as a safe default
          Get.toNamed('/duas');
        }
      }
    } catch (e) {
      print('❌ Error handling notification tap: $e');
      // Safe default navigation
      try {
        Get.toNamed('/duas');
      } catch (_) {}
    }
  }

  // Settings Management Methods
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }

  Future<void> enableNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    if (!enabled) {
      await cancelAllPrayerNotifications();
    }
  }

  Future<void> updateNotificationSettings() async {
    // This method can be called when user changes notification settings
    print('Notification settings updated');
  }

  // Cancel all prayer notifications
  Future<void> cancelAllPrayerNotifications() async {
    // Cancel prayer notification IDs (1-6)
    for (int i = 1; i <= 6; i++) {
      await _flutterLocalNotificationsPlugin.cancel(i);
    }

    // Also cancel any test notifications
    for (int i = 998; i <= 1006; i++) {
      await _flutterLocalNotificationsPlugin.cancel(i);
    }

    // Cancel all WorkManager tasks
    await cancelAllWorkManagerTasks();

    print('All prayer notifications cancelled');
  }

  // Request exact alarms (Android 12+)
  Future<void> _requestExactAlarmsPermissionIfNeeded() async {
    try {
      final androidImpl = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestExactAlarmsPermission();
    } catch (e) {
      print('⚠️ Exact alarm permission request failed or unavailable: $e');
    }
  }

  // Expose a public method for UI to request exact alarms permission
  Future<void> requestExactAlarmsPermissionFromUI() async {
    await _requestExactAlarmsPermissionIfNeeded();
  }

  // Schedule a daily rescheduler to recompute and schedule next day's prayers
  Future<void> registerDailyRescheduler() async {
    try {
      const uniqueName = 'prayerRescheduler';
      await Workmanager().registerPeriodicTask(
        uniqueName,
        uniqueName,
        frequency: const Duration(days: 1),
        initialDelay: _computeInitialDelayForDailyReschedule(),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
      print('✅ Daily rescheduler registered');
    } catch (e) {
      print('⚠️ Failed to register daily rescheduler: $e');
    }
  }

  Duration _computeInitialDelayForDailyReschedule() {
    final now = DateTime.now();
    final todayAt2 = DateTime(now.year, now.month, now.day, 2);
    final next = todayAt2.isAfter(now)
        ? todayAt2
        : todayAt2.add(const Duration(days: 1));
    return next.difference(now);
  }

  // Called from background callback to recompute using saved location
  Future<void> rescheduleFromCurrentLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('selected_latitude') ?? 25.2854;
      final lng = prefs.getDouble('selected_longitude') ?? 51.5310;

      tz.initializeTimeZones();

      final coordinates = Coordinates(lat, lng);
      final params = CalculationMethod.muslim_world_league.getParameters();
      final today = DateTime.now();
      final date = DateComponents.from(today);
      final times = PrayerTimes(coordinates, date, params);

      final List<Map<String, dynamic>> todayPrayers = [
        {'name': 'Fajr', 'time': times.fajr},
        {'name': 'Sunrise', 'time': times.sunrise},
        {'name': 'Dhuhr', 'time': times.dhuhr},
        {'name': 'Asr', 'time': times.asr},
        {'name': 'Maghrib', 'time': times.maghrib},
        {'name': 'Isha', 'time': times.isha},
      ];

      for (final p in todayPrayers) {
        final name = p['name'] as String;
        final dt = p['time'] as DateTime;
        if (dt.isBefore(DateTime.now())) {
          continue;
        }
        await scheduleExactPrayerNotification(
          prayerName: name,
          localDateTime: dt,
        );
      }

      print('✅ Rescheduled remaining prayers for today at lat=$lat, lng=$lng');
    } catch (e) {
      print('⚠️ Failed to reschedule from current location: $e');
    }
  }

  // Exact-time zoned scheduling using flutter_local_notifications + tz
  Future<void> scheduleExactPrayerNotification({
    required String prayerName,
    required DateTime localDateTime,
  }) async {
    try {
      // Ensure timezone database is initialized (safe to call multiple times)
      tz.initializeTimeZones();

      final tz.TZDateTime tzTime = tz.TZDateTime.from(localDateTime, tz.local);

      final int notificationId = _getNotificationId(prayerName);
      final String title = _getPrayerTitle(prayerName);
      final String body = _getPrayerBody(prayerName);

      print('🕰 Scheduling exact Adhan notification');
      print('   • Prayer: $prayerName');
      print('   • Local DateTime: $localDateTime');
      print('   • TZ: ${tz.local.name} -> $tzTime');
      print('   • Notification ID: $notificationId');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        tzTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            WorkManagerNotificationService.defaultChannelId,
            'Prayer Notifications',
            channelDescription: 'Exact-time Adhan notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
          ),
          iOS: DarwinNotificationDetails(presentSound: true),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
        payload: 'adhan',
      );

      print('✅ Exact Adhan scheduled at $tzTime (${tz.local.name})');
    } catch (e) {
      print('❌ zonedSchedule failed for $prayerName at $localDateTime: $e');
      rethrow;
    }
  }

  // WorkManager Methods

  Future<void> schedulePrayerNotificationsWithWorkManager(
    List<Map<String, dynamic>> prayerTimes,
  ) async {
    // Prevent duplicate scheduling
    if (_notificationsScheduled) {
      print('⚠️ Notifications already scheduled, skipping...');
      return;
    }

    try {
      print('🔄 Scheduling prayer notifications with exact zoned schedule...');
      _notificationsScheduled = true;

      bool workManagerFailed = false;

      for (final prayerTime in prayerTimes) {
        final prayerName = prayerTime['name'] as String;
        final prayerTimeDateTime = prayerTime['time'] as DateTime;
        try {
          // If the time already passed today, schedule for tomorrow at same clock time
          final now = DateTime.now();
          final adjusted = prayerTimeDateTime.isBefore(now)
              ? prayerTimeDateTime.add(const Duration(days: 1))
              : prayerTimeDateTime;

          await scheduleExactPrayerNotification(
            prayerName: prayerName,
            localDateTime: adjusted,
          );
        } catch (e) {
          print(
              '⚠️ Exact schedule failed for $prayerName, falling back to WorkManager/Timer');
          workManagerFailed = true;

          // Fallback to WorkManager duration scheduling
          final now = DateTime.now();
          final delay = (prayerTimeDateTime.isBefore(now)
                  ? prayerTimeDateTime.add(const Duration(days: 1))
                  : prayerTimeDateTime)
              .difference(now);
          await _scheduleSinglePrayerNotificationWithWorkManager(
            prayerName: prayerName,
            prayerTime: prayerTimeDateTime,
            delay: delay,
          );
        }
      }

      if (workManagerFailed) {
        print(
            '✅ Prayer notifications scheduled (some via WorkManager/Timer fallback)');
      } else {
        print('✅ Prayer notifications scheduled with exact zoned schedule');
      }
    } catch (e) {
      print('❌ Error scheduling prayer notifications with WorkManager: $e');
      // Fallback to Timer-based scheduling for the entire list if the initial WorkManager scheduling loop fails
      await _schedulePrayerNotificationsWithTimer(prayerTimes);
    }
  }

  Future<void> _scheduleSinglePrayerNotificationWithWorkManager({
    required String prayerName,
    required DateTime prayerTime,
    required Duration delay,
  }) async {
    try {
      final inputData = {
        'prayerName': prayerName,
        'prayerTime': prayerTime.toIso8601String(),
      };

      final taskId =
          'prayer_${prayerName.toLowerCase()}_${prayerTime.millisecondsSinceEpoch}';

      await Workmanager().registerOneOffTask(
        taskId,
        'prayerNotification',
        inputData: inputData,
        initialDelay: delay,
      );

      print(
          'Scheduled WorkManager notification for $prayerName at ${prayerTime.toString()}');
    } catch (e) {
      print('Error scheduling WorkManager notification for $prayerName: $e');
      // Fallback to Timer immediately when WorkManager fails
      _scheduleSinglePrayerNotificationWithTimer(
        prayerName: prayerName,
        prayerTime: prayerTime,
        delay: delay,
      );
    }
  }

  Future<void> _schedulePrayerNotificationsWithTimer(
    List<Map<String, dynamic>> prayerTimes,
  ) async {
    try {
      print('Using Timer fallback for prayer notifications...');

      for (final prayerTime in prayerTimes) {
        final prayerName = prayerTime['name'] as String;
        final prayerTimeDateTime = prayerTime['time'] as DateTime;

        // Calculate delay until prayer time
        final now = DateTime.now();
        final delay = prayerTimeDateTime.difference(now);

        if (delay.isNegative) {
          // Prayer time has passed, schedule for tomorrow
          final tomorrow = prayerTimeDateTime.add(const Duration(days: 1));
          final tomorrowDelay = tomorrow.difference(now);
          _scheduleSinglePrayerNotificationWithTimer(
            prayerName: prayerName,
            prayerTime: tomorrow,
            delay: tomorrowDelay,
          );
        } else {
          _scheduleSinglePrayerNotificationWithTimer(
            prayerName: prayerName,
            prayerTime: prayerTimeDateTime,
            delay: delay,
          );
        }
      }

      print('Prayer notifications scheduled with Timer fallback successfully');
    } catch (e) {
      print('Error scheduling Timer-based prayer notifications: $e');
    }
  }

  void _scheduleSinglePrayerNotificationWithTimer({
    required String prayerName,
    required DateTime prayerTime,
    required Duration delay,
  }) {
    try {
      print(
          'Scheduling Timer-based notification for $prayerName at ${prayerTime.toString()}');

      Timer(delay, () async {
        await showPrayerNotification(
          prayerName: prayerName,
          prayerTime: prayerTime,
        );
      });

      print('Timer-based prayer notification scheduled for $prayerName');
    } catch (e) {
      print(
          'Error scheduling Timer-based prayer notification for $prayerName: $e');
    }
  }

  // Show notification methods (called by WorkManager)
  Future<void> showPrayerNotification({
    required String prayerName,
    required DateTime prayerTime,
  }) async {
    try {
      // Get notification settings
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? false;

      if (!notificationsEnabled) {
        print('Prayer notifications are disabled');
        return;
      }

      final selectedSound =
          prefs.getString('selected_adhan_sound') ?? 'Athan (Madina)';
      final customRingtonePath = prefs.getString('custom_ringtone_path');

      // Get notification ID, title, and body
      final notificationId = _getNotificationId(prayerName);
      final title = _getPrayerTitle(prayerName);
      final body = _getPrayerBody(prayerName);

      // Determine sound and channel
      String channelId;
      AndroidNotificationSound? androidSound;
      String? iosSound;

      if (customRingtonePath != null && customRingtonePath.isNotEmpty) {
        // Use custom sound
        channelId = customChannelId;
        androidSound = null; // Will be handled by the channel
        iosSound = customRingtonePath;
      } else {
        // Use default azan sound
        final soundPath = _getDefaultAzanSound(selectedSound);
        channelId = defaultChannelId;
        androidSound = RawResourceAndroidNotificationSound(soundPath);
        iosSound = 'azan_default.aiff';
      }

      // Create notification details
      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == defaultChannelId
              ? 'Prayer Notifications'
              : 'Custom Prayer Notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: androidSound,
          icon: '@mipmap/launcher_icon',
          largeIcon:
              const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
          color: const Color(0xFF0CB002),
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          autoCancel: false,
          ongoing: false,
          showWhen: true,
          when: prayerTime.millisecondsSinceEpoch,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: iosSound,
          categoryIdentifier: 'PRAYER_NOTIFICATION',
        ),
      );

      // Show the notification
      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
      );

      print('Prayer notification shown for $prayerName');
    } catch (e) {
      print('Error showing prayer notification for $prayerName: $e');
    }
  }

  // Islamic Calendar Notifications
  Future<void> showIslamicCalendarNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('language') ?? 'en';

      final title = _getLocalizedTitle('islamic_calendar', language);
      final body = _getLocalizedBody('islamic_calendar', language);

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'islamic_calendar_notifications',
        'Islamic Calendar Notifications',
        channelDescription: 'Notifications for Islamic calendar events',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        1001,
        title,
        body,
        platformChannelSpecifics,
      );
      print('✅ Islamic calendar notification shown');
    } catch (e) {
      print('Error showing Islamic calendar notification: $e');
    }
  }

  // Tasbih Daily Reminder
  Future<void> showTasbihReminderNotification(String time) async {
    print('🔔 Attempting to show tasbih reminder notification...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('language') ?? 'en';
      print('🌍 Language: $language');

      final title = _getLocalizedTitle('tasbih', language);
      final body = _getLocalizedBody('tasbih', language);
      print('📝 Title: $title');
      print('📄 Body: $body');

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'tasbih_daily_reminder',
        'Tasbih Daily Reminder',
        channelDescription: 'Daily reminders for tasbih',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      print('📱 Showing notification with ID: 1002');
      await _flutterLocalNotificationsPlugin.show(
        1002,
        title,
        body,
        platformChannelSpecifics,
      );
      print('✅ Tasbih reminder notification shown successfully');
    } catch (e) {
      print('❌ Error showing tasbih reminder notification: $e');
      print('❌ Error stack trace: ${StackTrace.current}');
    }
  }

  // Daily Dua Popup
  Future<void> showDailyDuaPopupNotification(String time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('language') ?? 'en';

      final title = _getLocalizedTitle('daily_dua', language);
      final body = _getLocalizedBody('daily_dua', language);

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'daily_dua_popup',
        'Daily Dua Popup',
        channelDescription: 'Daily dua reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      // Attach payload with route and optional dua id (if stored)
      final String? duaId = prefs.getString('daily_dua_id');
      final String payload = jsonEncode({
        'route': duaId != null && duaId.isNotEmpty ? '/dua_details' : '/duas',
        'id': duaId ?? '',
      });

      await _flutterLocalNotificationsPlugin.show(
        1003,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
      print('✅ Daily dua notification shown');
    } catch (e) {
      print('Error showing daily dua notification: $e');
    }
  }

  // Quran Daily Reminder
  Future<void> showQuranReminderNotification(String time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('language') ?? 'en';

      final title = _getLocalizedTitle('quran', language);
      final body = _getLocalizedBody('quran', language);

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'quran_daily_reminder',
        'Quran Daily Reminder',
        channelDescription: 'Daily reminders for Quran reading',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        1004,
        title,
        body,
        platformChannelSpecifics,
      );
      print('✅ Quran reminder notification shown');
    } catch (e) {
      print('Error showing Quran reminder notification: $e');
    }
  }

  // Al-Kahf Friday Reminder
  Future<void> showAlKahfFridayReminderNotification(String time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('language') ?? 'en';

      final title = _getLocalizedTitle('al_kahf', language);
      final body = _getLocalizedBody('al_kahf', language);

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'al_kahf_friday_reminder',
        'Al-Kahf Friday Reminder',
        channelDescription: 'Friday reminders for reading Surah Al-Kahf',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        1005,
        title,
        body,
        platformChannelSpecifics,
      );
      print('✅ Al-Kahf Friday reminder notification shown');
    } catch (e) {
      print('Error showing Al-Kahf Friday reminder notification: $e');
    }
  }

  // Helper methods
  int _getNotificationId(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 1;
      case 'sunrise':
        return 2;
      case 'dhuhr':
        return 3;
      case 'asr':
        return 4;
      case 'maghrib':
        return 5;
      case 'isha':
        return 6;
      default:
        return 0;
    }
  }

  String _getPrayerTitle(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 'Fajr Prayer Time';
      case 'sunrise':
        return 'Sunrise';
      case 'dhuhr':
        return 'Dhuhr Prayer Time';
      case 'asr':
        return 'Asr Prayer Time';
      case 'maghrib':
        return 'Maghrib Prayer Time';
      case 'isha':
        return 'Isha Prayer Time';
      default:
        return 'Prayer Time';
    }
  }

  String _getPrayerBody(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 'It\'s time for Fajr prayer. May Allah accept your prayers.';
      case 'sunrise':
        return 'The sun has risen. A new day begins with Allah\'s blessings.';
      case 'dhuhr':
        return 'It\'s time for Dhuhr prayer. May Allah accept your prayers.';
      case 'asr':
        return 'It\'s time for Asr prayer. May Allah accept your prayers.';
      case 'maghrib':
        return 'It\'s time for Maghrib prayer. May Allah accept your prayers.';
      case 'isha':
        return 'It\'s time for Isha prayer. May Allah accept your prayers.';
      default:
        return 'It\'s time for prayer. May Allah accept your prayers.';
    }
  }

  String _getDefaultAzanSound(String selectedSound) {
    // Map selected sound names to asset file names
    switch (selectedSound.toLowerCase()) {
      case 'athan':
      case 'default ringtone':
        return 'azan_madinah';
      case 'long beep':
        return 'azan_madinah';
      case 'azan_dousary':
      case 'athan (dousary)':
        return 'azan_dousary';
      case 'azan_madinah':
      case 'athan (madina)':
        return 'azan_madinah';
      case 'azan_makah':
      case 'athan (makkah)':
        return 'azan_makah';
      case 'azan_naser':
      case 'athan (nasser al qatami)':
        return 'azan_naser';
      default:
        return 'azan_madinah';
    }
  }

  // Cancel all WorkManager tasks
  Future<void> cancelAllWorkManagerTasks() async {
    try {
      await Workmanager().cancelAll();
      print('All WorkManager tasks cancelled');
    } catch (e) {
      print('Error cancelling WorkManager tasks: $e');
    }
  }

  // Localization helper methods
  String _getLocalizedTitle(String type, String language) {
    switch (type) {
      case 'islamic_calendar':
        switch (language) {
          case 'ar':
            return 'تحديث التقويم الإسلامي';
          case 'bn':
            return 'ইসলামিক ক্যালেন্ডার আপডেট';
          default:
            return 'Islamic Calendar Update';
        }
      case 'tasbih':
        switch (language) {
          case 'ar':
            return 'تذكير التسبيح';
          case 'bn':
            return 'তাসবিহ স্মরণ';
          default:
            return 'Tasbih Reminder';
        }
      case 'daily_dua':
        switch (language) {
          case 'ar':
            return 'الدعاء اليومي';
          case 'bn':
            return 'দৈনিক দোয়া';
          default:
            return 'Daily Dua';
        }
      case 'quran':
        switch (language) {
          case 'ar':
            return 'تذكير القرآن';
          case 'bn':
            return 'কুরআন স্মরণ';
          default:
            return 'Quran Reading Reminder';
        }
      case 'al_kahf':
        switch (language) {
          case 'ar':
            return 'تذكير سورة الكهف';
          case 'bn':
            return 'সূরা আল-কাহফ স্মরণ';
          default:
            return 'Surah Al-Kahf Reminder';
        }
      default:
        return 'Notification';
    }
  }

  String _getLocalizedBody(String type, String language) {
    switch (type) {
      case 'islamic_calendar':
        switch (language) {
          case 'ar':
            return 'تحقق من التاريخ الإسلامي اليوم والأحداث القادمة';
          case 'bn':
            return 'আজকের ইসলামিক তারিখ এবং আসন্ন ঘটনাগুলি দেখুন';
          default:
            return 'Check today\'s Islamic date and upcoming events';
        }
      case 'tasbih':
        switch (language) {
          case 'ar':
            return 'حان وقت التسبيح اليومي. تذكر أن تحمد الله.';
          case 'bn':
            return 'আপনার দৈনিক তাসবিহের সময়। আল্লাহর প্রশংসা করতে ভুলবেন না।';
          default:
            return 'Time for your daily tasbih. Remember to praise Allah.';
        }
      case 'daily_dua':
        switch (language) {
          case 'ar':
            return 'حان وقت الدعاء اليومي. تواصل مع الله من خلال الدعاء.';
          case 'bn':
            return 'আপনার দৈনিক দোয়ার সময়। দোয়ার মাধ্যমে আল্লাহর সাথে সংযোগ করুন।';
          default:
            return 'Time for your daily dua. Connect with Allah through supplication.';
        }
      case 'quran':
        switch (language) {
          case 'ar':
            return 'حان وقت قراءة القرآن اليومية. اطلب الهداية من كلمات الله.';
          case 'bn':
            return 'আপনার দৈনিক কুরআন পড়ার সময়। আল্লাহর বাণী থেকে দিকনির্দেশনা চান।';
          default:
            return 'Time for your daily Quran reading. Seek guidance from Allah\'s words.';
        }
      case 'al_kahf':
        switch (language) {
          case 'ar':
            return 'إنه يوم الجمعة! لا تنس قراءة سورة الكهف لبركاتها الخاصة.';
          case 'bn':
            return 'এটা শুক্রবার! এর বিশেষ বরকতের জন্য সূরা আল-কাহফ পড়তে ভুলবেন না।';
          default:
            return 'It\'s Friday! Don\'t forget to read Surah Al-Kahf for its special blessings.';
        }
      default:
        return 'Notification';
    }
  }
}
