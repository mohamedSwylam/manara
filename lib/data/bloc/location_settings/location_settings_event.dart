part of 'location_settings_bloc.dart';

abstract class LocationSettingsEvent extends Equatable {
  const LocationSettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadLocationSettings extends LocationSettingsEvent {}

class ToggleAutoDetectLocation extends LocationSettingsEvent {
  final bool enabled;

  const ToggleAutoDetectLocation(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class GetCurrentLocation extends LocationSettingsEvent {}

class SearchLocation extends LocationSettingsEvent {
  final String query;

  const SearchLocation(this.query);

  @override
  List<Object> get props => [query];
}

class SelectLocation extends LocationSettingsEvent {
  final LocationResult location;

  const SelectLocation(this.location);

  @override
  List<Object> get props => [location];
}

class SaveLocationSettings extends LocationSettingsEvent {
  final String location;
  final double latitude;
  final double longitude;

  const SaveLocationSettings({
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [location, latitude, longitude];
}
