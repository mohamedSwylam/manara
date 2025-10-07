import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../views/more/widgets/auth_button.dart';

class CustomTimePickerBottomSheet extends StatefulWidget {
  final String title;
  final TimeOfDay? initialTime;
  final Function(TimeOfDay) onTimeSet;

  const CustomTimePickerBottomSheet({
    super.key,
    required this.title,
    this.initialTime,
    required this.onTimeSet,
  });

  static Future<TimeOfDay?> show({
    required BuildContext context,
    required String title,
    TimeOfDay? initialTime,
    required Function(TimeOfDay) onTimeSet,
  }) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomTimePickerBottomSheet(
        title: title,
        initialTime: initialTime,
        onTimeSet: onTimeSet,
      ),
    );
  }

  @override
  State<CustomTimePickerBottomSheet> createState() => _CustomTimePickerBottomSheetState();
}

class _CustomTimePickerBottomSheetState extends State<CustomTimePickerBottomSheet> {
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime ?? TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with X button and title
          Container(
            padding: EdgeInsets.only(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              bottom: 8.h,
            ),
            child: Row(
              children: [
                const Spacer(),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: theme.textTheme.titleMedium?.color ?? Colors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: theme.textTheme.titleMedium?.color ?? Colors.black,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Time Picker
          SizedBox(
            height: 200.h,
            child: TimePickerSpinner(
              time: selectedTime,
              is24HourMode: false,
              onTimeChange: (time) {
                setState(() {
                  selectedTime = time;
                });
              },
            ),
          ),
          
          // Set Button
          Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              bottom: 32.h,
            ),
            child: AuthButton(
              text: 'Set',
              onPressed: () {
                widget.onTimeSet(selectedTime);
                Navigator.of(context).pop(selectedTime);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Time Picker Spinner Widget
class TimePickerSpinner extends StatefulWidget {
  final TimeOfDay time;
  final bool is24HourMode;
  final Function(TimeOfDay) onTimeChange;

  const TimePickerSpinner({
    super.key,
    required this.time,
    this.is24HourMode = false,
    required this.onTimeChange,
  });

  @override
  State<TimePickerSpinner> createState() => _TimePickerSpinnerState();
}

class _TimePickerSpinnerState extends State<TimePickerSpinner> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;
  late int _selectedHour;
  late int _selectedMinute;
  late String _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.time.hour;
    _selectedMinute = widget.time.minute;
    _selectedPeriod = _selectedHour >= 12 ? 'PM' : 'AM';
    
    if (!widget.is24HourMode) {
      _selectedHour = _selectedHour % 12;
      if (_selectedHour == 0) _selectedHour = 12;
    }
    
    _hourController = FixedExtentScrollController(initialItem: _selectedHour - 1);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
    _periodController = FixedExtentScrollController(
      initialItem: _selectedPeriod == 'AM' ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _onHourChanged(int hour) {
    setState(() {
      _selectedHour = hour + 1;
      _updateTime();
    });
  }

  void _onMinuteChanged(int minute) {
    setState(() {
      _selectedMinute = minute;
      _updateTime();
    });
  }

  void _onPeriodChanged(int periodIndex) {
    setState(() {
      _selectedPeriod = periodIndex == 0 ? 'AM' : 'PM';
      _updateTime();
    });
  }

  void _updateTime() {
    int hour = _selectedHour;
    if (!widget.is24HourMode) {
      if (_selectedPeriod == 'PM' && hour != 12) {
        hour += 12;
      } else if (_selectedPeriod == 'AM' && hour == 12) {
        hour = 0;
      }
    }
    
    final newTime = TimeOfDay(hour: hour, minute: _selectedMinute);
    widget.onTimeChange(newTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Stack(
      children: [
        // Background highlight for selected row
        Positioned(
          top: 75.h, // Center the highlight
          left: 20.w,
          right: 20.w,
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : const Color(0xFFDADADA), // Light grey background
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        
        // Time picker content
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hour Picker
            SizedBox(
              width: 80.w,
              child: ListWheelScrollView.useDelegate(
                controller: _hourController,
                itemExtent: 50.h,
                onSelectedItemChanged: _onHourChanged,
                physics: const FixedExtentScrollPhysics(),
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    final hour = index + 1;
                    final isSelected = hour == _selectedHour;
                    return Center(
                      child: Text(
                        hour.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: isSelected ? 20.sp : 16.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? (theme.textTheme.titleMedium?.color ?? Colors.black) : (theme.textTheme.bodySmall?.color ?? Colors.grey[600]),
                        ),
                      ),
                    );
                  },
                  childCount: widget.is24HourMode ? 24 : 12,
                ),
              ),
            ),
            SizedBox(width: 50.w),
            // Minute Picker
            SizedBox(
              width: 80.w,
              child: ListWheelScrollView.useDelegate(
                controller: _minuteController,
                itemExtent: 50.h,
                onSelectedItemChanged: _onMinuteChanged,
                physics: const FixedExtentScrollPhysics(),
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    final minute = index;
                    final isSelected = minute == _selectedMinute;
                    return Center(
                      child: Text(
                        minute.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: isSelected ? 20.sp : 16.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? (theme.textTheme.titleMedium?.color ?? Colors.black) : (theme.textTheme.bodySmall?.color ?? Colors.grey[600]),
                        ),
                      ),
                    );
                  },
                  childCount: 60,
                ),
              ),
            ),
            
            if (!widget.is24HourMode) ...[
              SizedBox(width: 50.w),
              
              // AM/PM Picker
              SizedBox(
                width: 60.w,
                child: ListWheelScrollView.useDelegate(
                  controller: _periodController,
                  itemExtent: 60.h,
                  onSelectedItemChanged: _onPeriodChanged,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      final period = index == 0 ? 'AM' : 'PM';
                      final isSelected = period == _selectedPeriod;
                      return Center(
                        child: Text(
                          period,
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: isSelected ? 20.sp : 16.sp,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? (theme.textTheme.titleMedium?.color ?? Colors.black) : (theme.textTheme.bodySmall?.color ?? Colors.grey[600]),
                          ),
                        ),
                      );
                    },
                    childCount: 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
