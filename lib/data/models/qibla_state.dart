import 'package:equatable/equatable.dart';

class QiblaState extends Equatable {
  final bool isLoading;
  final double? latitude;
  final double? longitude;
  final double? qiblaDirection;
  final String? locationName;
  final String? error;
  final bool isMapLoaded;
  
  // New properties for device orientation and qiblah detection
  final double? deviceDirection;
  final double? qiblahAngle;
  final bool isPhoneLyingFlat;
  final bool isFacingQiblah;

  const QiblaState({
    this.isLoading = false,
    this.latitude,
    this.longitude,
    this.qiblaDirection,
    this.locationName,
    this.error,
    this.isMapLoaded = false,
    this.deviceDirection,
    this.qiblahAngle,
    this.isPhoneLyingFlat = true, // Changed from false to true
    this.isFacingQiblah = false,
  });

  QiblaState copyWith({
    bool? isLoading,
    double? latitude,
    double? longitude,
    double? qiblaDirection,
    String? locationName,
    String? error,
    bool? isMapLoaded,
    double? deviceDirection,
    double? qiblahAngle,
    bool? isPhoneLyingFlat,
    bool? isFacingQiblah,
  }) {
    return QiblaState(
      isLoading: isLoading ?? this.isLoading,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      qiblaDirection: qiblaDirection ?? this.qiblaDirection,
      locationName: locationName ?? this.locationName,
      error: error ?? this.error,
      isMapLoaded: isMapLoaded ?? this.isMapLoaded,
      deviceDirection: deviceDirection ?? this.deviceDirection,
      qiblahAngle: qiblahAngle ?? this.qiblahAngle,
      isPhoneLyingFlat: isPhoneLyingFlat ?? this.isPhoneLyingFlat,
      isFacingQiblah: isFacingQiblah ?? this.isFacingQiblah,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        latitude,
        longitude,
        qiblaDirection,
        locationName,
        error,
        isMapLoaded,
        deviceDirection,
        qiblahAngle,
        isPhoneLyingFlat,
        isFacingQiblah,
      ];
} 
