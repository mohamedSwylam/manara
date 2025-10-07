import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import 'islamic_calendar_event.dart';
import 'islamic_calendar_state.dart';

class IslamicCalendarBloc extends Bloc<IslamicCalendarEvent, IslamicCalendarState> {
  IslamicCalendarBloc() : super(IslamicCalendarInitial()) {
    on<LoadCalendarData>(_onLoadCalendarData);
    on<ChangeMonth>(_onChangeMonth);
    on<ToggleHijriView>(_onToggleHijriView);
    on<ToggleHolidayNotification>(_onToggleHolidayNotification);

    // Load initial data with current date
    final now = DateTime.now();
    add(LoadCalendarData(selectedDate: DateTime(now.year, now.month, now.day)));
  }

  Future<void> _onLoadCalendarData(
    LoadCalendarData event,
    Emitter<IslamicCalendarState> emit,
  ) async {
    emit(IslamicCalendarLoading());

    try {
      final calendarDays = _generateCalendarDays(event.selectedDate);
      final holidays = _generateHolidays();

      emit(IslamicCalendarLoaded(
        selectedDate: event.selectedDate,
        calendarDays: calendarDays,
        holidays: holidays,
        isHijriView: false,
      ));
    } catch (e) {
      emit(IslamicCalendarError(e.toString()));
    }
  }

  Future<void> _onChangeMonth(
    ChangeMonth event,
    Emitter<IslamicCalendarState> emit,
  ) async {
    add(LoadCalendarData(selectedDate: event.newDate));
  }

  void _onToggleHijriView(
    ToggleHijriView event,
    Emitter<IslamicCalendarState> emit,
  ) {
    if (state is IslamicCalendarLoaded) {
      final currentState = state as IslamicCalendarLoaded;
      emit(currentState.copyWith(isHijriView: !currentState.isHijriView));
    }
  }

  void _onToggleHolidayNotification(
    ToggleHolidayNotification event,
    Emitter<IslamicCalendarState> emit,
  ) {
    if (state is IslamicCalendarLoaded) {
      final currentState = state as IslamicCalendarLoaded;
      final updatedHolidays = currentState.holidays.map((holiday) {
        if (holiday.id == event.holidayId) {
          String newStatus = 'off';
          if (event.isEnabled) {
            newStatus = 'on';
          }
          return holiday.copyWith(
            notificationsEnabled: event.isEnabled,
            notificationStatus: newStatus,
          );
        }
        return holiday;
      }).toList();

      emit(currentState.copyWith(holidays: updatedHolidays));
    }
  }

  List<CalendarDay> _generateCalendarDays(DateTime selectedDate) {
    final List<CalendarDay> days = [];
    final DateTime lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    
    // Only add days from current month (1 to 30/31)
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      final DateTime date = DateTime(selectedDate.year, selectedDate.month, i);
      final HijriCalendar hijri = HijriCalendar.fromDate(date);
      
      days.add(CalendarDay(
        gregorianDate: date,
        hijriDate: hijri,
        isCurrentMonth: true,
        isToday: _isToday(date),
        isSelected: _isSelectedDate(date, selectedDate),
        hasHoliday: _hasHoliday(date),
        holidayName: _getHolidayName(date),
      ));
    }
    
    return days;
  }

  List<IslamicHoliday> _generateHolidays() {
    return [
      IslamicHoliday(
        id: 'ramadan_begins',
        name: 'Ramadan begins',
        gregorianDate: DateTime(2025, 2, 27),
        hijriDate: '1 Ramadan 1446',
        notificationsEnabled: true,
        notificationStatus: 'on',
      ),
      IslamicHoliday(
        id: 'laylat_al_qadr',
        name: 'Laylat al-Qadr',
        gregorianDate: DateTime(2025, 3, 26),
        hijriDate: '27 Ramadan 1446',
        notificationsEnabled: false,
        notificationStatus: 'off',
      ),
      IslamicHoliday(
        id: 'eid_al_fitr',
        name: 'Eid al-Fitr',
        gregorianDate: DateTime(2025, 3, 30),
        hijriDate: '1 Shawwai 1446',
        notificationsEnabled: false,
        notificationStatus: 'snooze',
      ),
      IslamicHoliday(
        id: 'hajj_season',
        name: 'Hajj season begins',
        gregorianDate: DateTime(2025, 6, 4),
        hijriDate: '8-13 Dhu al-Hijjah 1446',
        notificationsEnabled: true,
        notificationStatus: 'on',
      ),
      IslamicHoliday(
        id: 'day_of_arafah',
        name: 'Day of Arafah',
        gregorianDate: DateTime(2025, 6, 8),
        hijriDate: '9 Dhy al-Hijjah 1446',
        notificationsEnabled: true,
        notificationStatus: 'on',
      ),
      IslamicHoliday(
        id: 'eid_al_adha',
        name: 'Eid al-Adha',
        gregorianDate: DateTime(2025, 6, 9),
        hijriDate: '10 Dhy al-Hijjah 1446',
        notificationsEnabled: true,
        notificationStatus: 'on',
      ),
      IslamicHoliday(
        id: 'islamic_new_year',
        name: 'Islamic New Year',
        gregorianDate: DateTime(2025, 7, 27),
        hijriDate: '1 Muharram 1447',
        notificationsEnabled: true,
        notificationStatus: 'on',
      ),
    ];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    
    // Debug print to verify current day detection
    if (isToday) {
      print('Today detected: ${date.day}/${date.month}/${date.year}');
    }
    
    return isToday;
  }

  bool _isSelectedDate(DateTime date, DateTime selectedDate) {
    return date.year == selectedDate.year && 
           date.month == selectedDate.month && 
           date.day == selectedDate.day;
  }

  bool _hasHoliday(DateTime date) {
    final holidays = _generateHolidays();
    return holidays.any((holiday) => 
      holiday.gregorianDate.year == date.year &&
      holiday.gregorianDate.month == date.month &&
      holiday.gregorianDate.day == date.day
    );
  }

  String? _getHolidayName(DateTime date) {
    final holidays = _generateHolidays();
    final holiday = holidays.firstWhere(
      (holiday) => 
        holiday.gregorianDate.year == date.year &&
        holiday.gregorianDate.month == date.month &&
        holiday.gregorianDate.day == date.day,
             orElse: () => IslamicHoliday(
         id: '',
         name: '',
         gregorianDate: DateTime(2025, 1, 1),
         hijriDate: '',
         notificationsEnabled: false,
         notificationStatus: 'off',
       ),
    );
    return holiday.id.isNotEmpty ? holiday.name : null;
  }
}
