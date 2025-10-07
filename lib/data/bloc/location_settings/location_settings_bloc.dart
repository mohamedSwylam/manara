import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:ui' as ui;

part 'location_settings_event.dart';
part 'location_settings_state.dart';

class LocationSettingsBloc extends Bloc<LocationSettingsEvent, LocationSettingsState> {
  LocationSettingsBloc() : super(LocationSettingsInitial()) {
    on<LoadLocationSettings>(_onLoadLocationSettings);
    on<ToggleAutoDetectLocation>(_onToggleAutoDetectLocation);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<SearchLocation>(_onSearchLocation);
    on<SelectLocation>(_onSelectLocation);
    on<SaveLocationSettings>(_onSaveLocationSettings);
  }

  Future<void> _onLoadLocationSettings(
    LoadLocationSettings event,
    Emitter<LocationSettingsState> emit,
  ) async {
    emit(LocationSettingsLoading());
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final autoDetectEnabled = prefs.getBool('auto_detect_location') ?? true;
      String selectedLocation = prefs.getString('selected_location') ?? '';
      double selectedLatitude = prefs.getDouble('selected_latitude') ?? 25.2854;
      double selectedLongitude = prefs.getDouble('selected_longitude') ?? 51.5310;
      
      // If no location is saved, get current location
      if (selectedLocation.isEmpty) {
        try {
          selectedLocation = await _getCurrentLocationName();
          selectedLatitude = prefs.getDouble('selected_latitude') ?? 25.2854;
          selectedLongitude = prefs.getDouble('selected_longitude') ?? 51.5310;
          
          // Save the current location for future use
          await prefs.setString('selected_location', selectedLocation);
          await prefs.setDouble('selected_latitude', selectedLatitude);
          await prefs.setDouble('selected_longitude', selectedLongitude);
        } catch (e) {
          selectedLocation = 'Doha, Qatar';
          selectedLatitude = 25.2854;
          selectedLongitude = 51.5310;
          
          await prefs.setString('selected_location', selectedLocation);
          await prefs.setDouble('selected_latitude', selectedLatitude);
          await prefs.setDouble('selected_longitude', selectedLongitude);
        }
      }
      
      emit(LocationSettingsLoaded(
        autoDetectEnabled: autoDetectEnabled,
        selectedLocation: selectedLocation,
        selectedLatitude: selectedLatitude,
        selectedLongitude: selectedLongitude,
        searchResults: [],
        isLoading: false,
      ));
    } catch (e) {
      emit(LocationSettingsError('Failed to load location settings: $e'));
    }
  }

  Future<String> _getCurrentLocationName() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Doha, Qatar';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Doha, Qatar';
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      // Get location name using geocoding
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        String locationString = "${placemark.locality}, ${placemark.country}";
        locationString = locationString.replaceAll('null, ', '').replaceAll(', null', '');
        
        // Save coordinates for future use
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('selected_latitude', position.latitude);
        await prefs.setDouble('selected_longitude', position.longitude);
        
        return locationString.isNotEmpty ? locationString : 'Doha, Qatar';
      }

      return 'Doha, Qatar';
    } catch (e) {
      return 'Doha, Qatar';
    }
  }

  Future<void> _onToggleAutoDetectLocation(
    ToggleAutoDetectLocation event,
    Emitter<LocationSettingsState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_detect_location', event.enabled);
      
      if (state is LocationSettingsLoaded) {
        final currentState = state as LocationSettingsLoaded;
        emit(currentState.copyWith(autoDetectEnabled: event.enabled));
      }
    } catch (e) {
      emit(LocationSettingsError('Failed to update auto-detect setting: $e'));
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<LocationSettingsState> emit,
  ) async {
    try {
      if (state is LocationSettingsLoaded) {
        final currentState = state as LocationSettingsLoaded;
        emit(currentState.copyWith(isLoading: true));
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(LocationSettingsError('Location permission denied'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(LocationSettingsError('Location permission permanently denied'));
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // Get location name
      final locationName = await _getLocationName(position.latitude, position.longitude);

      // Update state
      if (state is LocationSettingsLoaded) {
        final currentState = state as LocationSettingsLoaded;
        emit(currentState.copyWith(
          selectedLocation: locationName,
          selectedLatitude: position.latitude,
          selectedLongitude: position.longitude,
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(LocationSettingsError('Failed to get current location: $e'));
    }
  }

  Future<void> _onSearchLocation(
    SearchLocation event,
    Emitter<LocationSettingsState> emit,
  ) async {
    try {
      if (state is LocationSettingsLoaded) {
        final currentState = state as LocationSettingsLoaded;
        emit(currentState.copyWith(isLoading: true));
      }

      if (event.query.isEmpty) {
        if (state is LocationSettingsLoaded) {
          final currentState = state as LocationSettingsLoaded;
          emit(currentState.copyWith(
            searchResults: [],
            isLoading: false,
          ));
        }
        return;
      }

      // Search for locations using geocoding
      final locations = await locationFromAddress(event.query);
      
      final searchResults = <LocationResult>[];
      for (final location in locations.take(5)) { // Limit to 5 results
        final locationName = await _getLocationName(location.latitude, location.longitude);
        searchResults.add(LocationResult(
          name: locationName,
          latitude: location.latitude,
          longitude: location.longitude,
        ));
      }

      if (state is LocationSettingsLoaded) {
        final currentState = state as LocationSettingsLoaded;
        emit(currentState.copyWith(
          searchResults: searchResults,
          isLoading: false,
        ));
      }
    } catch (e) {
      if (state is LocationSettingsLoaded) {
        final currentState = state as LocationSettingsLoaded;
        emit(currentState.copyWith(
          searchResults: [],
          isLoading: false,
        ));
      }
    }
  }

  Future<void> _onSelectLocation(
    SelectLocation event,
    Emitter<LocationSettingsState> emit,
  ) async {
    try {
      if (state is LocationSettingsLoaded) {
        final currentState = state as LocationSettingsLoaded;
        emit(currentState.copyWith(
          selectedLocation: event.location.name,
          selectedLatitude: event.location.latitude,
          selectedLongitude: event.location.longitude,
          searchResults: [], // Clear search results
        ));
      }
    } catch (e) {
      emit(LocationSettingsError('Failed to select location: $e'));
    }
  }

  Future<void> _onSaveLocationSettings(
    SaveLocationSettings event,
    Emitter<LocationSettingsState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('selected_location', event.location);
      await prefs.setDouble('selected_latitude', event.latitude);
      await prefs.setDouble('selected_longitude', event.longitude);
      
      // Also save to prayer settings for consistency
      await prefs.setString('prayer_location', event.location);
      
      // Update prayer times with new location
      // This will be handled by the UI layer by dispatching to PrayerTimesBloc
      
      emit(LocationSettingsSaved());
    } catch (e) {
      emit(LocationSettingsError('Failed to save location settings: $e'));
    }
  }

  Future<String> _getLocationName(double latitude, double longitude) async {
    try {
      // Get current locale to determine language
      final locale = ui.window.locale;
      final isArabic = locale.languageCode == 'ar';
      
      // Get placemarks
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        
        // Build location string
        String locationString = "${placemark.name}, ${placemark.locality}, ${placemark.country}";
        
        // Clean up the location string
        locationString = locationString.replaceAll('null, ', '').replaceAll(', null', '');
        
        // If app is in Arabic but location is in English, we might want to translate
        // For now, we'll return the location as is
        return locationString;
      }
      
      return 'Unknown Location';
    } catch (e) {
      return 'Unknown Location';
    }
  }
}

class LocationResult {
  final String name;
  final double latitude;
  final double longitude;

  LocationResult({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationResult &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => name.hashCode ^ latitude.hashCode ^ longitude.hashCode;
}
