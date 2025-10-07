import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../constants/images.dart';
import '../../../data/bloc/reminders_notifications/reminders_notifications_bloc.dart';
import '../../../data/bloc/reminders_notifications/reminders_notifications_event.dart';
import '../../../data/bloc/reminders_notifications/reminders_notifications_state.dart';
import '../../widgets/custom_time_picker_bottom_sheet.dart';

class RemindersNotificationsScreen extends StatelessWidget {
  const RemindersNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RemindersNotificationsBloc()..add(LoadRemindersSettings()),
      child: const RemindersNotificationsView(      ),
    );
  }


}

class RemindersNotificationsView extends StatefulWidget {
  const RemindersNotificationsView({super.key});

  @override
  State<RemindersNotificationsView> createState() => _RemindersNotificationsViewState();
}

class _RemindersNotificationsViewState extends State<RemindersNotificationsView> {

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  TimeOfDay _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(' ');
      final timeParts = parts[0].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final isPM = parts[1] == 'PM';
      
      int adjustedHour = hour;
      if (isPM && hour != 12) adjustedHour += 12;
      if (!isPM && hour == 12) adjustedHour = 0;
      
      return TimeOfDay(hour: adjustedHour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 14, minute: 30);
    }
  }

  void _showTimePicker(String title, String currentTime, Function(String) onTimeSet) {
    print('🕐 Showing time picker for: $title');
    print('⏰ Current time: $currentTime');
    
    final timeOfDay = _parseTimeString(currentTime);
    print('📅 Parsed time: $timeOfDay');
    
    CustomTimePickerBottomSheet.show(
      context: context,
      title: title,
      initialTime: timeOfDay,
      onTimeSet: (time) {
        final formattedTime = _formatTime(time);
        print('✅ Time selected: $formattedTime');
        onTimeSet(formattedTime);
      },
    );
  }

  void _handleDailyDuaToggle(BuildContext context, bool value) {
    final bloc = context.read<RemindersNotificationsBloc>();
    final currentState = bloc.state;
    
    if (currentState is RemindersNotificationsLoaded) {
      bloc.add(ToggleDailyDuaPopup(value, time: currentState.dailyDuaTime));
      
      if (value) {
        // If turning on, show time picker with current time
        _showTimePicker(
          'Set Daily Dua Pop-up Time',
          currentState.dailyDuaTime,
          (time) {
            bloc.add(UpdateDailyDuaTime(time));
          },
        );
      }
    }
  }

  void _handleTasbihToggle(BuildContext context, bool value) {
    print('🔄 Handling tasbih toggle: $value');
    final bloc = context.read<RemindersNotificationsBloc>();
    final currentState = bloc.state;
    
    if (currentState is RemindersNotificationsLoaded) {
      print('⏰ Current tasbih time: ${currentState.tasbihTime}');
      bloc.add(ToggleTasbihDailyReminder(value, time: currentState.tasbihTime));
      
      if (value) {
        // If turning on, show time picker with current time
        _showTimePicker(
          'Set Tasbih Daily Reminder',
          currentState.tasbihTime,
          (time) {
            print('🔄 Updating tasbih time to: $time');
            bloc.add(UpdateTasbihTime(time));
          },
        );
      }
    } else {
      print('❌ State is not RemindersNotificationsLoaded');
    }
  }

  void _handleQuranToggle(BuildContext context, bool value) {
    final bloc = context.read<RemindersNotificationsBloc>();
    final currentState = bloc.state;
    
    if (currentState is RemindersNotificationsLoaded) {
      bloc.add(ToggleQuranDailyReminder(value, time: currentState.quranTime));
      
      if (value) {
        // If turning on, show time picker with current time
        _showTimePicker(
          'Set Quran Daily Reminder',
          currentState.quranTime,
          (time) {
            bloc.add(UpdateQuranTime(time));
          },
        );
      }
    }
  }

  void _handleAlKahfToggle(BuildContext context, bool value) {
    final bloc = context.read<RemindersNotificationsBloc>();
    final currentState = bloc.state;
    
    if (currentState is RemindersNotificationsLoaded) {
      bloc.add(ToggleAlKahfFridayReminder(value, time: currentState.alKahfTime));
      
      if (value) {
        // If turning on, show time picker with current time
        _showTimePicker(
          'Set Al-Kahf Friday Reminder',
          currentState.alKahfTime,
          (time) {
            bloc.add(UpdateAlKahfTime(time));
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Reminders & Notifications',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<RemindersNotificationsBloc, RemindersNotificationsState>(
        builder: (context, state) {
          if (state is RemindersNotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is RemindersNotificationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading settings',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          if (state is RemindersNotificationsLoaded) {
            return Padding(
              padding: EdgeInsets.only(top: 60.h, left: 16.w, right: 16.w),
              child: Column(
                children: [
                  _buildNavigationOptionsCard(theme, state),
                  SizedBox(height: 16.h),
                  _buildNotificationOptionsCard(theme, state),
                  if (state.successMessage != null)
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Text(
                          state.successMessage!,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  if (state.error != null)
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          state.error!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
          
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildNavigationOptionsCard(ThemeData theme, RemindersNotificationsLoaded state) {
    return Container(
      width: 328.w,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFEAEAEA), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Prayer Notifications - with forward arrow
          _buildNavigationOption(
            title: 'Prayer Notifications',
            subtitle: 'Fajr, Sunrise, Dhuhur...etc',
            onTap: () {
              // TODO: Navigate to Prayer Notifications settings
              print('Prayer Notifications tapped');
            },
          ),
          
          Divider(height: 1, color: theme.dividerTheme.color ?? const Color(0xFFEAEAEA)),
          
          // Islamic Calendar Notifications - with toggle
          _buildNotificationOption(
            title: 'Islamic Calendar Notifications',
            subtitle: null,
            value: state.islamicCalendarNotifications,
            onChanged: (value) {
              context.read<RemindersNotificationsBloc>().add(ToggleIslamicCalendarNotifications(value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOptionsCard(ThemeData theme, RemindersNotificationsLoaded state) {
    return Container(
      width: 328.w,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFEAEAEA), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tasbih Daily Reminder
          _buildNotificationOption(
            title: 'Tasbih Daily Reminder',
            subtitle: state.tasbihDailyReminder ? state.tasbihTime : null,
            value: state.tasbihDailyReminder,
            onChanged: (value) => _handleTasbihToggle(context, value),
            onTap: state.tasbihDailyReminder ? () {
              _showTimePicker(
                'Set Tasbih Daily Reminder',
                state.tasbihTime,
                (time) {
                  context.read<RemindersNotificationsBloc>().add(UpdateTasbihTime(time));
                },
              );
            } : null,
          ),
          
          Divider(height: 1, color: theme.dividerTheme.color ?? const Color(0xFFEAEAEA)),
          
          // Daily Dua Pop-up
          _buildNotificationOption(
            title: 'Daily Dua Pop-up',
            subtitle: state.dailyDuaPopup ? state.dailyDuaTime : null,
            value: state.dailyDuaPopup,
            onChanged: (value) => _handleDailyDuaToggle(context, value),
            onTap: state.dailyDuaPopup ? () {
              _showTimePicker(
                'Set Daily Dua Pop-up Time',
                state.dailyDuaTime,
                (time) {
                  context.read<RemindersNotificationsBloc>().add(UpdateDailyDuaTime(time));
                },
              );
            } : null,
          ),
          
          Divider(height: 1, color: theme.dividerTheme.color ?? const Color(0xFFEAEAEA)),
          
          // Quran Daily Reminder
          _buildNotificationOption(
            title: 'Quran Daily Reminder',
            subtitle: state.quranDailyReminder ? state.quranTime : null,
            value: state.quranDailyReminder,
            onChanged: (value) => _handleQuranToggle(context, value),
            onTap: state.quranDailyReminder ? () {
              _showTimePicker(
                'Set Quran Daily Reminder',
                state.quranTime,
                (time) {
                  context.read<RemindersNotificationsBloc>().add(UpdateQuranTime(time));
                },
              );
            } : null,
          ),
          
          Divider(height: 1, color: theme.dividerTheme.color ?? const Color(0xFFEAEAEA)),
          
          // Read Al-Kahf every Friday
          _buildNotificationOption(
            title: 'Read Al-Kahf every Friday',
            subtitle: state.readAlKahfFriday ? state.alKahfTime : null,
            value: state.readAlKahfFriday,
            onChanged: (value) => _handleAlKahfToggle(context, value),
            onTap: state.readAlKahfFriday ? () {
              _showTimePicker(
                'Set Al-Kahf Friday Reminder',
                state.alKahfTime,
                (time) {
                  context.read<RemindersNotificationsBloc>().add(UpdateAlKahfTime(time));
                },
              );
            } : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationOption({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: theme.textTheme.bodyMedium?.color ?? Colors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: theme.textTheme.bodySmall?.color ?? Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: theme.textTheme.bodySmall?.color ?? Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: theme.textTheme.bodyMedium?.color ?? Colors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: theme.textTheme.bodySmall?.color ?? Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF8D1B3D),
              activeTrackColor: const Color(0xFF8D1B3D).withOpacity(0.3),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }


}
