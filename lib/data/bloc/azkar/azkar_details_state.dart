import 'package:equatable/equatable.dart';
import '../../models/azkar/azkar_model.dart';

abstract class AzkarDetailsState extends Equatable {
  const AzkarDetailsState();

  @override
  List<Object?> get props => [];
}

class AzkarDetailsInitial extends AzkarDetailsState {}

class AzkarDetailsLoading extends AzkarDetailsState {}

class AzkarDetailsLoaded extends AzkarDetailsState {
  final List<AzkarModel> azkars;
  final String categoryId;

  const AzkarDetailsLoaded({
    required this.azkars,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [azkars, categoryId];

  /// Get total repeat count for all azkars
  int get totalRepeatCount {
    return azkars.fold(0, (sum, azkar) => sum + azkar.repeatCount);
  }
}

class AzkarDetailsFailure extends AzkarDetailsState {
  final String error;

  const AzkarDetailsFailure(this.error);

  @override
  List<Object?> get props => [error];
}
