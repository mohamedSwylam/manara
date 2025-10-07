part of 'prayer_settings_bloc.dart';

abstract class PrayerSettingsEvent extends Equatable {
  const PrayerSettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadPrayerSettings extends PrayerSettingsEvent {}

class ToggleNotifications extends PrayerSettingsEvent {
  final bool enabled;

  const ToggleNotifications(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class UpdateLocation extends PrayerSettingsEvent {
  final String location;

  const UpdateLocation(this.location);

  @override
  List<Object> get props => [location];
}

class SelectAdhanSound extends PrayerSettingsEvent {
  final String soundName;

  const SelectAdhanSound(this.soundName);

  @override
  List<Object> get props => [soundName];
}

class AddCustomRingtone extends PrayerSettingsEvent {
  final String ringtoneName;
  final String? filePath;

  const AddCustomRingtone(this.ringtoneName, {this.filePath});

  @override
  List<Object> get props => [ringtoneName, filePath ?? ''];
}

class DeleteCustomRingtone extends PrayerSettingsEvent {
  const DeleteCustomRingtone();

  @override
  List<Object> get props => [];
}

class DismissNotificationBanner extends PrayerSettingsEvent {}
