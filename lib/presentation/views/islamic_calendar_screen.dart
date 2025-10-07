import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_linear_datepicker/flutter_datepicker.dart';

import '../../constants/colors.dart';
import '../../data/bloc/islamic_calendar/islamic_calendar_bloc.dart';
import '../../data/bloc/islamic_calendar/islamic_calendar_event.dart';
import '../../data/bloc/islamic_calendar/islamic_calendar_state.dart';
import '../widgets/custom_toast_widget.dart';

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});

  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Colors.grey[900] 
          : Colors.white,
      body: BlocProvider(
        create: (context) => IslamicCalendarBloc(),
        child: BlocConsumer<IslamicCalendarBloc, IslamicCalendarState>(
          listener: (context, state) {
            if (state is IslamicCalendarError) {
              CustomToastWidget.show(
                context: context,
                title: state.message,
                iconPath: 'assets/images/error_icon.png',
                iconBackgroundColor: AppColors.colorError,
                backgroundColor: AppColors.colorError.withOpacity(0.1),
              );
            }
          },
          builder: (context, state) {
            if (state is IslamicCalendarLoading) {
              return const SafeArea(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (state is IslamicCalendarLoaded) {
              return SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, state),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildCalendarGrid(context, state),
                            _buildHolidaysSection(context, state),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return const SafeArea(
              child: Center(
                child: Text('No data available'),
              ),
            );
          },
        ),
      ),
    );
  }

    Widget _buildHeader(BuildContext context, IslamicCalendarLoaded state) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey[850] 
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : AppColors.colorBlackHighEmp,
              size: 24.sp,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _showCustomDatePicker(context, state, context.read<IslamicCalendarBloc>()),
                  child: Row(

                    children: [
                      Text(
                        state.selectedDate != null 
                            ? DateFormat('MMMM yyyy').format(state.selectedDate!)
                            : 'May 2025',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : AppColors.colorBlackHighEmp,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.black,
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
                if (state.selectedDate != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    _getHijriMonthYear(state.selectedDate!),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[400] 
                          : AppColors.colorGrayEmp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.read<IslamicCalendarBloc>().add(const ToggleHijriView());
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.colorGrayEmp.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/images/convert.svg',
                        width: 16.w,
                        height: 16.h,
                        colorFilter: const ColorFilter.mode(AppColors.colorPrimary, BlendMode.srcIn),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Hijri',
                        style: TextStyle(
                          color: AppColors.colorPrimary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Stack(
                children: [
                  SvgPicture.asset(
                    'assets/images/calender.svg',
                    width: 24.w,
                    height: 24.h,
                  ),
                  Positioned.fill(
                    top: 6.h,
                    child: Center(
                      child: Text(
                        DateTime.now().day.toString(),
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

    Widget _buildCalendarGrid(BuildContext context, IslamicCalendarLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Days of week header - dynamically ordered based on first day of month
          Row(
            children: _getDayNames(state.selectedDate)
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                                                 style: TextStyle(
                           fontSize: 12.sp,
                           fontWeight: FontWeight.w600,
                           color: Theme.of(context).brightness == Brightness.dark 
                               ? Colors.grey[300] 
                               : AppColors.colorBlackMidEmp,
                         ),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 8.h),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4.w,
              mainAxisSpacing: 4.h,
            ),
            itemCount: state.calendarDays.length,
            itemBuilder: (context, index) {
              final day = state.calendarDays[index];
              return _buildCalendarDay(context, day, state);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(BuildContext context, CalendarDay day, IslamicCalendarLoaded state) {
    Color backgroundColor = Colors.transparent;
    Color textColor = AppColors.colorBlackLowEmp;
    Color hijriTextColor = AppColors.colorGrayEmp;
    Color borderColor = Colors.transparent;

    if (day.isSelected) {
      backgroundColor = AppColors.colorPrimary;
      textColor = Colors.white;
      hijriTextColor = Colors.white;
      borderColor = AppColors.colorPrimary;
    } else if (day.isToday) {
      backgroundColor = AppColors.colorPrimary.withOpacity(0.1);
      textColor = AppColors.colorPrimary;
      borderColor = AppColors.colorPrimary;
    } else if (day.isCurrentMonth) {
      textColor = AppColors.colorBlackHighEmp;
    }

    return GestureDetector(
      onTap: () {
        if (day.isCurrentMonth) {
          context.read<IslamicCalendarBloc>().add(LoadCalendarData(selectedDate: day.gregorianDate));
        }
      },
             child: Container(
         decoration: BoxDecoration(
           color: day.isSelected ? AppColors.colorPrimary : backgroundColor,
           shape: (day.isSelected || day.isToday) ? BoxShape.circle : BoxShape.rectangle,
           borderRadius: (day.isSelected || day.isToday) ? null : BorderRadius.circular(8.r),
          
         ),
        child: Stack(
          children: [
                         Center(
               child: day.isCurrentMonth 
                 ? AnimatedSwitcher(
                     duration: const Duration(milliseconds: 300),
                     transitionBuilder: (Widget child, Animation<double> animation) {
                       return SlideTransition(
                         position: Tween<Offset>(
                           begin: const Offset(0, 0.5),
                           end: Offset.zero,
                         ).animate(CurvedAnimation(
                           parent: animation,
                           curve: Curves.easeInOut,
                         )),
                         child: FadeTransition(
                           opacity: animation,
                           child: child,
                         ),
                       );
                     },
                     child: state.isHijriView
                       ? Column(
                           key: const ValueKey('hijri_first'),
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text(
                               day.hijriDate.hDay.toString(),
                               style: TextStyle(
                                 fontSize: 14.sp,
                                 fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w600,
                                 color: textColor,
                               ),
                             ),
                             Text(
                               day.gregorianDate.day.toString(),
                               style: TextStyle(
                                 fontSize: 10.sp,
                                 color: hijriTextColor,
                                 fontWeight: day.isToday ? FontWeight.w600 : FontWeight.normal,
                               ),
                             ),
                           ],
                         )
                       : Column(
                           key: const ValueKey('gregorian_first'),
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text(
                               day.gregorianDate.day.toString(),
                               style: TextStyle(
                                 fontSize: 14.sp,
                                 fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w600,
                                 color: textColor,
                               ),
                             ),
                             Text(
                               day.hijriDate.hDay.toString(),
                               style: TextStyle(
                                 fontSize: 10.sp,
                                 color: hijriTextColor,
                                 fontWeight: day.isToday ? FontWeight.w600 : FontWeight.normal,
                               ),
                             ),
                           ],
                         ),
                   )
                 : const SizedBox.shrink(), // Empty space for non-current month days
             ),
            if (day.hasHoliday && !day.isToday)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 6.w,
                  height: 6.h,
                  decoration: const BoxDecoration(
                    color: AppColors.colorPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
                         if (day.isToday)
               Positioned(
                 top: 2,
                 right: 2,
                 child: Container(
                   width: 10.w,
                   height: 10.h,
                   decoration: const BoxDecoration(
                     color: AppColors.colorPrimary,
                     shape: BoxShape.circle,
                   ),
                 ),
               ),
          ],
        ),
      ),
    );
  }

  Widget _buildHolidaysSection(BuildContext context, IslamicCalendarLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Islamic Holidays',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : AppColors.colorBlackHighEmp,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[900] 
                : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: state.holidays.asMap().entries.map((entry) {
              final index = entry.key;
              final holiday = entry.value;
              return Column(
                children: [
                  _buildHolidayItem(context, holiday),
                  if (index < state.holidays.length - 1)
                    Divider(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[700] 
                          : Colors.grey[300],
                      height: 16.h,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHolidayItem(BuildContext context, IslamicHoliday holiday) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                holiday.name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.colorBlackHighEmp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                holiday.hijriDate,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[500]
                      : AppColors.colorGrayEmp,
                ),
              ),

            ],
          ),
          Text(
            DateFormat('dd MMM yyyy').format(holiday.gregorianDate),
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : AppColors.colorGrayEmp,
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<IslamicCalendarBloc>().add(
                ToggleHolidayNotification(
                  holidayId: holiday.id,
                  isEnabled: !holiday.notificationsEnabled,
                ),
              );
            },
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: _getNotificationColor(holiday.notificationStatus),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  _getNotificationIconAsset(holiday.notificationStatus),
                  width: 16.w,
                  height: 16.h,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  void _showCustomDatePicker(BuildContext context, IslamicCalendarLoaded state, IslamicCalendarBloc bloc) {
    DateTime selectedDate = state.selectedDate ?? DateTime.now();
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 300.h,
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Month & Year',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color ?? AppColors.colorBlackHighEmp,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.close,
                        size: 24.sp,
                        color: theme.textTheme.titleMedium?.color ?? AppColors.colorBlackHighEmp,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Date Picker
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: LinearDatePicker(
                    startDate: DateTime.now().subtract(const Duration(days: 365)),
                    endDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: selectedDate,
                    dateChangeListener: (date) {
                      selectedDate = date;
                    },
                    showDay: false, // Hide the day column
                    labelStyle: TextStyle(
                      color: theme.textTheme.titleMedium?.color ?? AppColors.colorBlackHighEmp,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    selectedRowStyle: TextStyle(
                      color: theme.textTheme.titleMedium?.color ?? AppColors.colorBlackHighEmp,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedRowStyle: TextStyle(
                      color: theme.textTheme.bodySmall?.color ?? AppColors.colorBlackLowEmp,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.normal,
                    ),
                    yearLabel: "Year",
                    monthLabel: "Month", 
                    dayLabel: "Day",
                    showLabels: false,
                    columnWidth: 100.w,
                    isJalali: false,
                    showMonthName: true,
                    monthsNames: [
                      'January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November', 'December'
                    ],
                  ),
                ),
              ),
              
              // Confirm Button
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                child: ElevatedButton(
                  onPressed: () {
                    bloc.add(ChangeMonth(newDate: selectedDate));
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getHijriMonthYear(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final monthNames = [
      'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
      'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha\'ban',
      'Ramadan', 'Shawwal', 'Dhu al-Qadah', 'Dhu al-Hijjah'
    ];
    
    final currentMonth = monthNames[hijri.hMonth - 1];
    final nextMonth = monthNames[hijri.hMonth % 12];
    final year = hijri.hYear;
    
    return '$currentMonth-$nextMonth, $year';
  }

  Color _getNotificationColor(String status) {
    switch (status) {
      case 'on':
        return AppColors.colorSuccess;
      case 'off':
        return AppColors.colorError;
      case 'snooze':
        return AppColors.colorGrayEmp;
      default:
        return AppColors.colorGrayEmp;
    }
  }

  IconData _getNotificationIcon(String status) {
    switch (status) {
      case 'on':
        return Icons.volume_up;
      case 'off':
        return Icons.volume_off;
      case 'snooze':
        return Icons.pause;
      default:
        return Icons.volume_up;
    }
  }

  String _getNotificationIconAsset(String status) {
    switch (status) {
      case 'on':
        return 'assets/images/sound.svg';
      case 'off':
        return 'assets/images/no-sound.svg';
      case 'snooze':
        return 'assets/images/vibration.svg';
      default:
        return 'assets/images/sound.svg';
    }
  }

  List<String> _getDayNames(DateTime? selectedDate) {
    if (selectedDate == null) {
      return ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    }
    
    final DateTime firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday; // Monday=1, Tuesday=2, ..., Sunday=7
    
    // Convert to Sunday-based week (Sunday=0, Monday=1, ..., Saturday=6)
    final int sundayBasedWeekday = firstWeekday == 7 ? 0 : firstWeekday;
    
    final List<String> allDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    
    // Reorder the days so that the first day of the month appears first
    final List<String> reorderedDays = [];
    for (int i = 0; i < 7; i++) {
      final index = (sundayBasedWeekday + i) % 7;
      reorderedDays.add(allDays[index]);
    }
    
    return reorderedDays;
  }
}
