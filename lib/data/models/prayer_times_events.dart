import 'package:equatable/equatable.dart';

abstract class PrayerTimesEvent extends Equatable {
  const PrayerTimesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrayerTimes extends PrayerTimesEvent {
  final double latitude;
  final double longitude;

  const LoadPrayerTimes({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class UpdateLocation extends PrayerTimesEvent {
  final double latitude;
  final double longitude;
  final String locationName;

  const UpdateLocation({
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  List<Object?> get props => [latitude, longitude, locationName];
}

class UpdateCurrentTime extends PrayerTimesEvent {
  final DateTime currentTime;

  const UpdateCurrentTime(this.currentTime);

  @override
  List<Object?> get props => [currentTime];
}

class RefreshPrayerTimes extends PrayerTimesEvent {
  const RefreshPrayerTimes();
} 
