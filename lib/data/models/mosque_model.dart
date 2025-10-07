import 'package:equatable/equatable.dart';

class MosqueModel extends Equatable {
  final String name;
  final String location;
  final String distance;
  final double latitude;
  final double longitude;

  const MosqueModel({
    required this.name,
    required this.location,
    required this.distance,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [name, location, distance, latitude, longitude];

  MosqueModel copyWith({
    String? name,
    String? location,
    String? distance,
    double? latitude,
    double? longitude,
  }) {
    return MosqueModel(
      name: name ?? this.name,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
} 
