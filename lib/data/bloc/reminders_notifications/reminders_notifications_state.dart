import 'package:equatable/equatable.dart';

abstract class RemindersNotificationsState extends Equatable {
  const RemindersNotificationsState();

  @override
  List<Object?> get props => [];
}

class RemindersNotificationsInitial extends RemindersNotificationsState {}

class RemindersNotificationsLoading extends RemindersNotificationsState {}

class RemindersNotificationsLoaded extends RemindersNotificationsState {
  final bool islamicCalendarNotifications;
  final bool tasbihDailyReminder;
  final bool dailyDuaPopup;
  final bool quranDailyReminder;
  final bool readAlKahfFriday;
  
  final String tasbihTime;
  final String dailyDuaTime;
  final String quranTime;
  final String alKahfTime;
  
  final bool isSaving;
  final String? error;
  final String? successMessage;

  const RemindersNotificationsLoaded({
    this.islamicCalendarNotifications = true,
    this.tasbihDailyReminder = true,
    this.dailyDuaPopup = true,
    this.quranDailyReminder = true,
    this.readAlKahfFriday = true,
    this.tasbihTime = '12:00 PM',
    this.dailyDuaTime = '12:00 PM',
    this.quranTime = '12:00 PM',
    this.alKahfTime = '12:00 PM',
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  RemindersNotificationsLoaded copyWith({
    bool? islamicCalendarNotifications,
    bool? tasbihDailyReminder,
    bool? dailyDuaPopup,
    bool? quranDailyReminder,
    bool? readAlKahfFriday,
    String? tasbihTime,
    String? dailyDuaTime,
    String? quranTime,
    String? alKahfTime,
    bool? isSaving,
    String? error,
    String? successMessage,
  }) {
    return RemindersNotificationsLoaded(
      islamicCalendarNotifications: islamicCalendarNotifications ?? this.islamicCalendarNotifications,
      tasbihDailyReminder: tasbihDailyReminder ?? this.tasbihDailyReminder,
      dailyDuaPopup: dailyDuaPopup ?? this.dailyDuaPopup,
      quranDailyReminder: quranDailyReminder ?? this.quranDailyReminder,
      readAlKahfFriday: readAlKahfFriday ?? this.readAlKahfFriday,
      tasbihTime: tasbihTime ?? this.tasbihTime,
      dailyDuaTime: dailyDuaTime ?? this.dailyDuaTime,
      quranTime: quranTime ?? this.quranTime,
      alKahfTime: alKahfTime ?? this.alKahfTime,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    islamicCalendarNotifications,
    tasbihDailyReminder,
    dailyDuaPopup,
    quranDailyReminder,
    readAlKahfFriday,
    tasbihTime,
    dailyDuaTime,
    quranTime,
    alKahfTime,
    isSaving,
    error,
    successMessage,
  ];
}

class RemindersNotificationsError extends RemindersNotificationsState {
  final String message;

  const RemindersNotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}
