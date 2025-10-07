import 'package:equatable/equatable.dart';
import '../../models/azkar/azkar_category_model.dart';
import '../../models/azkar/azkar_tracking_model.dart';

abstract class AzkarState extends Equatable {
  const AzkarState();

  @override
  List<Object?> get props => [];
}

class AzkarInitial extends AzkarState {}

class AzkarLoading extends AzkarState {}

class AzkarLoaded extends AzkarState {
  final List<AzkarCategoryModel> categories;
  final List<AzkarTrackingModel> tracking;

  const AzkarLoaded({
    required this.categories,
    required this.tracking,
  });

  @override
  List<Object?> get props => [categories, tracking];

  /// Get tracking for a specific category
  AzkarTrackingModel? getTrackingForCategory(String categoryName) {
    try {
      return tracking.firstWhere((track) => track.category == categoryName);
    } catch (e) {
      return null;
    }
  }
}

class AzkarFailure extends AzkarState {
  final String error;

  const AzkarFailure(this.error);

  @override
  List<Object?> get props => [error];
}
