part of 'prayer_settings_bloc.dart';

abstract class PrayerSettingsState extends Equatable {
  const PrayerSettingsState();
  
  @override
  List<Object> get props => [];
}

class PrayerSettingsInitial extends PrayerSettingsState {}

class PrayerSettingsLoading extends PrayerSettingsState {}

class PrayerSettingsLoaded extends PrayerSettingsState {
  final bool notificationsEnabled;
  final String selectedLocation;
  final String selectedAdhanSound;
  final List<String> customRingtones;
  final bool showNotificationBanner;

  const PrayerSettingsLoaded({
    required this.notificationsEnabled,
    required this.selectedLocation,
    required this.selectedAdhanSound,
    required this.customRingtones,
    required this.showNotificationBanner,
  });

  PrayerSettingsLoaded copyWith({
    bool? notificationsEnabled,
    String? selectedLocation,
    String? selectedAdhanSound,
    List<String>? customRingtones,
    bool? showNotificationBanner,
  }) {
    return PrayerSettingsLoaded(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedAdhanSound: selectedAdhanSound ?? this.selectedAdhanSound,
      customRingtones: customRingtones ?? this.customRingtones,
      showNotificationBanner: showNotificationBanner ?? this.showNotificationBanner,
    );
  }

  @override
  List<Object> get props => [
    notificationsEnabled,
    selectedLocation,
    selectedAdhanSound,
    customRingtones,
    showNotificationBanner,
  ];
}

class PrayerSettingsError extends PrayerSettingsState {
  final String message;

  const PrayerSettingsError(this.message);

  @override
  List<Object> get props => [message];
}
