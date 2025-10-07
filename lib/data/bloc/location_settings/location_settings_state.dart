part of 'location_settings_bloc.dart';

abstract class LocationSettingsState extends Equatable {
  const LocationSettingsState();
  
  @override
  List<Object> get props => [];
}

class LocationSettingsInitial extends LocationSettingsState {}

class LocationSettingsLoading extends LocationSettingsState {}

class LocationSettingsLoaded extends LocationSettingsState {
  final bool autoDetectEnabled;
  final String selectedLocation;
  final double selectedLatitude;
  final double selectedLongitude;
  final List<LocationResult> searchResults;
  final bool isLoading;

  const LocationSettingsLoaded({
    required this.autoDetectEnabled,
    required this.selectedLocation,
    required this.selectedLatitude,
    required this.selectedLongitude,
    required this.searchResults,
    required this.isLoading,
  });

  LocationSettingsLoaded copyWith({
    bool? autoDetectEnabled,
    String? selectedLocation,
    double? selectedLatitude,
    double? selectedLongitude,
    List<LocationResult>? searchResults,
    bool? isLoading,
  }) {
    return LocationSettingsLoaded(
      autoDetectEnabled: autoDetectEnabled ?? this.autoDetectEnabled,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedLatitude: selectedLatitude ?? this.selectedLatitude,
      selectedLongitude: selectedLongitude ?? this.selectedLongitude,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [
    autoDetectEnabled,
    selectedLocation,
    selectedLatitude,
    selectedLongitude,
    searchResults,
    isLoading,
  ];
}

class LocationSettingsSaved extends LocationSettingsState {}

class LocationSettingsError extends LocationSettingsState {
  final String message;

  const LocationSettingsError(this.message);

  @override
  List<Object> get props => [message];
}
