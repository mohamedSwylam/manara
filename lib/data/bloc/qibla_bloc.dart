import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';

import '../models/qibla_events.dart';
import '../models/qibla_state.dart';

class QiblaBloc extends Bloc<QiblaEvent, QiblaState> {
  QiblaBloc() : super(const QiblaState()) {
    on<LoadQiblaDirection>(_onLoadQiblaDirection);
    on<UpdateQiblaLocation>(_onUpdateQiblaLocation);
    on<RefreshQiblaDirection>(_onRefreshQiblaDirection);
    on<UpdateDeviceDirection>(_onUpdateDeviceDirection);
    on<UpdatePhoneFlatness>(_onUpdatePhoneFlatness);
  }

  Future<void> _onLoadQiblaDirection(
    LoadQiblaDirection event,
    Emitter<QiblaState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Get location name
      final locationName =
          await _getLocationName(event.latitude, event.longitude);

      // Calculate qibla direction
      final qiblaDirection =
          _calculateQiblaDirection(event.latitude, event.longitude);

      // CRITICAL TEST LOG: user lat/lng and computed bearing
      // Compare this bearing with a trusted external source (e.g., Google Qibla Finder)
      print(
          '[QIBLA] lat=${event.latitude}, lng=${event.longitude}, bearing=${qiblaDirection.toStringAsFixed(2)}°');

      emit(state.copyWith(
        isLoading: false,
        latitude: event.latitude,
        longitude: event.longitude,
        qiblaDirection: qiblaDirection,
        locationName: locationName,
        isMapLoaded: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateQiblaLocation(
    UpdateQiblaLocation event,
    Emitter<QiblaState> emit,
  ) async {
    emit(state.copyWith(
      latitude: event.latitude,
      longitude: event.longitude,
    ));

    // Reload qibla direction with new location
    add(LoadQiblaDirection(
      latitude: event.latitude,
      longitude: event.longitude,
    ));
  }

  Future<void> _onRefreshQiblaDirection(
    RefreshQiblaDirection event,
    Emitter<QiblaState> emit,
  ) async {
    if (state.latitude != null && state.longitude != null) {
      add(LoadQiblaDirection(
        latitude: state.latitude!,
        longitude: state.longitude!,
      ));
    }
  }

  void _onUpdateDeviceDirection(
    UpdateDeviceDirection event,
    Emitter<QiblaState> emit,
  ) {
    // Calculate the qiblah angle
    double qiblahAngle = event.qiblah;

    // Normalize to -180 to 180 range for easier comparison
    if (qiblahAngle > 180) {
      qiblahAngle = qiblahAngle - 360;
    } else if (qiblahAngle < -180) {
      qiblahAngle = qiblahAngle + 360;
    }

    // Check if device is facing Qiblah (within 25 degrees tolerance)
    bool isFacingQiblah = qiblahAngle.abs() <= 25;

    emit(state.copyWith(
      deviceDirection: event.direction,
      qiblahAngle: qiblahAngle,
      isFacingQiblah: isFacingQiblah,
    ));
  }

  void _onUpdatePhoneFlatness(
    UpdatePhoneFlatness event,
    Emitter<QiblaState> emit,
  ) {
    emit(state.copyWith(
      isPhoneLyingFlat: event.isLyingFlat,
    ));
  }

  Future<String> _getLocationName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return "${placemark.name}, ${placemark.locality}, ${placemark.country}";
      }
      return 'Location not found';
    } catch (e) {
      return 'Error fetching location';
    }
  }

  double _calculateQiblaDirection(double latitude, double longitude) {
    // Kaaba coordinates (Mecca, Saudi Arabia)
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;

    // Convert to radians
    final lat1 = latitude * math.pi / 180;
    final lng1 = longitude * math.pi / 180;
    final lat2 = kaabaLat * math.pi / 180;
    final lng2 = kaabaLng * math.pi / 180;

    // Calculate the bearing
    final y = math.sin(lng2 - lng1) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(lng2 - lng1);

    double bearing = math.atan2(y, x) * 180 / math.pi;

    // Convert to 0-360 range
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  String getDirectionText(double angle) {
    if (angle >= 337.5 || angle < 22.5) return 'شمال';
    if (angle >= 22.5 && angle < 67.5) return 'شمال شرق';
    if (angle >= 67.5 && angle < 112.5) return 'شرق';
    if (angle >= 112.5 && angle < 157.5) return 'جنوب شرق';
    if (angle >= 157.5 && angle < 202.5) return 'جنوب';
    if (angle >= 202.5 && angle < 247.5) return 'جنوب غرب';
    if (angle >= 247.5 && angle < 292.5) return 'غرب';
    if (angle >= 292.5 && angle < 337.5) return 'شمال غرب';
    return 'شمال';
  }
}
