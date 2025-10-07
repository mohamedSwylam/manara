import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../../services/workmanager_notification_service.dart';
import 'reminders_notifications_event.dart';
import 'reminders_notifications_state.dart';

class RemindersNotificationsBloc extends Bloc<RemindersNotificationsEvent, RemindersNotificationsState> {
  final WorkManagerNotificationService _workManagerService = WorkManagerNotificationService();
  
  RemindersNotificationsBloc() : super(RemindersNotificationsInitial()) {
    on<LoadRemindersSettings>(_onLoadRemindersSettings);
    on<ToggleIslamicCalendarNotifications>(_onToggleIslamicCalendarNotifications);
    on<ToggleTasbihDailyReminder>(_onToggleTasbihDailyReminder);
    on<ToggleDailyDuaPopup>(_onToggleDailyDuaPopup);
    on<ToggleQuranDailyReminder>(_onToggleQuranDailyReminder);
    on<ToggleAlKahfFridayReminder>(_onToggleAlKahfFridayReminder);
    on<UpdateTasbihTime>(_onUpdateTasbihTime);
    on<UpdateDailyDuaTime>(_onUpdateDailyDuaTime);
    on<UpdateQuranTime>(_onUpdateQuranTime);
    on<UpdateAlKahfTime>(_onUpdateAlKahfTime);
    on<SaveRemindersSettings>(_onSaveRemindersSettings);
    on<ResetRemindersSettings>(_onResetRemindersSettings);
  }

    Future<void> _onLoadRemindersSettings(
    LoadRemindersSettings event,
    Emitter<RemindersNotificationsState> emit,
  ) async {
    emit(RemindersNotificationsLoading());
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final state = RemindersNotificationsLoaded(
        islamicCalendarNotifications: prefs.getBool('islamic_calendar_notifications') ?? true,
        tasbihDailyReminder: prefs.getBool('tasbih_daily_reminder') ?? true,
        dailyDuaPopup: prefs.getBool('daily_dua_popup') ?? true,
        quranDailyReminder: prefs.getBool('quran_daily_reminder') ?? true,
        readAlKahfFriday: prefs.getBool('read_al_kahf_friday') ?? true,
        tasbihTime: prefs.getString('tasbih_time') ?? '12:00 PM',
        dailyDuaTime: prefs.getString('daily_dua_time') ?? '12:00 PM',
        quranTime: prefs.getString('quran_time') ?? '12:00 PM',
        alKahfTime: prefs.getString('al_kahf_time') ?? '12:00 PM',
      );
      
      emit(state);
      
      // Schedule all active reminders
      await _scheduleAllActiveReminders(state);
      
    } catch (e) {
      emit(RemindersNotificationsError('Failed to load settings: $e'));
    }
  }

  Future<void> _onToggleIslamicCalendarNotifications(
    ToggleIslamicCalendarNotifications event,
    Emitter<RemindersNotificationsState> emit,
  ) async {
    if (state is RemindersNotificationsLoaded) {
      final currentState = state as RemindersNotificationsLoaded;
      final newState = currentState.copyWith(
        islamicCalendarNotifications: event.enabled,
      );
      emit(newState);
      
      // Save to SharedPreferences immediately
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('islamic_calendar_notifications', event.enabled);
      
      // Schedule or cancel notifications based on toggle
      await _scheduleIslamicCalendarNotifications(event.enabled);
    }
  }

  Future<void> _onToggleTasbihDailyReminder(
    ToggleTasbihDailyReminder event,
    Emitter<RemindersNotificationsState> emit,
  ) async {
    print('🔄 Toggling tasbih daily reminder: ${event.enabled}');
    if (state is RemindersNotificationsLoaded) {
      final currentState = state as RemindersNotificationsLoaded;
      final newState = currentState.copyWith(
        tasbihDailyReminder: event.enabled,
        tasbihTime: event.time ?? currentState.tasbihTime,
      );
      emit(newState);
      
      // Save to SharedPreferences immediately
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tasbih_daily_reminder', event.enabled);
      print('💾 Saved tasbih_daily_reminder: ${event.enabled}');
      
      if (event.time != null) {
        await prefs.setString('tasbih_time', event.time!);
        print('💾 Saved tasbih_time: ${event.time!}');
      }
      
      if (event.enabled) {
        print('⏰ Scheduling tasbih reminder...');
        await _scheduleTasbihReminder(event.time ?? currentState.tasbihTime);
      } else {
        print('🗑️ Cancelling tasbih reminder...');
        await _cancelTasbihReminder();
      }
    } else {
      print('❌ State is not RemindersNotificationsLoaded');
    }
  }

  Future<void> _onToggleDailyDuaPopup(
    ToggleDailyDuaPopup event,
    Emitter<RemindersNotificationsState> emit,
  ) async {
    if (state is RemindersNotificationsLoaded) {
      final currentState = state as RemindersNotificationsLoaded;
      final newState = currentState.copyWith(
        dailyDuaPopup: event.enabled,
        dailyDuaTime: event.time ?? currentState.dailyDuaTime,
      );
      emit(newState);
      
      // Save to SharedPreferences immediately
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('daily_dua_popup', event.enabled);
      if (event.time != null) {
        await prefs.setString('daily_dua_time', event.time!);
      }
      
      if (event.enabled) {
        await _scheduleDailyDuaPopup(event.time ?? currentState.dailyDuaTime);
      } else {
        await _cancelDailyDuaPopup();
      }
    }
  }

  Future<void> _onToggleQuranDailyReminder(
    ToggleQuranDailyReminder event,
    Emitter<RemindersNotificationsState> emit,
  ) async {
    if (state is RemindersNotificationsLoaded) {
      final currentState = state as RemindersNotificationsLoaded;
      final newState = currentState.copyWith(
        quranDailyReminder: event.enabled,
        quranTime: event.time ?? currentState.quranTime,
      );
      emit(newState);
      
      // Save to SharedPreferences immediately
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('quran_daily_reminder', event.enabled);
      if (event.time != null) {
        await prefs.setString('quran_time', event.time!);
      }
      
      if (event.enabled) {
        await _scheduleQuranReminder(event.time ?? currentState.quranTime);
      } else {
        await _cancelQuranReminder();
      }
    }
  }

  Future<void> _onToggleAlKahfFridayReminder(
    ToggleAlKahfFridayReminder event,
    Emitter<RemindersNotificationsState> emit,
  ) async {
    if (state is RemindersNotificationsLoaded) {
      final currentState = state as RemindersNotificationsLoaded;
      final newState = currentState.copyWith(
        readAlKahfFriday: event.enabled,
        alKahfTime: event.time ?? currentState.alKahfTime,
      );
      emit(newState);
      
      // Save to SharedPreferences immediately
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('read_al_kahf_friday', event.enabled);
      if (event.time != null) {
        await prefs.setString('al_kahf_time', event.time!);
      }
      
      if (event.enabled) {
        await _scheduleAlKahfReminder(event.time ?? currentState.alKahfTime);
      } else {
        await _cancelAlKahfReminder();
      }
    }
  }

  Future<void> _onUpdateTasbihTime(
    UpdateTasbihTime event,
    Emitter<RemindersNotificationsState> emit,
  ) async {
    print('🔄 Updating tasbih time to: ${event.time}');
    if (state is RemindersNotificationsLoaded) {
      final currentState = state as RemindersNotificationsLoaded;
      final newState = currentState.copyWith(tasbihTime: event.time);
      emit(newState);
      
      // Save to SharedPreferences immediately
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tasbih_time', event.time);
      print('💾 Saved tasbih_time: ${event.time}');
      
      if (currentState.tasbihDailyReminder) {
        print('⏰ Rescheduling tasbih reminder with new time...');
        await _scheduleTasbihReminder(event.time);
      } else {
        print('⚠️ Tasbih reminder is disabled, not rescheduling');
      }
    } else {
      print('❌ State is not RemindersNotificationsLoaded');
    }
  }

  Future<void> _onUpdateDailyDuaTime(
    UpdateDailyDuaTime event,
    Emitter<RemindersNotificationsState> emit,
  ) async {
    if (state is RemindersNotificationsLoaded) {
      final currentState = state as RemindersNotificationsLoaded;
      final newState = currentState.copyWith(dailyDuaTime: event.time);
      emit(newState);
      
      // Save to SharedPreferences immediately
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('daily_dua_time', event.time);
      
      if (currentState.dailyDuaPopup) {
        await _scheduleDailyDuaPopup(event.time);
      }
    }
  }

  Future<void> _onUpdateQuranTime(
    UpdateQuranTime event,
    Emitter<RemindersNotificationsState> emit,
  ) async {
    if (state is RemindersNotificationsLoaded) {
      final currentState = state as RemindersNotificationsLoaded;
      final newState = currentState.copyWith(quranTime: event.time);
      emit(newState);
      
      // Save to SharedPreferences immediately
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('quran_time', event.time);
      
      if (currentState.quranDailyReminder) {
        await _scheduleQuranReminder(event.time);
      }
    }
  }

  Future<void> _onUpdateAlKahfTime(
    UpdateAlKahfTime event,
    Emitter<RemindersNotificationsState> emit,
  ) async {
    if (state is RemindersNotificationsLoaded) {
      final currentState = state as RemindersNotificationsLoaded;
      final newState = currentState.copyWith(alKahfTime: event.time);
      emit(newState);
      
      // Save to SharedPreferences immediately
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('al_kahf_time', event.time);
      
      if (currentState.readAlKahfFriday) {
        await _scheduleAlKahfReminder(event.time);
      }
    }
  }

  Future<void> _onSaveRemindersSettings(
    SaveRemindersSettings event,
    Emitter<RemindersNotificationsState> emit,
  ) async {
    if (state is RemindersNotificationsLoaded) {
      final currentState = state as RemindersNotificationsLoaded;
      emit(currentState.copyWith(isSaving: true, error: null, successMessage: null));
      
      try {
        final prefs = await SharedPreferences.getInstance();
        
        await prefs.setBool('islamic_calendar_notifications', currentState.islamicCalendarNotifications);
        await prefs.setBool('tasbih_daily_reminder', currentState.tasbihDailyReminder);
        await prefs.setBool('daily_dua_popup', currentState.dailyDuaPopup);
        await prefs.setBool('quran_daily_reminder', currentState.quranDailyReminder);
        await prefs.setBool('read_al_kahf_friday', currentState.readAlKahfFriday);
        await prefs.setString('tasbih_time', currentState.tasbihTime);
        await prefs.setString('daily_dua_time', currentState.dailyDuaTime);
        await prefs.setString('quran_time', currentState.quranTime);
        await prefs.setString('al_kahf_time', currentState.alKahfTime);
        
        emit(currentState.copyWith(
          isSaving: false,
          successMessage: 'Settings saved successfully!',
        ));
        
        // Clear success message after 3 seconds
        Timer(const Duration(seconds: 3), () {
          if (state is RemindersNotificationsLoaded) {
            final currentState = state as RemindersNotificationsLoaded;
            emit(currentState.copyWith(successMessage: null));
          }
        });
        
      } catch (e) {
        emit(currentState.copyWith(
          isSaving: false,
          error: 'Failed to save settings: $e',
        ));
      }
    }
  }

  Future<void> _onResetRemindersSettings(
    ResetRemindersSettings event,
    Emitter<RemindersNotificationsState> emit,
  ) async {
    emit(RemindersNotificationsLoading());
    
    try {
      // Cancel all scheduled reminders
      await _cancelAllReminders();
      
      // Reset to default values
      final defaultState = RemindersNotificationsLoaded();
      emit(defaultState);
      
             // Save default values
       final prefs = await SharedPreferences.getInstance();
       await prefs.setBool('islamic_calendar_notifications', true);
       await prefs.setBool('tasbih_daily_reminder', true);
       await prefs.setBool('daily_dua_popup', true);
       await prefs.setBool('quran_daily_reminder', true);
       await prefs.setBool('read_al_kahf_friday', true);
       await prefs.setString('tasbih_time', '12:00 PM');
       await prefs.setString('daily_dua_time', '12:00 PM');
       await prefs.setString('quran_time', '12:00 PM');
       await prefs.setString('al_kahf_time', '12:00 PM');
      
    } catch (e) {
      emit(RemindersNotificationsError('Failed to reset settings: $e'));
    }
  }

  // WorkManager scheduling methods
  Future<void> _scheduleIslamicCalendarNotifications(bool enabled) async {
    try {
      if (enabled) {
        // Schedule Islamic calendar notifications
        await Workmanager().registerPeriodicTask(
          'islamic_calendar_notifications',
          'islamicCalendarNotifications',
          frequency: const Duration(days: 1),
          constraints: Constraints(
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
        );
        print('✅ Islamic calendar notifications scheduled');
      } else {
        // Cancel Islamic calendar notifications
        await Workmanager().cancelByUniqueName('islamic_calendar_notifications');
        print('❌ Islamic calendar notifications cancelled');
      }
    } catch (e) {
      print('Error scheduling Islamic calendar notifications: $e');
    }
  }

  Future<void> _scheduleTasbihReminder(String time, [int retryCount = 0]) async {
    print('🔄 Scheduling tasbih reminder for time: $time (retry: $retryCount)');
    
    // Prevent infinite recursion
    if (retryCount >= 3) {
      print('❌ Max retry attempts reached for tasbih reminder scheduling');
      return;
    }
    
    try {
      final timeOfDay = _parseTimeString(time);
      print('⏰ Parsed time: $timeOfDay');
      
      if (timeOfDay != null) {
        // Cancel existing task first
        await Workmanager().cancelByUniqueName('tasbih_daily_reminder');
        print('🗑️ Cancelled existing tasbih task');
        
        final delay = _calculateInitialDelay(timeOfDay);
        print('⏱️ Calculated delay: ${delay.inMinutes} minutes (${delay.inHours} hours)');
        
        print('📝 Registering one-off task with:');
        print('   - Unique name: tasbih_daily_reminder');
        print('   - Task name: tasbihDailyReminder');
        print('   - Initial delay: ${delay.inMinutes} minutes');
        print('   - Input data: {time: $time}');
        
        // Ensure WorkManager is initialized before proceeding
        if (retryCount == 0) {
          print('🔧 Ensuring WorkManager is initialized...');
          try {
            final workManagerService = WorkManagerNotificationService();
            await workManagerService.initializeWorkManager();
            await Future.delayed(const Duration(milliseconds: 500));
          } catch (initError) {
            print('⚠️ WorkManager initialization check failed: $initError');
          }
        }
        
        // Add a longer delay to ensure WorkManager is ready
        await Future.delayed(const Duration(milliseconds: 500));
        
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
        print('✅ Tasbih reminder scheduled for $time with delay: ${delay.inMinutes} minutes');
      } else {
        print('❌ Failed to parse time: $time');
      }
    } catch (e) {
      print('❌ Error scheduling tasbih reminder: $e');
      print('❌ Error stack trace: ${StackTrace.current}');
      
      // If WorkManager fails, try to reinitialize it
      if (e.toString().contains('not properly initialized')) {
        print('🔄 Attempting to reinitialize WorkManager... (attempt ${retryCount + 1})');
        try {
          final workManagerService = WorkManagerNotificationService();
          await workManagerService.initializeWorkManager();
          await Future.delayed(const Duration(milliseconds: 1000));
          
          // Retry scheduling with incremented retry count
          await _scheduleTasbihReminder(time, retryCount + 1);
        } catch (retryError) {
          print('❌ Failed to reinitialize WorkManager: $retryError');
        }
      }
    }
  }

  Future<void> _cancelTasbihReminder() async {
    await Workmanager().cancelByUniqueName('tasbih_daily_reminder');
  }

  Future<void> _scheduleDailyDuaPopup(String time) async {
    try {
      final timeOfDay = _parseTimeString(time);
      if (timeOfDay != null) {
        // Cancel existing task first
        await Workmanager().cancelByUniqueName('daily_dua_popup');
        
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
        print('✅ Daily dua popup scheduled for $time with delay: ${delay.inMinutes} minutes');
      }
    } catch (e) {
      print('Error scheduling daily dua popup: $e');
    }
  }

  Future<void> _cancelDailyDuaPopup() async {
    await Workmanager().cancelByUniqueName('daily_dua_popup');
  }

  Future<void> _scheduleQuranReminder(String time) async {
    try {
      final timeOfDay = _parseTimeString(time);
      if (timeOfDay != null) {
        // Cancel existing task first
        await Workmanager().cancelByUniqueName('quran_daily_reminder');
        
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
        print('✅ Quran reminder scheduled for $time with delay: ${delay.inMinutes} minutes');
      }
    } catch (e) {
      print('Error scheduling Quran reminder: $e');
    }
  }

  Future<void> _cancelQuranReminder() async {
    await Workmanager().cancelByUniqueName('quran_daily_reminder');
  }

  Future<void> _scheduleAlKahfReminder(String time) async {
    try {
      final timeOfDay = _parseTimeString(time);
      if (timeOfDay != null) {
        // Cancel existing task first
        await Workmanager().cancelByUniqueName('al_kahf_friday_reminder');
        
        // Calculate delay to next Friday at the specified time
        final delayToNextFriday = _calculateDelayToNextFriday(timeOfDay);
        
        await Workmanager().registerOneOffTask(
          'al_kahf_friday_reminder',
          'alKahfFridayReminder',
          initialDelay: delayToNextFriday,
          constraints: Constraints(
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
          inputData: {'time': time},
        );
        print('✅ Al-Kahf Friday reminder scheduled for $time with delay: ${delayToNextFriday.inMinutes} minutes');
      }
    } catch (e) {
      print('Error scheduling Al-Kahf Friday reminder: $e');
    }
  }

  Future<void> _cancelAlKahfReminder() async {
    await Workmanager().cancelByUniqueName('al_kahf_friday_reminder');
  }

  Future<void> _cancelAllReminders() async {
    await Workmanager().cancelByUniqueName('islamic_calendar_notifications');
    await Workmanager().cancelByUniqueName('tasbih_daily_reminder');
    await Workmanager().cancelByUniqueName('daily_dua_popup');
    await Workmanager().cancelByUniqueName('quran_daily_reminder');
    await Workmanager().cancelByUniqueName('al_kahf_friday_reminder');
  }

  // Helper methods
  DateTime? _parseTimeString(String timeString) {
    print('🕐 Parsing time string: $timeString');
    try {
      final parts = timeString.split(' ');
      final timeParts = parts[0].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final isPM = parts[1] == 'PM';
      
      print('📊 Parsed components - Hour: $hour, Minute: $minute, isPM: $isPM');
      
      int adjustedHour = hour;
      if (isPM && hour != 12) adjustedHour += 12;
      if (!isPM && hour == 12) adjustedHour = 0;
      
      print('🕐 Adjusted hour: $adjustedHour');
      
      final now = DateTime.now();
      final result = DateTime(now.year, now.month, now.day, adjustedHour, minute);
      print('📅 Final parsed time: $result');
      return result;
    } catch (e) {
      print('❌ Error parsing time string: $e');
      return null;
    }
  }

  Duration _calculateInitialDelay(DateTime targetTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetToday = DateTime(today.year, today.month, today.day, targetTime.hour, targetTime.minute);
    
    print('🕐 Current time: $now');
    print('📅 Target time today: $targetToday');
    
    Duration delay = targetToday.difference(now);
    print('⏱️ Initial delay: ${delay.inMinutes} minutes');
    
    // If the time has already passed today, schedule for tomorrow
    if (delay.isNegative) {
      delay = delay + const Duration(days: 1);
      print('⏰ Time already passed today, scheduling for tomorrow. New delay: ${delay.inMinutes} minutes');
    }
    
    print('✅ Final delay: ${delay.inMinutes} minutes (${delay.inHours} hours)');
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
    
    final nextFriday = DateTime(now.year, now.month, now.day + daysUntilFriday, targetTime.hour, targetTime.minute);
    return nextFriday.difference(now);
  }

  Future<void> _scheduleAllActiveReminders(RemindersNotificationsLoaded state) async {
    try {
      print('🔄 Scheduling all active reminders...');
      
      if (state.islamicCalendarNotifications) {
        await _scheduleIslamicCalendarNotifications(true);
      }
      
      if (state.tasbihDailyReminder) {
        await _scheduleTasbihReminder(state.tasbihTime);
      }
      
      if (state.dailyDuaPopup) {
        await _scheduleDailyDuaPopup(state.dailyDuaTime);
      }
      
      if (state.quranDailyReminder) {
        await _scheduleQuranReminder(state.quranTime);
      }
      
      if (state.readAlKahfFriday) {
        await _scheduleAlKahfReminder(state.alKahfTime);
      }
      
      print('✅ All active reminders scheduled');
    } catch (e) {
      print('❌ Error scheduling active reminders: $e');
    }
  }


}
