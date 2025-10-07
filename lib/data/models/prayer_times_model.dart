import 'package:equatable/equatable.dart';

class PrayerTimesModel extends Equatable {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime date;

  const PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
  });

  @override
  List<Object?> get props => [fajr, sunrise, dhuhr, asr, maghrib, isha, date];

  PrayerTimesModel copyWith({
    DateTime? fajr,
    DateTime? sunrise,
    DateTime? dhuhr,
    DateTime? asr,
    DateTime? maghrib,
    DateTime? isha,
    DateTime? date,
  }) {
    return PrayerTimesModel(
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      date: date ?? this.date,
    );
  }
}

class PrayerTimesState extends Equatable {
  final List<PrayerTimesModel> prayerTimes;
  final String locationName;
  final bool isLoading;
  final String? error;
  final DateTime? currentTime;
  final String? nextPrayer;
  final Duration? timeUntilNextPrayer;
  final List<dynamic> nearbyMosques; // Using dynamic to avoid circular import
  final double? userLat;
  final double? userLng;

  const PrayerTimesState({
    this.prayerTimes = const [],
    this.locationName = '',
    this.isLoading = false,
    this.error,
    this.currentTime,
    this.nextPrayer,
    this.timeUntilNextPrayer,
    this.userLat,
    this.userLng,
    this.nearbyMosques = const [],
  });

  @override
  List<Object?> get props => [
        prayerTimes,
        locationName,
        isLoading,
        error,
        currentTime,
        nextPrayer,
        timeUntilNextPrayer,
        nearbyMosques,
        userLat,
        userLng,
      ];

  PrayerTimesState copyWith({
    List<PrayerTimesModel>? prayerTimes,
    String? locationName,
    bool? isLoading,
    String? error,
    DateTime? currentTime,
    String? nextPrayer,
    Duration? timeUntilNextPrayer,
    List<dynamic>? nearbyMosques,
    double? userLat,
    double? userLng,
  }) {
    return PrayerTimesState(
      prayerTimes: prayerTimes ?? this.prayerTimes,
      locationName: locationName ?? this.locationName,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentTime: currentTime ?? this.currentTime,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      timeUntilNextPrayer: timeUntilNextPrayer ?? this.timeUntilNextPrayer,
      nearbyMosques: nearbyMosques ?? this.nearbyMosques,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
    );
  }
} 
