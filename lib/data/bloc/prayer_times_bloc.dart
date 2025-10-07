import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import '../models/prayer_times_events.dart';
import '../models/prayer_times_model.dart';
import '../models/mosque_model.dart';
import '../services/mosque_service.dart';
import '../services/workmanager_notification_service.dart';

class PrayerTimesBloc extends Bloc<PrayerTimesEvent, PrayerTimesState> {
  Timer? _timer;
  final WorkManagerNotificationService _workManagerService =
      WorkManagerNotificationService();

  // Cache for location names to prevent duplicate API calls
  static final Map<String, String> _locationCache = {};
  static const Duration _locationCacheExpiry = Duration(minutes: 30);

  PrayerTimesBloc() : super(const PrayerTimesState()) {
    on<LoadPrayerTimes>(_onLoadPrayerTimes);
    on<UpdateLocation>(_onUpdateLocation);
    on<UpdateCurrentTime>(_onUpdateCurrentTime);
    on<RefreshPrayerTimes>(_onRefreshPrayerTimes);

    // Start timer to update current time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(UpdateCurrentTime(DateTime.now()));
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> _onLoadPrayerTimes(
    LoadPrayerTimes event,
    Emitter<PrayerTimesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final prayerTimes = await _calculatePrayerTimes(
        event.latitude,
        event.longitude,
      );

      final locationName = await _getLocationName(
        event.latitude,
        event.longitude,
      );

      final nearbyMosques = await _getNearbyMosques(
        event.latitude,
        event.longitude,
      );

      emit(state.copyWith(
        prayerTimes: prayerTimes,
        locationName: locationName,
        nearbyMosques: nearbyMosques,
        userLat: event.latitude,
        userLng: event.longitude,
        isLoading: false,
      ));

      // Calculate next prayer time
      _calculateNextPrayerTime(emit);

      // Schedule prayer notifications
      await _schedulePrayerNotifications(prayerTimes);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<PrayerTimesState> emit,
  ) async {
    emit(state.copyWith(
      locationName: event.locationName,
    ));

    // Reload prayer times with new location
    add(LoadPrayerTimes(
      latitude: event.latitude,
      longitude: event.longitude,
    ));
  }

  void _onUpdateCurrentTime(
    UpdateCurrentTime event,
    Emitter<PrayerTimesState> emit,
  ) {
    emit(state.copyWith(currentTime: event.currentTime));
    _calculateNextPrayerTime(emit);
  }

  Future<void> _onRefreshPrayerTimes(
    RefreshPrayerTimes event,
    Emitter<PrayerTimesState> emit,
  ) async {
    if (state.prayerTimes.isNotEmpty) {
      // Recalculate prayer times for current location
      final firstPrayerTime = state.prayerTimes.first;
      // You would need to store the current coordinates somewhere
      // For now, we'll just recalculate with the existing data
      _calculateNextPrayerTime(emit);
    }
  }

  Future<List<PrayerTimesModel>> _calculatePrayerTimes(
    double latitude,
    double longitude,
  ) async {
    final coordinates = Coordinates(latitude, longitude);
    final calculationMethod =
        CalculationMethod.muslim_world_league.getParameters();
    final prayerTimes = <PrayerTimesModel>[];

    for (var i = 0; i <= 5; i++) {
      final date = DateComponents.from(DateTime.now().add(Duration(days: i)));
      final times = PrayerTimes(coordinates, date, calculationMethod);

      prayerTimes.add(PrayerTimesModel(
        fajr: times.fajr,
        sunrise: times.sunrise,
        dhuhr: times.dhuhr,
        asr: times.asr,
        maghrib: times.maghrib,
        isha: times.isha,
        date: DateTime.now().add(Duration(days: i)),
      ));
    }

    return prayerTimes;
  }

  Future<String> _getLocationName(double latitude, double longitude) async {
    // Create cache key based on coordinates (rounded to 2 decimal places)
    final cacheKey =
        '${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';

    // Check cache first
    if (_locationCache.containsKey(cacheKey)) {
      print('📋 Returning cached location for: $cacheKey');
      return _locationCache[cacheKey]!;
    }

    try {
      // Get current locale to determine language
      final locale = ui.window.locale;
      final isArabic = locale.languageCode == 'ar';

      print('Fetching location for lat: $latitude, lng: $longitude');
      print('Current locale: ${locale.languageCode}');

      // Get placemarks - this will return in device language
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      print('Found ${placemarks.length} placemarks');

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        print('Placemark data:');
        print('  Name: ${placemark.name}');
        print('  Locality: ${placemark.locality}');
        print('  Country: ${placemark.country}');
        print('  Administrative Area: ${placemark.administrativeArea}');
        print('  Sub Locality: ${placemark.subLocality}');

        // If app is in English but device is in Arabic, we need to translate
        // If app is in Arabic but device is in English, we need to translate
        String locationString =
            "${placemark.name}, ${placemark.locality}, ${placemark.country}";

        // Check if we need to translate based on app language vs device language
        if (isArabic && _containsArabicText(locationString)) {
          // App is Arabic, location is already in Arabic - good
          print('Location already in Arabic - no translation needed');
        } else if (!isArabic && _containsArabicText(locationString)) {
          // App is English, but location is in Arabic - need to translate
          print('Translating Arabic location to English');
          locationString = _translateLocationToEnglish(locationString);
        } else if (isArabic && !_containsArabicText(locationString)) {
          // App is Arabic, but location is in English - need to translate
          print('Translating English location to Arabic');
          locationString = _translateLocationToArabic(locationString);
        } else {
          // App is English, location is already in English - good
          print('Location already in English - no translation needed');
        }

        print('Final location string: $locationString');

        // Cache the result
        _locationCache[cacheKey] = locationString;

        return locationString;
      }

      final fallbackLocation = 'Location not found';
      _locationCache[cacheKey] = fallbackLocation;
      return fallbackLocation;
    } catch (e) {
      print('Error fetching location: $e');
      final errorLocation = 'Error fetching location';
      _locationCache[cacheKey] = errorLocation;
      return errorLocation;
    }
  }

  bool _containsArabicText(String text) {
    // Check if text contains Arabic characters
    final arabicRegex = RegExp(
        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
    return arabicRegex.hasMatch(text);
  }

  String _translateLocationToEnglish(String arabicLocation) {
    // Common Arabic to English translations
    final translations = {
      'مصر': 'Egypt',
      'القاهرة': 'Cairo',
      'الإسكندرية': 'Alexandria',
      'الجيزة': 'Giza',
      'الرياض': 'Riyadh',
      'جدة': 'Jeddah',
      'مكة': 'Mecca',
      'المدينة': 'Medina',
      'دبي': 'Dubai',
      'أبو ظبي': 'Abu Dhabi',
      'الشارقة': 'Sharjah',
      'عمان': 'Amman',
      'بيروت': 'Beirut',
      'بغداد': 'Baghdad',
      'دمشق': 'Damascus',
      'القدس': 'Jerusalem',
      'غزة': 'Gaza',
      'الخليل': 'Hebron',
      'نابلس': 'Nablus',
      'رام الله': 'Ramallah',
      'الجزائر': 'Algeria',
      'الجزائر العاصمة': 'Algiers',
      'المغرب': 'Morocco',
      'الرباط': 'Rabat',
      'الدار البيضاء': 'Casablanca',
      'تونس': 'Tunisia',
      'تونس العاصمة': 'Tunis',
      'ليبيا': 'Libya',
      'طرابلس': 'Tripoli',
      'السودان': 'Sudan',
      'الخرطوم': 'Khartoum',
      'الصومال': 'Somalia',
      'مقديشو': 'Mogadishu',
      'اليمن': 'Yemen',
      'صنعاء': 'Sanaa',
      'عدن': 'Aden',
      'الكويت': 'Kuwait',
      'الكويت العاصمة': 'Kuwait City',
      'البحرين': 'Bahrain',
      'المنامة': 'Manama',
      'قطر': 'Qatar',
      'الدوحة': 'Doha',
      'عمان': 'Oman',
      'مسقط': 'Muscat',
      'الإمارات': 'UAE',
      'الإمارات العربية المتحدة': 'United Arab Emirates',
      'السعودية': 'Saudi Arabia',
      'المملكة العربية السعودية': 'Saudi Arabia',
      'الأردن': 'Jordan',
      'لبنان': 'Lebanon',
      'العراق': 'Iraq',
      'سوريا': 'Syria',
      'فلسطين': 'Palestine',
      'قطاع غزة': 'Gaza Strip',
      'الضفة الغربية': 'West Bank',
      'محلة أبو علي القنطرة': 'Abu Ali Qantara',
      'محافظة الغربية': 'Western Province',
    };

    String translated = arabicLocation;
    for (final entry in translations.entries) {
      translated = translated.replaceAll(entry.key, entry.value);
    }

    // Replace Arabic comma with English comma
    translated = translated.replaceAll('،', ',');

    return translated;
  }

  String _translateLocationToArabic(String englishLocation) {
    // Common English to Arabic translations
    final translations = {
      'Egypt': 'مصر',
      'Cairo': 'القاهرة',
      'Alexandria': 'الإسكندرية',
      'Giza': 'الجيزة',
      'Riyadh': 'الرياض',
      'Jeddah': 'جدة',
      'Mecca': 'مكة',
      'Medina': 'المدينة',
      'Dubai': 'دبي',
      'Abu Dhabi': 'أبو ظبي',
      'Sharjah': 'الشارقة',
      'Amman': 'عمان',
      'Beirut': 'بيروت',
      'Baghdad': 'بغداد',
      'Damascus': 'دمشق',
      'Jerusalem': 'القدس',
      'Gaza': 'غزة',
      'Hebron': 'الخليل',
      'Nablus': 'نابلس',
      'Ramallah': 'رام الله',
      'Algeria': 'الجزائر',
      'Algiers': 'الجزائر العاصمة',
      'Morocco': 'المغرب',
      'Rabat': 'الرباط',
      'Casablanca': 'الدار البيضاء',
      'Tunisia': 'تونس',
      'Tunis': 'تونس العاصمة',
      'Libya': 'ليبيا',
      'Tripoli': 'طرابلس',
      'Sudan': 'السودان',
      'Khartoum': 'الخرطوم',
      'Somalia': 'الصومال',
      'Mogadishu': 'مقديشو',
      'Yemen': 'اليمن',
      'Sanaa': 'صنعاء',
      'Aden': 'عدن',
      'Kuwait': 'الكويت',
      'Kuwait City': 'الكويت العاصمة',
      'Bahrain': 'البحرين',
      'Manama': 'المنامة',
      'Qatar': 'قطر',
      'Doha': 'الدوحة',
      'Oman': 'عمان',
      'Muscat': 'مسقط',
      'UAE': 'الإمارات',
      'United Arab Emirates': 'الإمارات العربية المتحدة',
      'Saudi Arabia': 'السعودية',
      'Jordan': 'الأردن',
      'Lebanon': 'لبنان',
      'Iraq': 'العراق',
      'Syria': 'سوريا',
      'Palestine': 'فلسطين',
      'Gaza Strip': 'قطاع غزة',
      'West Bank': 'الضفة الغربية',
      'Abu Ali Qantara': 'محلة أبو علي القنطرة',
      'Western Province': 'محافظة الغربية',
    };

    String translated = englishLocation;
    for (final entry in translations.entries) {
      translated = translated.replaceAll(entry.key, entry.value);
    }

    // Replace English comma with Arabic comma
    translated = translated.replaceAll(',', '،');

    return translated;
  }

  Future<List<MosqueModel>> _getNearbyMosques(
      double latitude, double longitude) async {
    try {
      // Use the real mosque service to fetch actual nearby mosques
      return await MosqueService.getNearbyMosques(latitude, longitude);
    } catch (e) {
      print('Error fetching nearby mosques: $e');
      // Return empty list on error
      return [];
    }
  }

  void _calculateNextPrayerTime(Emitter<PrayerTimesState> emit) {
    if (state.prayerTimes.isEmpty || state.currentTime == null) return;

    final now = state.currentTime!;
    final todayPrayerTimes = state.prayerTimes.first;

    // Define prayer times in order
    final prayers = [
      {'name': 'fajr', 'time': todayPrayerTimes.fajr},
      {'name': 'sunrise', 'time': todayPrayerTimes.sunrise},
      {'name': 'dhuhr', 'time': todayPrayerTimes.dhuhr},
      {'name': 'asr', 'time': todayPrayerTimes.asr},
      {'name': 'maghrib', 'time': todayPrayerTimes.maghrib},
      {'name': 'isha', 'time': todayPrayerTimes.isha},
    ];

    // Find next prayer
    String? nextPrayer;
    Duration? timeUntilNextPrayer;

    for (final prayer in prayers) {
      final prayerTime = prayer['time'] as DateTime;
      // Ensure we're comparing the same day
      final today = DateTime(now.year, now.month, now.day);
      final prayerDateTime = DateTime(
        today.year,
        today.month,
        today.day,
        prayerTime.hour,
        prayerTime.minute,
        prayerTime.second,
      );

      if (prayerDateTime.isAfter(now)) {
        nextPrayer = prayer['name'] as String;
        timeUntilNextPrayer = prayerDateTime.difference(now);
        break;
      }
    }

    // If no prayer found for today, use tomorrow's fajr
    if (nextPrayer == null && state.prayerTimes.length > 1) {
      final tomorrowFajr = state.prayerTimes[1].fajr;
      final tomorrow =
          DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      final tomorrowFajrDateTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        tomorrowFajr.hour,
        tomorrowFajr.minute,
        tomorrowFajr.second,
      );

      nextPrayer = 'fajr';
      timeUntilNextPrayer = tomorrowFajrDateTime.difference(now);
    }

    emit(state.copyWith(
      nextPrayer: nextPrayer,
      timeUntilNextPrayer: timeUntilNextPrayer,
    ));
  }

  String formatPrayerTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String formatTimeUntilNextPrayer() {
    if (state.timeUntilNextPrayer == null) return '00:00:00';

    final duration = state.timeUntilNextPrayer!;
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  String getCurrentPrayerName() {
    if (state.nextPrayer == null) return 'العصر';

    switch (state.nextPrayer!) {
      case 'fajr':
        return 'fajr'.tr;
      case 'sunrise':
        return 'sunrise'.tr;
      case 'dhuhr':
        return 'dhuhr'.tr;
      case 'asr':
        return 'asr'.tr;
      case 'maghrib':
        return 'maghrib'.tr;
      case 'isha':
        return 'isha'.tr;
      default:
        return 'asr'.tr;
    }
  }

  Future<void> _schedulePrayerNotifications(
      List<PrayerTimesModel> prayerTimes) async {
    try {
      if (prayerTimes.isEmpty) return;

      // Get today's prayer times
      final todayPrayerTimes = prayerTimes.first;

      // Convert prayer times to the format expected by notification service
      final prayerTimesList = [
        {'name': 'fajr', 'time': todayPrayerTimes.fajr},
        {'name': 'sunrise', 'time': todayPrayerTimes.sunrise},
        {'name': 'dhuhr', 'time': todayPrayerTimes.dhuhr},
        {'name': 'asr', 'time': todayPrayerTimes.asr},
        {'name': 'maghrib', 'time': todayPrayerTimes.maghrib},
        {'name': 'isha', 'time': todayPrayerTimes.isha},
      ];

      // Try WorkManager first, fallback to Timer if it fails
      try {
        await _workManagerService
            .schedulePrayerNotificationsWithWorkManager(prayerTimesList);
        print('Prayer notifications scheduled with WorkManager successfully');
      } catch (e) {
        print('WorkManager failed, using Timer fallback: $e');
        // Timer fallback is handled automatically in the WorkManager service
        await _workManagerService
            .schedulePrayerNotificationsWithWorkManager(prayerTimesList);
      }

      print('Prayer notifications scheduled successfully');
    } catch (e) {
      print('Error scheduling prayer notifications: $e');
    }
  }
}
