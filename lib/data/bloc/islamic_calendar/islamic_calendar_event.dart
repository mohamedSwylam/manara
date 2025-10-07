import 'package:equatable/equatable.dart';

abstract class IslamicCalendarEvent extends Equatable {
  const IslamicCalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCalendarData extends IslamicCalendarEvent {
  final DateTime selectedDate;

  const LoadCalendarData({required this.selectedDate});

  @override
  List<Object?> get props => [selectedDate];
}

class ChangeMonth extends IslamicCalendarEvent {
  final DateTime newDate;

  const ChangeMonth({required this.newDate});

  @override
  List<Object?> get props => [newDate];
}

class ToggleHijriView extends IslamicCalendarEvent {
  const ToggleHijriView();
}

class ToggleHolidayNotification extends IslamicCalendarEvent {
  final String holidayId;
  final bool isEnabled;

  const ToggleHolidayNotification({
    required this.holidayId,
    required this.isEnabled,
  });

  @override
  List<Object?> get props => [holidayId, isEnabled];
}
