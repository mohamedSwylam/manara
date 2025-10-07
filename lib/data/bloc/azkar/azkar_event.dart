import 'package:equatable/equatable.dart';

abstract class AzkarEvent extends Equatable {
  const AzkarEvent();

  @override
  List<Object?> get props => [];
}

class LoadAzkarData extends AzkarEvent {}

class RefreshAzkarData extends AzkarEvent {}
