import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  String _currentLocation = '';
  double _currentLatitude = 25.2854;
  double _currentLongitude = 51.5310;

  String get currentLocation => _currentLocation;
  double get currentLatitude => _currentLatitude;
  double get currentLongitude => _currentLongitude;

  // Initialize location service
  Future<void> initialize() async {
    await loadSavedLocation();
  }

  // Load saved location from preferences
  Future<void> loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocation = prefs.getString('selected_location');
      final savedLatitude = prefs.getDouble('selected_latitude');
      final savedLongitude = prefs.getDouble('selected_longitude');

      if (savedLocation != null && savedLocation.isNotEmpty) {
        _currentLocation = savedLocation;
        _currentLatitude = savedLatitude ?? 25.2854;
        _currentLongitude = savedLongitude ?? 51.5310;
      } else {
        // Get current location if no saved location
        await getCurrentLocation();
      }
      notifyListeners();
    } catch (e) {
      print('Error loading saved location: $e');
    }
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      // Ensure location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Try to prompt user to enable location services
        await Geolocator.openLocationSettings();
        // Re-check after returning
        if (!await Geolocator.isLocationServiceEnabled()) {
          print('Location services are disabled');
          return;
        }
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Direct user to app settings to grant permission
        await Geolocator.openAppSettings();
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );

      // Get location name using geocoding
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        String locationString = "${placemark.locality}, ${placemark.country}";
        locationString =
            locationString.replaceAll('null, ', '').replaceAll(', null', '');

        await updateLocation(
          locationString.isNotEmpty ? locationString : 'Doha, Qatar',
          position.latitude,
          position.longitude,
        );
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  // Update location and notify all listeners
  Future<void> updateLocation(
      String location, double latitude, double longitude) async {
    try {
      _currentLocation = location;
      _currentLatitude = latitude;
      _currentLongitude = longitude;

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_location', location);
      await prefs.setDouble('selected_latitude', latitude);
      await prefs.setDouble('selected_longitude', longitude);
      await prefs.setString('prayer_location', location);

      // Notify all listeners (all screens will be updated)
      notifyListeners();
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  // Clear saved location
  Future<void> clearLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selected_location');
      await prefs.remove('selected_latitude');
      await prefs.remove('selected_longitude');
      await prefs.remove('prayer_location');

      _currentLocation = '';
      _currentLatitude = 25.2854;
      _currentLongitude = 51.5310;

      notifyListeners();
    } catch (e) {
      print('Error clearing location: $e');
    }
  }
}
