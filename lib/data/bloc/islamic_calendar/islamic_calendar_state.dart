import 'package:equatable/equatable.dart';
import 'package:hijri/hijri_calendar.dart';

class CalendarDay extends Equatable {
  final DateTime gregorianDate;
  final HijriCalendar hijriDate;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final bool hasHoliday;
  final String? holidayName;

  const CalendarDay({
    required this.gregorianDate,
    required this.hijriDate,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    this.hasHoliday = false,
    this.holidayName,
  });

  @override
  List<Object?> get props => [
        gregorianDate,
        hijriDate,
        isCurrentMonth,
        isToday,
        isSelected,
        hasHoliday,
        holidayName,
      ];
}

class IslamicHoliday extends Equatable {
  final String id;
  final String name;
  final DateTime gregorianDate;
  final String hijriDate;
  final bool notificationsEnabled;
  final String notificationStatus; // 'on', 'off', 'snooze'

  const IslamicHoliday({
    required this.id,
    required this.name,
    required this.gregorianDate,
    required this.hijriDate,
    required this.notificationsEnabled,
    required this.notificationStatus,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        gregorianDate,
        hijriDate,
        notificationsEnabled,
        notificationStatus,
      ];

  IslamicHoliday copyWith({
    String? id,
    String? name,
    DateTime? gregorianDate,
    String? hijriDate,
    bool? notificationsEnabled,
    String? notificationStatus,
  }) {
    return IslamicHoliday(
      id: id ?? this.id,
      name: name ?? this.name,
      gregorianDate: gregorianDate ?? this.gregorianDate,
      hijriDate: hijriDate ?? this.hijriDate,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationStatus: notificationStatus ?? this.notificationStatus,
    );
  }
}

abstract class IslamicCalendarState extends Equatable {
  const IslamicCalendarState();

  @override
  List<Object?> get props => [];
}

class IslamicCalendarInitial extends IslamicCalendarState {}

class IslamicCalendarLoading extends IslamicCalendarState {}

class IslamicCalendarLoaded extends IslamicCalendarState {
  final DateTime? selectedDate;
  final List<CalendarDay> calendarDays;
  final List<IslamicHoliday> holidays;
  final bool isHijriView;

  const IslamicCalendarLoaded({
    this.selectedDate,
    this.calendarDays = const [],
    this.holidays = const [],
    this.isHijriView = false,
  });

  @override
  List<Object?> get props => [
        selectedDate,
        calendarDays,
        holidays,
        isHijriView,
      ];

  IslamicCalendarLoaded copyWith({
    DateTime? selectedDate,
    List<CalendarDay>? calendarDays,
    List<IslamicHoliday>? holidays,
    bool? isHijriView,
  }) {
    return IslamicCalendarLoaded(
      selectedDate: selectedDate ?? this.selectedDate,
      calendarDays: calendarDays ?? this.calendarDays,
      holidays: holidays ?? this.holidays,
      isHijriView: isHijriView ?? this.isHijriView,
    );
  }
}

class IslamicCalendarError extends IslamicCalendarState {
  final String message;

  const IslamicCalendarError(this.message);

  @override
  List<Object?> get props => [message];
}
