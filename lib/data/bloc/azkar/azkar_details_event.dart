import 'package:equatable/equatable.dart';

abstract class AzkarDetailsEvent extends Equatable {
  const AzkarDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAzkarsByCategory extends AzkarDetailsEvent {
  final String categoryId;

  const LoadAzkarsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class RefreshAzkarsByCategory extends AzkarDetailsEvent {
  final String categoryId;

  const RefreshAzkarsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
