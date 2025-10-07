import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linear_datepicker/flutter_datepicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:ui' as ui;
import 'package:intl/intl.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts_weights.dart';
import '../../../constants/images.dart';
import '../../../data/bloc/prayer_times_bloc.dart';
import '../../../data/models/prayer_times_model.dart';
import '../../widgets/curved_timeline_widget.dart';
import 'prayer_bloc.dart';
import 'prayer_settings_screen.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PrayerBloc()..add(StartTimer()),
      child: const PrayerView(),
    );
  }
}

class PrayerView extends StatefulWidget {
  const PrayerView({super.key});

  @override
  State<PrayerView> createState() => _PrayerViewState();
}

class _PrayerViewState extends State<PrayerView> {
  @override
  void initState() {
    super.initState();
    // No need to load location and prayer times again - they're already loaded in home screen
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getCurrentPrayerBackground(PrayerLoaded state) {
    // Get current prayer based on real time
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    
    int currentPrayerIndex = 0;
    for (int i = 0; i < state.prayers.length; i++) {
      final prayer = state.prayers[i];
      final prayerTime = _parseTimeString(prayer['time']);
      
      if (currentTime.hour > prayerTime.hour || 
          (currentTime.hour == prayerTime.hour && currentTime.minute >= prayerTime.minute)) {
        currentPrayerIndex = i;
      } else {
        break;
      }
    }
    
    // If we've passed all prayers for today, start from the beginning
    if (currentPrayerIndex >= state.prayers.length) {
      currentPrayerIndex = 0;
    }

    final currentPrayer = state.prayers[currentPrayerIndex];
    return _getPrayerBackground(currentPrayer['name']);
  }

  List<StepperStep> _buildStepperSteps(PrayerLoaded state) {
    // Get current prayer index
    final currentPrayerIndex = _getCurrentPrayerIndex(state);

    return List.generate(state.prayers.length, (index) {
      final prayer = state.prayers[index];
      StepperState stepState;
      
      if (index < currentPrayerIndex) {
        stepState = StepperState.completed;
      } else if (index == currentPrayerIndex) {
        stepState = StepperState.current;
      } else {
        stepState = StepperState.upcoming;
      }

      return StepperStep(
        icon: _getPrayerIcon(prayer['name']),
        label: prayer['name'],
        time: prayer['time'],
        state: stepState,
      );
    });
  }

  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return AssetsPath.alfagrSVG;
      case 'sunrise':
        return AssetsPath.alsobhSVG;
      case 'dhuhur':
        return AssetsPath.alzohrSVG;
      case 'asr':
        return AssetsPath.la3srSVG;
      case 'maghrib':
        return AssetsPath.almaghribSVG;
      case 'isha':
        return AssetsPath.aleshaaSVG;
      default:
        return AssetsPath.aleshaaSVG;
    }
  }

  int _getCurrentPrayerIndex(PrayerLoaded state) {
    // Get current prayer based on time (real or test)
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    
    int currentPrayerIndex = 0;
    for (int i = 0; i < state.prayers.length; i++) {
      final prayer = state.prayers[i];
      final prayerTime = _parseTimeString(prayer['time']);
      
      if (currentTime.hour > prayerTime.hour || 
          (currentTime.hour == prayerTime.hour && currentTime.minute >= prayerTime.minute)) {
        currentPrayerIndex = i;
      } else {
        break;
      }
    }
    
    // If we've passed all prayers for today, start from the beginning
    if (currentPrayerIndex >= state.prayers.length) {
      currentPrayerIndex = 0;
    }

    return currentPrayerIndex;
  }

  String _getPrayerBackground(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return AssetsPath.fajrPNG;
      case 'sunrise':
        return AssetsPath.shruokPNG;
      case 'dhuhur':
        return AssetsPath.dhuhurPNG;
      case 'asr':
        return AssetsPath.asrPNG;
      case 'maghrib':
        return AssetsPath.magribPNG;
      case 'isha':
        return AssetsPath.ishaPNG;
      default:
        return AssetsPath.duaBackgroundPNG; // Default fallback
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
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.iconTheme.color,
            size: 24.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Prayer',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeights.semiBold,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              AssetsPath.quransettingsSVG,
              width: 24.sp,
              height: 24.sp,
                          colorFilter: ColorFilter.mode(
              theme.iconTheme.color ?? Colors.black,
              BlendMode.srcIn,
            ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PrayerSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<PrayerTimesBloc, PrayerTimesState>(
        listener: (context, prayerTimesState) {
          // Update PrayerBloc with real prayer times data
          if (prayerTimesState.prayerTimes.isNotEmpty) {
            final prayerBloc = context.read<PrayerBloc>();
            final todayPrayerTimes = prayerTimesState.prayerTimes.first;
            
            // Update prayers with real data
            final updatedPrayers = [
              {
                'name': 'Fajr',
                'icon': AssetsPath.alfagrSVG,
                'time': _formatTime(todayPrayerTimes.fajr),
                'notification': 'sound',
                'isCurrent': false,
              },
              {
                'name': 'Sunrise',
                'icon': AssetsPath.alsobhSVG,
                'time': _formatTime(todayPrayerTimes.sunrise),
                'notification': 'muted',
                'isCurrent': false,
              },
              {
                'name': 'Dhuhur',
                'icon': AssetsPath.alzohrSVG,
                'time': _formatTime(todayPrayerTimes.dhuhr),
                'notification': 'vibrate',
                'isCurrent': false,
              },
              {
                'name': 'Asr',
                'icon': AssetsPath.la3srSVG,
                'time': _formatTime(todayPrayerTimes.asr),
                'notification': 'sound',
                'isCurrent': true,
              },
              {
                'name': 'Maghrib',
                'icon': AssetsPath.almaghribSVG,
                'time': _formatTime(todayPrayerTimes.maghrib),
                'notification': 'sound',
                'isCurrent': false,
              },
              {
                'name': 'Isha',
                'icon': AssetsPath.aleshaaSVG,
                'time': _formatTime(todayPrayerTimes.isha),
                'notification': 'sound',
                'isCurrent': false,
              },
            ];
            
            // Update the PrayerBloc state with real data
            prayerBloc.add(UpdatePrayerTimes(updatedPrayers, prayerTimesState.locationName));
          }
        },
        child: BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
          builder: (context, prayerTimesState) {
            return BlocBuilder<PrayerBloc, PrayerState>(
              builder: (context, state) {
                if (state is PrayerInitial || state is PrayerLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is PrayerError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: AppColors.colorError,
                      ),
                    ),
                  );
                } else if (state is PrayerLoaded) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Content Area with Curved Timeline
                        _buildMainContentArea(context, state, prayerTimesState),
                        
                        // Prayer List
                        _buildPrayerList(context, state),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContentArea(BuildContext context, PrayerLoaded state, PrayerTimesState prayerTimesState) {
    // Get current prayer background
    final backgroundSvg = _getCurrentPrayerBackground(state);
    
    return SizedBox(
      height: 360.h,
      child: Stack(

        children: [
          // Dynamic Background with Animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Image.asset(
              backgroundSvg,
              key: ValueKey(backgroundSvg), // Important for AnimatedSwitcher
              fit: BoxFit.fitWidth,
              width: double.infinity,
              height: 320.h,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to gradient background if image fails to load
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFE5F0), // Light pink
                        Color(0xFFFFB3D1), // Darker pink
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Curved Timeline
          Positioned(
            // top: 40.h,
            left: 20.w,
            right: 20.w,
            child: CurvedTimelineWidget(
              steps: _buildStepperSteps(state),
              currentStep: _getCurrentPrayerIndex(state),
              onStepTapped: (index) {
                // Handle step selection if needed
              },
            ),
          ),

          // Current Prayer Info
          Positioned(
            top: 100.h,
            left: 20.w,
            right: 20.w,
            child: _buildCurrentPrayerInfo(context, state, prayerTimesState),
          ),

          // Date Selector - positioned at bottom to overlap
          _buildDateSelector(context, state),
        ],
      ),
    );
  }

  Widget _buildCurrentPrayerInfo(BuildContext context, PrayerLoaded state, PrayerTimesState prayerTimesState) {
    // Get current prayer index
    final currentPrayerIndex = _getCurrentPrayerIndex(state);
    final now = DateTime.now();

    final currentPrayer = state.prayers[currentPrayerIndex];
    final nextPrayerIndex = (currentPrayerIndex + 1) % state.prayers.length;
    final nextPrayer = state.prayers[nextPrayerIndex];
    
    // Calculate time remaining until next prayer
    final nextPrayerTime = _parseTimeString(nextPrayer['time']);
    final nextPrayerDateTime = DateTime(
      now.year, 
      now.month, 
      now.day, 
      nextPrayerTime.hour, 
      nextPrayerTime.minute,
    );
    
    // If next prayer is tomorrow, add a day
    final targetDateTime = nextPrayerDateTime.isBefore(now) 
        ? nextPrayerDateTime.add(const Duration(days: 1))
        : nextPrayerDateTime;
    
    final timeRemaining = targetDateTime.difference(now);
    
    // Determine text color based on current prayer
    final prayerName = currentPrayer['name'].toLowerCase();
    final isSpecialPrayer = prayerName == 'sunrise' || prayerName == 'dhuhur' || prayerName == 'asr';
    final prayerTextColor = isSpecialPrayer ? const Color(0xFF8D1B3D) : Colors.white;
    final secondaryTextColor = isSpecialPrayer ? const Color(0xFF151515) : Colors.white;
    
    // Get location from PrayerTimesBloc
    String locationName = 'Doha, Qatar'; // Default location
    
    // Try to get location from PrayerTimesBloc state
    if (prayerTimesState.locationName.isNotEmpty) {
      locationName = prayerTimesState.locationName;
    } else {
      // If not available in PrayerTimesBloc, try to get from the current state
      locationName = state.locationName.isNotEmpty ? state.locationName : 'Doha, Qatar';
    }
    
    return Column(
      children: [
        Text(
          'Now ${currentPrayer['name']}',
          style: GoogleFonts.poppins(
            fontSize: 28.sp,
            fontWeight: FontWeights.bold,
            color: prayerTextColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'pray within',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeights.medium,
            color: secondaryTextColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          _formatDuration(timeRemaining),
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 40.sp,
            fontWeight: FontWeight.w300,
            height: 52 / 40, // line-height / font-size
            letterSpacing: 0,
            color: secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              size: 16.sp,
              color: secondaryTextColor,
            ),
            SizedBox(width: 4.w),
            Text(
              _formatLocation(locationName),
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeights.medium,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    // Format as HH:MM:SS with zero padding
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatLocation(String locationName) {
    // Get current locale
    final locale = ui.window.locale;
    final isArabic = locale.languageCode == 'ar';
    
    // Handle empty or null location
    if (locationName.isEmpty || locationName == 'Loading location...' || locationName == 'null') {
      return isArabic ? 'قطر، الدوحة' : 'Doha, Qatar';
    }
    
    // Clean up the location string
    final cleanLocation = locationName.trim();
    
    final parts = cleanLocation.split(',');
    if (parts.length >= 2) {
      // Take the last part (country) and second to last part (city)
      final country = parts.last.trim();
      final city = parts[parts.length - 2].trim();
      
      // Return with appropriate punctuation based on language
      return isArabic ? '$country، $city' : '$country, $city';
    } else if (parts.length == 1) {
      return parts[0].trim();
    }
    return cleanLocation;
  }

  List<Map<String, dynamic>> _getPrayerTimesForDate(DateTime selectedDate, List<Map<String, dynamic>> basePrayers) {
    // Get prayer times from PrayerTimesBloc
    final prayerTimesState = context.read<PrayerTimesBloc>().state;
    
    // Find prayer times for the selected date
    PrayerTimesModel? selectedDatePrayerTimes;
    for (final prayerTime in prayerTimesState.prayerTimes) {
      if (prayerTime.date.year == selectedDate.year &&
          prayerTime.date.month == selectedDate.month &&
          prayerTime.date.day == selectedDate.day) {
        selectedDatePrayerTimes = prayerTime;
        break;
      }
    }
    
    // If we don't have prayer times for the selected date, use base prayers
    if (selectedDatePrayerTimes == null) {
      return basePrayers;
    }
    
    // Create prayer list with real data for the selected date
    final now = DateTime.now();
    final isSelectedDateToday = selectedDate.year == now.year && 
                               selectedDate.month == now.month && 
                               selectedDate.day == now.day;
    
    // Create list of prayer times for current prayer detection
    final prayerTimesList = [
      {'name': 'Fajr', 'time': selectedDatePrayerTimes.fajr},
      {'name': 'Sunrise', 'time': selectedDatePrayerTimes.sunrise},
      {'name': 'Dhuhur', 'time': selectedDatePrayerTimes.dhuhr},
      {'name': 'Asr', 'time': selectedDatePrayerTimes.asr},
      {'name': 'Maghrib', 'time': selectedDatePrayerTimes.maghrib},
      {'name': 'Isha', 'time': selectedDatePrayerTimes.isha},
    ];
    
    // Find current prayer (only for today)
    String currentPrayerName = '';
    if (isSelectedDateToday) {
      currentPrayerName = _findCurrentPrayer(prayerTimesList, now);
    }
    
    return [
      {
        'name': 'Fajr',
        'icon': AssetsPath.alfagrSVG,
        'time': _formatTime(selectedDatePrayerTimes.fajr),
        'notification': 'sound',
        'isCurrent': isSelectedDateToday && currentPrayerName == 'Fajr',
      },
      {
        'name': 'Sunrise',
        'icon': AssetsPath.alsobhSVG,
        'time': _formatTime(selectedDatePrayerTimes.sunrise),
        'notification': 'muted',
        'isCurrent': isSelectedDateToday && currentPrayerName == 'Sunrise',
      },
      {
        'name': 'Dhuhur',
        'icon': AssetsPath.alzohrSVG,
        'time': _formatTime(selectedDatePrayerTimes.dhuhr),
        'notification': 'vibrate',
        'isCurrent': isSelectedDateToday && currentPrayerName == 'Dhuhur',
      },
      {
        'name': 'Asr',
        'icon': AssetsPath.la3srSVG,
        'time': _formatTime(selectedDatePrayerTimes.asr),
        'notification': 'sound',
        'isCurrent': isSelectedDateToday && currentPrayerName == 'Asr',
      },
      {
        'name': 'Maghrib',
        'icon': AssetsPath.almaghribSVG,
        'time': _formatTime(selectedDatePrayerTimes.maghrib),
        'notification': 'sound',
        'isCurrent': isSelectedDateToday && currentPrayerName == 'Maghrib',
      },
      {
        'name': 'Isha',
        'icon': AssetsPath.aleshaaSVG,
        'time': _formatTime(selectedDatePrayerTimes.isha),
        'notification': 'sound',
        'isCurrent': isSelectedDateToday && currentPrayerName == 'Isha',
      },
    ];
  }

  String _findCurrentPrayer(List<Map<String, dynamic>> prayerTimesList, DateTime now) {
    final nowTimeOfDay = TimeOfDay.fromDateTime(now);
    final nowMinutes = nowTimeOfDay.hour * 60 + nowTimeOfDay.minute;
    
    // Find the next prayer that hasn't passed yet
    for (final prayer in prayerTimesList) {
      final prayerTime = prayer['time'] as DateTime;
      final prayerTimeOfDay = TimeOfDay.fromDateTime(prayerTime);
      final prayerMinutes = prayerTimeOfDay.hour * 60 + prayerTimeOfDay.minute;
      
      if (nowMinutes < prayerMinutes) {
        // This prayer hasn't passed yet, so the previous one is current
        final currentIndex = prayerTimesList.indexOf(prayer);
        if (currentIndex > 0) {
          return prayerTimesList[currentIndex - 1]['name'] as String;
        } else {
          // If it's before the first prayer, the last prayer of yesterday is current
          return prayerTimesList.last['name'] as String;
        }
      }
    }
    
    // If all prayers have passed, the last prayer is current
    return prayerTimesList.last['name'] as String;
  }

  String _getDateDisplayText(DateTime selectedDate) {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year && 
                   selectedDate.month == now.month && 
                   selectedDate.day == now.day;
    
    if (isToday) {
      return 'Today, ${DateFormat('dd MMM yyyy').format(selectedDate)}';
    } else {
      return DateFormat('dd MMM yyyy').format(selectedDate);
    }
  }

  void _showDatePickerBottomSheet(BuildContext context, DateTime currentDate) {
    DateTime selectedDate = currentDate;
    final prayerBloc = context.read<PrayerBloc>();
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
                      'Select Date',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeights.semiBold,
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
                    showDay: true,
                    labelStyle: TextStyle(
                      color: theme.textTheme.titleMedium?.color ?? AppColors.colorBlackHighEmp,
                      fontSize: 14.sp,
                      fontWeight: FontWeights.medium,
                    ),
                    selectedRowStyle: TextStyle(
                      color: theme.textTheme.titleMedium?.color ?? AppColors.colorBlackHighEmp,
                      fontSize: 18.sp,
                      fontWeight: FontWeights.semiBold,
                    ),
                    unselectedRowStyle: TextStyle(
                      color: theme.textTheme.bodySmall?.color ?? AppColors.colorBlackLowEmp,
                      fontSize: 16.sp,
                      fontWeight: FontWeights.regular,
                    ),
                    yearLabel: ui.window.locale.languageCode == 'ar' ? "سنة" : "Year",
                    monthLabel: ui.window.locale.languageCode == 'ar' ? "شهر" : "Month", 
                    dayLabel: ui.window.locale.languageCode == 'ar' ? "يوم" : "Day",
                    showLabels: false,
                    columnWidth: 100.w,
                    isJalali: false,
                    showMonthName: true,
                    monthsNames: ui.window.locale.languageCode == 'ar' ? [
                      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
                      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
                    ] : [
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
                    // Update the selected date in the bloc
                    prayerBloc.add(SelectDate(selectedDate));
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D1B3D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeights.medium,
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

  Widget _buildDateSelector(BuildContext context, PrayerLoaded state) {
    final bloc = context.read<PrayerBloc>();
    final theme = Theme.of(context);
    
    return Positioned(
      bottom: 0.h,
      left: 16.w,
      right: 16.w,
      child: GestureDetector(
        onTap: () {
          _showDatePickerBottomSheet(context, state.selectedDate);
        },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20.sp,
                color: theme.textTheme.titleMedium?.color ?? AppColors.colorBlackHighEmp,
              ),
              onPressed: () {
                context.read<PrayerBloc>().add(NavigateToPreviousDay());
              },
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                      _getDateDisplayText(state.selectedDate),
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeights.medium,
                      color: theme.textTheme.titleMedium?.color ?? AppColors.colorBlackHighEmp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    bloc.getHijriDate(),
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeights.regular,
                      color: theme.textTheme.bodySmall?.color ?? AppColors.colorBlackLowEmp,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 20.sp,
                color: theme.textTheme.titleMedium?.color ?? AppColors.colorBlackHighEmp,
              ),
              onPressed: () {
                context.read<PrayerBloc>().add(NavigateToNextDay());
              },
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerList(BuildContext context, PrayerLoaded state) {
    final bloc = context.read<PrayerBloc>();
    final theme = Theme.of(context);
    
    // Get prayer times for the selected date
    final prayersForSelectedDate = _getPrayerTimesForDate(state.selectedDate, state.prayers);
    
    return Container(
      width: 328.w,
      height: 312.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: List.generate(prayersForSelectedDate.length, (index) {
          final prayer = prayersForSelectedDate[index];
          final isCurrent = prayer['isCurrent'] as bool;
          final isLast = index == prayersForSelectedDate.length - 1;
          
          return Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: isLast ? null : Border(
                  bottom: BorderSide(
                    color: theme.dividerTheme.color ?? const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Prayer icon
                  Center(
                    child: SvgPicture.asset(
                      prayer['icon'],
                      height: 20.h,
                      colorFilter: ColorFilter.mode(
                        isCurrent
                            ? const Color(0xFF8D1B3D)
                            : AppColors.colorBlackMidEmp,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  
                  // Prayer name and time
                  Text(
                    prayer['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeights.medium,
                      color: isCurrent
                          ? const Color(0xFF8D1B3D)
                          : (theme.textTheme.titleMedium?.color ?? AppColors.colorBlackHighEmp),
                    ),
                  ),
                  if (isCurrent) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'NOW',
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeights.bold,
                          color: theme.textTheme.titleMedium?.color ?? AppColors.colorBlackHighEmp,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    prayer['time'],
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeights.medium,
                      color: isCurrent
                          ? const Color(0xFF8D1B3D)
                          : (theme.textTheme.bodyMedium?.color ?? AppColors.colorBlackMidEmp),
                    ),
                  ),
                  const Spacer(),
                  // Notification icon
                  GestureDetector(
                    onTap: () {
                      context.read<PrayerBloc>().add(ToggleNotification(index));
                    },
                    child: Container(
                      width: 40.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF8D1B3D).withOpacity(0.1)
                            : (theme.cardTheme.color?.withOpacity(0.1) ?? AppColors.colorGrey),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child:bloc.getNotificationIcon(prayer['notification']),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
