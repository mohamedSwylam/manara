import 'package:equatable/equatable.dart';

abstract class QiblaEvent extends Equatable {
  const QiblaEvent();

  @override
  List<Object?> get props => [];
}

class LoadQiblaDirection extends QiblaEvent {
  final double latitude;
  final double longitude;

  const LoadQiblaDirection({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class UpdateQiblaLocation extends QiblaEvent {
  final double latitude;
  final double longitude;

  const UpdateQiblaLocation({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class RefreshQiblaDirection extends QiblaEvent {
  const RefreshQiblaDirection();
}

class UpdateDeviceDirection extends QiblaEvent {
  final double direction;
  final double qiblah;

  const UpdateDeviceDirection({
    required this.direction,
    required this.qiblah,
  });

  @override
  List<Object?> get props => [direction, qiblah];
}

class UpdatePhoneFlatness extends QiblaEvent {
  final bool isLyingFlat;

  const UpdatePhoneFlatness({
    required this.isLyingFlat,
  });

  @override
  List<Object?> get props => [isLyingFlat];
} 
