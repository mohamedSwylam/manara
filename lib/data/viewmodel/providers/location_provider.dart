import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider extends ChangeNotifier{
  //Getting suffix of date
  String getDaySuffix(int day) {
    // Helper function to get the day suffix
    switch (day) {
      case 1:
      case 21:
      case 31:
        return 'st';
      case 2:
      case 22:
        return 'nd';
      case 3:
      case 23:
        return 'rd';
      default:
        return 'th';
    }
  }

  //Getting location (lat & long)
  Position? _position;
  Position? get initPosition => _position;

  Future<void> getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _position = position;
      notifyListeners();

      // Update prayer times
      await updatePrayerTimes();
      await getLocationName();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  //Get location name based on lat lon
  String _locationName = '';
  String get locationName => _locationName;

  Future<void> getLocationName() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(_position!.latitude, _position!.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        _locationName = "${placemark.name}, ${placemark.locality}, ${placemark.country}";
        notifyListeners();
      } else {
        _locationName = 'Location not found';
        notifyListeners();
      }
    } catch (e) {
      print("Error: $e");
      _locationName = 'Error fetching location';
      notifyListeners();
    }
  }

  Coordinates? _coordinates;
  CalculationParameters? _calculationMethod;

  final List<PrayerTimes> _prayerTimes = [];
  List<PrayerTimes>? get prayerTimes => _prayerTimes;

  Future<void> updatePrayerTimes() async {
    _calculationMethod ??= CalculationMethod.muslim_world_league.getParameters();

    _coordinates = Coordinates(_position!.latitude, _position!.longitude);
    _prayerTimes.clear();

    for (var i = 0; i <= 5; i++){
      final date = DateComponents.from(DateTime.now().add(Duration(days: i)));
      final prayerTimes = PrayerTimes(_coordinates!, date, _calculationMethod!);
      _prayerTimes.add(prayerTimes);
      notifyListeners();
    }
  }

  // Notification settings (simplified - actual notifications handled by WorkManagerNotificationService)
  bool _fajrNotification = false;
  bool _dhuharNotification = false;
  bool _asrNotification = false;
  bool _maghribNotification = false;
  bool _ishaNotification = false;

  bool get fajrNotification => _fajrNotification;
  bool get dhuharNotification => _dhuharNotification;
  bool get asrNotification => _asrNotification;
  bool get maghribNotification => _maghribNotification;
  bool get ishaNotification => _ishaNotification;

  Future<void> setBool() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _fajrNotification = prefs.getBool('fajrNotification') ?? false;
    _dhuharNotification = prefs.getBool('dhuharNotification') ?? false;
    _asrNotification = prefs.getBool('asrNotification') ?? false;
    _maghribNotification = prefs.getBool('maghribNotification') ?? false;
    _ishaNotification = prefs.getBool('ishaNotification') ?? false;
    notifyListeners();
  }

  Future<void> getBool() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _fajrNotification = prefs.getBool('fajrNotification') ?? false;
    _dhuharNotification = prefs.getBool('dhuharNotification') ?? false;
    _asrNotification = prefs.getBool('asrNotification') ?? false;
    _maghribNotification = prefs.getBool('maghribNotification') ?? false;
    _ishaNotification = prefs.getBool('ishaNotification') ?? false;
    notifyListeners();
  }

  Future<void> updatePrayerTimesAndSetNotification() async {
    await updatePrayerTimes();
    // Notifications are now handled by WorkManagerNotificationService
    // This method is kept for compatibility but doesn't schedule notifications
  }
}
