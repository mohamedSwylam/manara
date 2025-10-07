import 'package:equatable/equatable.dart';
import '../../models/auth/change_password_request_model.dart';

abstract class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object?> get props => [];
}

class ChangePasswordSubmitted extends ChangePasswordEvent {
  final ChangePasswordRequestModel request;

  const ChangePasswordSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

class ToggleChangePasswordVisibility extends ChangePasswordEvent {
  final String field;

  const ToggleChangePasswordVisibility(this.field);

  @override
  List<Object?> get props => [field];
}
