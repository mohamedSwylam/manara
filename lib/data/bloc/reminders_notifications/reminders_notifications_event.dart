import 'package:equatable/equatable.dart';

abstract class RemindersNotificationsEvent extends Equatable {
  const RemindersNotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRemindersSettings extends RemindersNotificationsEvent {}

class ToggleIslamicCalendarNotifications extends RemindersNotificationsEvent {
  final bool enabled;

  const ToggleIslamicCalendarNotifications(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleTasbihDailyReminder extends RemindersNotificationsEvent {
  final bool enabled;
  final String? time;

  const ToggleTasbihDailyReminder(this.enabled, {this.time});

  @override
  List<Object?> get props => [enabled, time];
}

class ToggleDailyDuaPopup extends RemindersNotificationsEvent {
  final bool enabled;
  final String? time;

  const ToggleDailyDuaPopup(this.enabled, {this.time});

  @override
  List<Object?> get props => [enabled, time];
}

class ToggleQuranDailyReminder extends RemindersNotificationsEvent {
  final bool enabled;
  final String? time;

  const ToggleQuranDailyReminder(this.enabled, {this.time});

  @override
  List<Object?> get props => [enabled, time];
}

class ToggleAlKahfFridayReminder extends RemindersNotificationsEvent {
  final bool enabled;
  final String? time;

  const ToggleAlKahfFridayReminder(this.enabled, {this.time});

  @override
  List<Object?> get props => [enabled, time];
}

class UpdateTasbihTime extends RemindersNotificationsEvent {
  final String time;

  const UpdateTasbihTime(this.time);

  @override
  List<Object?> get props => [time];
}

class UpdateDailyDuaTime extends RemindersNotificationsEvent {
  final String time;

  const UpdateDailyDuaTime(this.time);

  @override
  List<Object?> get props => [time];
}

class UpdateQuranTime extends RemindersNotificationsEvent {
  final String time;

  const UpdateQuranTime(this.time);

  @override
  List<Object?> get props => [time];
}

class UpdateAlKahfTime extends RemindersNotificationsEvent {
  final String time;

  const UpdateAlKahfTime(this.time);

  @override
  List<Object?> get props => [time];
}

class SaveRemindersSettings extends RemindersNotificationsEvent {}

class ResetRemindersSettings extends RemindersNotificationsEvent {}


